import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class YogaPoseDetection extends StatefulWidget {
  const YogaPoseDetection({super.key});

  @override
  State<YogaPoseDetection> createState() => _YogaPoseDetectionState();
}

class _YogaPoseDetectionState extends State<YogaPoseDetection>
    with WidgetsBindingObserver {
  late ImagePicker imagePicker;
  File? _image;
  late PoseDetector poseDetector;
  ui.Image? image;
  List<Pose> poses = [];
  String poseMessage = '';
  bool _isProcessing = false;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isDisposed = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  void _initializeCamera() {
    if (!_isCameraInitialized) {
      imagePicker = ImagePicker();
      final options = PoseDetectorOptions(
        model: PoseDetectionModel.accurate,
        mode: PoseDetectionMode.single,
      );
      poseDetector = PoseDetector(options: options);
      _isCameraInitialized = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is in foreground
      if (!_isDisposed && mounted) {
        setState(() {});
      }
    } else if (state == AppLifecycleState.paused) {
      // App is in background
      if (!_isDisposed && mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Clean up resources
    image?.dispose();
    if (poseDetector != null) {
      poseDetector.close();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _imgFromCamera() async {
    if (_isProcessing || _isDisposed) return;

    try {
      setState(() {
        _isProcessing = true;
        _showLoadingIndicator();
      });

      // Check camera permissions
      final status = await Permission.camera.request();
      if (status.isDenied) {
        throw Exception('Camera permission denied');
      }

      // Clear previous image resources
      _clearPreviousImage();

      // Add delay to prevent rapid camera access
      await Future.delayed(Duration(milliseconds: 500));

      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null && !_isDisposed) {
        // Validate image size
        final fileSize = await pickedFile.length();
        if (fileSize > 5 * 1024 * 1024) { // 5MB limit
          throw Exception('Image too large');
        }

        if (!_isDisposed) {
          // Set image file first
          setState(() {
            _image = File(pickedFile.path);
          });

          // Process image in background
          await Future.microtask(() async {
            try {
              // First draw the pose
              await drawPose();
              
              // Then do pose detection
              await doPoseDetection();
              
              // Finally show the message
              await poseDetectionMessage();
            } catch (e) {
              if (!_isDisposed) {
                _showError(e.toString());
              }
            }
          });
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        _showError(e.toString());
      }
    } finally {
      if (!_isDisposed) {
        setState(() {
          _isProcessing = false;
          _hideLoadingIndicator();
        });
      }
    }
  }

  void _clearPreviousImage() {
    if (_image != null) {
      // Dispose of previous image resources
      image?.dispose();
      _image = null;
      image = null;
      poses = [];
      setState(() {});
    }
  }

  Future<void> _imgFromGallery() async {
    if (_isProcessing || _isDisposed) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      // Release previous image resources
      if (_image != null) {
        _image = null;
        image = null;
        poses = [];
        setState(() {});
      }

      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null && !_isDisposed) {
        setState(() {
          _image = File(pickedFile.path);
        });

        await drawPose();
        await doPoseDetection();
        await poseDetectionMessage();
      }
    } catch (e) {
      if (!_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing gallery: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (!_isDisposed) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> doPoseDetection() async {
    if (_image == null || _isDisposed) return;

    try {
      InputImage inputImage = InputImage.fromFile(_image!);
      final detectedPoses = await poseDetector.processImage(inputImage);
      
      if (!_isDisposed) {
        setState(() {
          poses = detectedPoses;
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        _showError('Error processing image: ${e.toString()}');
      }
    }
  }

  Future<void> drawPose() async {
    if (_image == null || _isDisposed) return;

    try {
      final bytes = await _image!.readAsBytes();
      final decodedImage = await decodeImageFromList(bytes);
      
      if (!_isDisposed) {
        setState(() {
          image = decodedImage;
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        _showError('Error drawing pose: ${e.toString()}');
      }
    }
  }

  Future<void> poseDetectionMessage() async {
    if (poses.isEmpty) {
      setState(() {
        poseMessage = 'No pose detected. Please ensure good lighting and clear view.';
      });
      return;
    }

    final pose = poses[0];
    
    // Check pose detection confidence
    if (!_isPoseConfident(pose)) {
      setState(() {
        poseMessage = 'Pose detection unclear. Please ensure good lighting.';
      });
      return;
    }

    // Calculate dynamic thresholds based on body proportions
    final bodyHeight = _calculateBodyHeight(pose.landmarks);
    final thresholds = _calculateDynamicThresholds(bodyHeight);

    // Use dynamic thresholds for pose detection
    bool oneLegUp = _checkOneLegUp(pose.landmarks, thresholds);
    bool handsTogetherAboveHead =
        (pose.landmarks[PoseLandmarkType.leftWrist]!.x - pose.landmarks[PoseLandmarkType.rightWrist]!.x).abs() < 40;
    String message = 'Unknown Pose or Form Improper';

    if (oneLegUp) {
      message =
          handsTogetherAboveHead
              ? 'Vrksasana (Tree Pose): Proper Form'
              : 'Vrksasana (Tree Pose): Improper Form – Hands not together above head';
    }
    // 🏔️ Tadasana (Mountain Pose)
    else if (pose.landmarks[PoseLandmarkType.leftWrist]!.y > pose.landmarks[PoseLandmarkType.leftHip]!.y &&
        pose.landmarks[PoseLandmarkType.rightWrist]!.y > pose.landmarks[PoseLandmarkType.rightHip]!.y &&
        pose.landmarks[PoseLandmarkType.leftShoulder]!.y < pose.landmarks[PoseLandmarkType.leftHip]!.y &&
        pose.landmarks[PoseLandmarkType.rightShoulder]!.y < pose.landmarks[PoseLandmarkType.rightHip]!.y) {
      message = 'Tadasana (Mountain Pose): Proper Form';
    }
    // ⚔️ Virabhadrasana II (Warrior II)
    else if (_isArmHorizontal(pose.landmarks[PoseLandmarkType.leftShoulder]!, pose.landmarks[PoseLandmarkType.leftWrist]!, bodyHeight) &&
        _isArmHorizontal(pose.landmarks[PoseLandmarkType.rightShoulder]!, pose.landmarks[PoseLandmarkType.rightWrist]!, bodyHeight)) {
      message =
          _legsApart(pose.landmarks[PoseLandmarkType.leftHip]!, pose.landmarks[PoseLandmarkType.rightHip]!, pose.landmarks[PoseLandmarkType.leftAnkle]!, pose.landmarks[PoseLandmarkType.rightAnkle]!)
              ? 'Virabhadrasana II (Warrior II): Proper Form'
              : 'Virabhadrasana II (Warrior II): Improper Form – Legs not wide enough';
    }
    // 🙌 Urdhva Hastasana (Raised Hands Pose)
    else if (pose.landmarks[PoseLandmarkType.leftWrist]!.y < pose.landmarks[PoseLandmarkType.leftShoulder]!.y &&
        pose.landmarks[PoseLandmarkType.rightWrist]!.y < pose.landmarks[PoseLandmarkType.rightShoulder]!.y &&
        (pose.landmarks[PoseLandmarkType.leftWrist]!.x - pose.landmarks[PoseLandmarkType.rightWrist]!.x).abs() < 60) {
      bool upright =
          (pose.landmarks[PoseLandmarkType.leftShoulder]!.x - pose.landmarks[PoseLandmarkType.leftHip]!.x).abs() < 30 &&
          (pose.landmarks[PoseLandmarkType.rightShoulder]!.x - pose.landmarks[PoseLandmarkType.rightHip]!.x).abs() < 30;
      message =
          upright
              ? 'Urdhva Hastasana (Raised Hands Pose): Proper Form'
              : 'Urdhva Hastasana (Raised Hands Pose): Improper Form – Keep body straight';
    }
    // 🐶 Adho Mukha Svanasana (Downward-Facing Dog)
    else if (hipAboveHandsAndFeet(
      pose.landmarks[PoseLandmarkType.leftHip]!,
      pose.landmarks[PoseLandmarkType.rightHip]!,
      pose.landmarks[PoseLandmarkType.leftWrist]!,
      pose.landmarks[PoseLandmarkType.rightWrist]!,
      pose.landmarks[PoseLandmarkType.leftAnkle]!,
      pose.landmarks[PoseLandmarkType.rightAnkle]!,
    )) {
      message = 'Adho Mukha Svanasana (Downward Dog): Proper Form';
    }
    // 🔺 Trikonasana (Triangle Pose)
    else if (_isArmVertical(pose.landmarks[PoseLandmarkType.leftShoulder]!, pose.landmarks[PoseLandmarkType.leftWrist]!) &&
        _isArmVertical(pose.landmarks[PoseLandmarkType.rightShoulder]!, pose.landmarks[PoseLandmarkType.rightWrist]!) &&
        _legsApart(pose.landmarks[PoseLandmarkType.leftHip]!, pose.landmarks[PoseLandmarkType.rightHip]!, pose.landmarks[PoseLandmarkType.leftAnkle]!, pose.landmarks[PoseLandmarkType.rightAnkle]!)) {
      message = 'Trikonasana (Triangle Pose): Proper Form';
    }
    // 🧘 Virabhadrasana I (Warrior I)
    else if (_isArmRaised(pose.landmarks[PoseLandmarkType.leftWrist]!, pose.landmarks[PoseLandmarkType.leftShoulder]!) &&
        _isArmRaised(pose.landmarks[PoseLandmarkType.rightWrist]!, pose.landmarks[PoseLandmarkType.rightShoulder]!) &&
        _oneKneeBent(pose.landmarks[PoseLandmarkType.leftKnee]!, pose.landmarks[PoseLandmarkType.rightKnee]!, pose.landmarks[PoseLandmarkType.leftHip]!, pose.landmarks[PoseLandmarkType.rightHip]!)) {
      message = 'Virabhadrasana I (Warrior I): Proper Form';
    }
    // 🐍 Bhujangasana (Cobra Pose)
    else if (_isUpperBodyLifted(
          pose.landmarks[PoseLandmarkType.leftShoulder]!,
          pose.landmarks[PoseLandmarkType.rightShoulder]!,
          pose.landmarks[PoseLandmarkType.leftHip]!,
          pose.landmarks[PoseLandmarkType.rightHip]!,
        ) &&
        pose.landmarks[PoseLandmarkType.leftKnee]!.y > pose.landmarks[PoseLandmarkType.leftHip]!.y &&
        pose.landmarks[PoseLandmarkType.rightKnee]!.y > pose.landmarks[PoseLandmarkType.rightHip]!.y) {
      message = 'Bhujangasana (Cobra Pose): Proper Form';
    }
    // 🙇 Balasana (Child Pose)
    else if (pose.landmarks[PoseLandmarkType.nose] != null &&
        pose.landmarks[PoseLandmarkType.leftWrist]!.y > pose.landmarks[PoseLandmarkType.leftShoulder]!.y &&
        pose.landmarks[PoseLandmarkType.rightWrist]!.y > pose.landmarks[PoseLandmarkType.rightShoulder]!.y &&
        pose.landmarks[PoseLandmarkType.nose]!.y < pose.landmarks[PoseLandmarkType.leftHip]!.y &&
        pose.landmarks[PoseLandmarkType.leftAnkle]!.y < pose.landmarks[PoseLandmarkType.leftHip]!.y) {
      message = 'Balasana (Child Pose): Proper Form';
    }
    // 🏋️‍♂️ Setu Bandhasana (Bridge Pose) - New Pose
    else if (pose.landmarks[PoseLandmarkType.leftHip]!.y > pose.landmarks[PoseLandmarkType.leftKnee]!.y &&
        pose.landmarks[PoseLandmarkType.rightHip]!.y > pose.landmarks[PoseLandmarkType.rightKnee]!.y &&
        pose.landmarks[PoseLandmarkType.leftAnkle]!.y > pose.landmarks[PoseLandmarkType.leftKnee]!.y &&
        pose.landmarks[PoseLandmarkType.rightAnkle]!.y > pose.landmarks[PoseLandmarkType.rightKnee]!.y &&
        pose.landmarks[PoseLandmarkType.leftShoulder]!.y < pose.landmarks[PoseLandmarkType.leftHip]!.y &&
        pose.landmarks[PoseLandmarkType.rightShoulder]!.y < pose.landmarks[PoseLandmarkType.rightHip]!.y) {
      message = 'Setu Bandhasana (Bridge Pose): Proper Form';
    }

    setState(() {
      poseMessage = message;
    });
  }

  bool _isPoseConfident(Pose pose) {
    final requiredConfidence = 0.7;
    final keyPoints = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
    ];
    
    return keyPoints.every((point) => 
      (pose.landmarks[point]?.likelihood ?? 0) > requiredConfidence);
  }

  double _calculateBodyHeight(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final nose = landmarks[PoseLandmarkType.nose];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
    
    if (nose == null || leftAnkle == null || rightAnkle == null) {
      return 0;
    }
    
    // Calculate average ankle position
    final ankleY = (leftAnkle.y + rightAnkle.y) / 2;
    return (ankleY - nose.y).abs();
  }

  List<double> _calculateDynamicThresholds(double bodyHeight) {
    // Implement logic to calculate dynamic thresholds based on body height
    // This is a placeholder and should be replaced with actual implementation
    return [bodyHeight * 0.1, bodyHeight * 0.15, bodyHeight * 0.2];
  }

  bool _checkOneLegUp(Map<PoseLandmarkType, PoseLandmark> landmarks, List<double> thresholds) {
    // Implement logic to check if one leg is up based on landmarks and thresholds
    // This is a placeholder and should be replaced with actual implementation
    return false; // Placeholder return, actual implementation needed
  }

  bool _isArmHorizontal(PoseLandmark shoulder, PoseLandmark wrist, double bodyHeight) {
    // Calculate dynamic threshold based on body height
    final threshold = bodyHeight * 0.1; // 10% of body height
    return (shoulder.y - wrist.y).abs() < threshold;
  }

  bool _legsApart(
    PoseLandmark leftHip,
    PoseLandmark rightHip,
    PoseLandmark leftAnkle,
    PoseLandmark rightAnkle,
  ) {
    return (leftAnkle.x - rightAnkle.x).abs() >
        50; // Example for legs apart check
  }

  bool _isArmVertical(PoseLandmark shoulder, PoseLandmark wrist) {
    return (shoulder.x - wrist.x).abs() <
        30; // Example threshold for vertical arm
  }

  bool _isArmRaised(PoseLandmark wrist, PoseLandmark shoulder) {
    return wrist.y < shoulder.y; // Check if arm is raised
  }

  bool _oneKneeBent(
    PoseLandmark leftKnee,
    PoseLandmark rightKnee,
    PoseLandmark leftHip,
    PoseLandmark rightHip,
  ) {
    return (leftKnee.y < leftHip.y ||
        rightKnee.y < rightHip.y); // Example for one bent knee
  }

  bool _isUpperBodyLifted(
    PoseLandmark leftShoulder,
    PoseLandmark rightShoulder,
    PoseLandmark leftHip,
    PoseLandmark rightHip,
  ) {
    return leftShoulder.y < leftHip.y &&
        rightShoulder.y < rightHip.y; // Example for upper body lifted
  }

  bool hipAboveHandsAndFeet(
    PoseLandmark leftHip,
    PoseLandmark rightHip,
    PoseLandmark leftWrist,
    PoseLandmark rightWrist,
    PoseLandmark leftAnkle,
    PoseLandmark rightAnkle,
  ) {
    return leftHip.y < leftWrist.y &&
        rightHip.y < rightWrist.y; // Example for Downward Dog check
  }

  void _showError(String message) {
    if (!_isDisposed) {
      setState(() {
        _errorMessage = message;
      });
      
      // Auto-hide error after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (!_isDisposed) {
          setState(() {
            _errorMessage = null;
          });
        }
      });
    }
  }

  void _showLoadingIndicator() {
    if (!_isDisposed) {
      setState(() {
        _isLoading = true;
      });
    }
  }

  void _hideLoadingIndicator() {
    if (!_isDisposed) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffe5f6),
      appBar: AppBar(
        backgroundColor: Color(0xffffe5f6),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.navigate_before, size: 35, color: Color(0xff9B7EBD)),
        ),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 0),
                  child: _buildImageDisplay(),
                ),
              ),
              if (_image != null) _buildPoseMessage(),
              _buildBottomControls(),
            ],
          ),
          if (_isProcessing) _buildLoadingIndicator(),
          if (_errorMessage != null) _buildErrorMessage(),
        ],
      ),
    );
  }

  Widget _buildImageDisplay() {
    return Container(
      child: _image != null && image != null
          ? Center(
              child: FittedBox(
                child: SizedBox(
                  width: image?.width.toDouble() ?? 300,
                  height: image?.height.toDouble() ?? 300,
                  child: CustomPaint(
                    painter: posePainter(image, poses),
                  ),
                ),
              ),
            )
          : SizedBox(
              height: MediaQuery.of(context).size.height - 300,
              child: SizedBox(
                child: Image.asset(
                  'assets/images/yogapose5.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }

  Widget _buildPoseMessage() {
    return Visibility(
      visible:
          _image != null, // Message box visible only after image upload
      child: Container(
        height: 100, // Set a specific smaller height for the message box
        width: 350, // Adjusted width to make the box smaller
        margin: EdgeInsets.only(
          top: 110,
        ), // Reduced margin for a more compact look
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(
            8,
          ), // Slightly smaller rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6, // Reduced blur radius for a subtler shadow
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Color(0xff9B7EBD), // Border color
            width: 1.5, // Border width
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ), // Reduced horizontal padding
            child: Text(
              poseMessage,
              textAlign: TextAlign.center, // Center the message text
              style: GoogleFonts.outfit(
                color: Color(0xff9B7EBD),
                fontSize:
                    16, // Smaller font size for a more compact message
                fontWeight: FontWeight.w500, // Lighter boldness
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              _imgFromGallery();
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              decoration: BoxDecoration(
                color: Color(0xffffe5f6),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Color(0xff9B7EBD), // Border color
                  width: 2.0, // Border width
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.photo, color: Color(0xff9B7EBD), size: 30),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              _imgFromCamera();
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              decoration: BoxDecoration(
                color: Color(0xffffe5f6),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Color(0xff9B7EBD), // Border color
                  width: 2.0, // Border width
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: Color(0xff9B7EBD),
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _errorMessage!,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}

class posePainter extends CustomPainter {
  final ui.Image? image;
  final List<Pose> poses;
  
  posePainter(this.image, this.poses);

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;
    
    canvas.drawImage(image!, Offset.zero, Paint());

    Paint paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill
      ..strokeWidth = 4;

    Paint leftPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    Paint rightPaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    for (Pose pose in poses) {
      // to access all landmarks
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(Offset(landmark.x, landmark.y), 5, paint);
      });

      void drawCustomLine(
        PoseLandmarkType point1,
        PoseLandmarkType point2,
        Paint linePaint,
      ) {
        PoseLandmark poseLandmark1 = pose.landmarks[point1]!;
        PoseLandmark poseLandmark2 = pose.landmarks[point2]!;
        canvas.drawLine(
          Offset(poseLandmark1.x, poseLandmark1.y),
          Offset(poseLandmark2.x, poseLandmark2.y),
          linePaint,
        );
      }

      //Head & Face
      drawCustomLine(
        PoseLandmarkType.leftEar,
        PoseLandmarkType.leftEye,
        leftPaint,
      );
      drawCustomLine(
        PoseLandmarkType.leftEye,
        PoseLandmarkType.rightEye,
        leftPaint,
      );
      drawCustomLine(
        PoseLandmarkType.rightEye,
        PoseLandmarkType.rightEar,
        rightPaint,
      );
      drawCustomLine(
        PoseLandmarkType.nose,
        PoseLandmarkType.leftEye,
        leftPaint,
      );
      drawCustomLine(
        PoseLandmarkType.nose,
        PoseLandmarkType.rightEye,
        rightPaint,
      );

      //Draw head-to-body connection
      drawCustomLine(
        PoseLandmarkType.nose,
        PoseLandmarkType.leftShoulder,
        leftPaint,
      );
      drawCustomLine(
        PoseLandmarkType.nose,
        PoseLandmarkType.rightShoulder,
        rightPaint,
      );

      // Drawing arms
      drawCustomLine(
        PoseLandmarkType.rightWrist,
        PoseLandmarkType.rightElbow,
        rightPaint,
      );
      drawCustomLine(
        PoseLandmarkType.rightElbow,
        PoseLandmarkType.rightShoulder,
        rightPaint,
      );
      drawCustomLine(
        PoseLandmarkType.leftWrist,
        PoseLandmarkType.leftElbow,
        leftPaint,
      );
      drawCustomLine(
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftShoulder,
        leftPaint,
      );

      // Drawing body
      drawCustomLine(
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightHip,
        rightPaint,
      );
      drawCustomLine(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftHip,
        leftPaint,
      );
      drawCustomLine(
        PoseLandmarkType.rightHip,
        PoseLandmarkType.leftHip,
        rightPaint,
      );
      drawCustomLine(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.rightShoulder,
        leftPaint,
      );

      // Drawing legs
      drawCustomLine(
        PoseLandmarkType.rightHip,
        PoseLandmarkType.rightKnee,
        rightPaint,
      );
      drawCustomLine(
        PoseLandmarkType.rightKnee,
        PoseLandmarkType.rightAnkle,
        rightPaint,
      );
      drawCustomLine(
        PoseLandmarkType.leftHip,
        PoseLandmarkType.leftKnee,
        leftPaint,
      );
      drawCustomLine(
        PoseLandmarkType.leftKnee,
        PoseLandmarkType.leftAnkle,
        leftPaint,
      );

      // Drawing Feet
      drawCustomLine(
        PoseLandmarkType.leftAnkle,
        PoseLandmarkType.leftHeel,
        leftPaint,
      );
      drawCustomLine(
        PoseLandmarkType.leftHeel,
        PoseLandmarkType.leftFootIndex,
        leftPaint,
      );

      drawCustomLine(
        PoseLandmarkType.rightAnkle,
        PoseLandmarkType.rightHeel,
        rightPaint,
      );
      drawCustomLine(
        PoseLandmarkType.rightHeel,
        PoseLandmarkType.rightFootIndex,
        rightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

