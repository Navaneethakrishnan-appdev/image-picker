import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker_test/main.dart';
import 'package:image_picker_test/modul/live_camera_fitness_tracker/exercise_data_model.dart';
import 'package:image_picker_test/modul/live_camera_fitness_tracker/level_selection_page.dart';

class LiveCameraFitnessTracker extends StatefulWidget {
  final ExerciseDataModel exerciseDataModel;
  final ExerciseLevel selectedLevel;
  final int currentLevelIndex;
  final List<ExerciseLevel> allLevels;

  LiveCameraFitnessTracker({
    super.key,
    required this.exerciseDataModel,
    required this.selectedLevel,
    required this.currentLevelIndex,
    required this.allLevels,
  });

  @override
  State<LiveCameraFitnessTracker> createState() =>
      _LiveCameraFitnessTrackerState();
}

class _LiveCameraFitnessTrackerState extends State<LiveCameraFitnessTracker> {
  dynamic controller;
  bool isBusy = false;
  late Size size;
  late Timer _timer;
  int _timeLeft = 0;
  int _currentCount = 0;
  bool _isExerciseComplete = false;
  bool _exerciseStarted = false;

  //TODO declare detector
  late PoseDetector poseDetector;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    _timeLeft = widget.selectedLevel.durationInSeconds;
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft <= 0) {
        if (_exerciseStarted) {
          checkExerciseResult();
        }
        timer.cancel();
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  void checkExerciseResult() {
    setState(() {
      _isExerciseComplete = true;
    });

    if (_currentCount >= widget.selectedLevel.targetCount) {
      // Mark current level as completed
      setState(() {
        widget.selectedLevel.markAsCompleted();
      });

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Level Complete! 🎉',
                style: GoogleFonts.outfit(
                  color: widget.exerciseDataModel.color,
                ),
              ),
              content: Text(
                'You completed ${_currentCount} ${widget.exerciseDataModel.title.toLowerCase()}!',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    if (widget.currentLevelIndex + 1 <
                        widget.allLevels.length) {
                      // Go to next level
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => LiveCameraFitnessTracker(
                                exerciseDataModel: widget.exerciseDataModel,
                                selectedLevel:
                                    widget.allLevels[widget.currentLevelIndex +
                                        1],
                                currentLevelIndex: widget.currentLevelIndex + 1,
                                allLevels: widget.allLevels,
                              ),
                        ),
                      );
                    } else {
                      // If no more levels, go back to level selection
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Next Level',
                    style: GoogleFonts.outfit(
                      color: widget.exerciseDataModel.color,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => LevelSelectionPage(
                              exerciseDataModel: widget.exerciseDataModel,
                            ),
                      ),
                    );
                  },
                  child: Text(
                    'Close',
                    style: GoogleFonts.outfit(
                      color: widget.exerciseDataModel.color,
                    ),
                  ),
                ),
              ],
            ),
      );
    } else {
      // Show failure dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Level Failed 😔',
                style: GoogleFonts.outfit(
                  color: widget.exerciseDataModel.color,
                ),
              ),
              content: Text(
                'You completed ${_currentCount} out of ${widget.selectedLevel.targetCount} ${widget.exerciseDataModel.title.toLowerCase()}.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    setState(() {
                      _timeLeft = widget.selectedLevel.durationInSeconds;
                      _currentCount = 0;
                      _isExerciseComplete = false;
                      _exerciseStarted = false;
                    });
                    // Restart the timer after resetting state
                    startTimer();
                  },
                  child: Text(
                    'Try Again',
                    style: GoogleFonts.outfit(
                      color: widget.exerciseDataModel.color,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => LevelSelectionPage(
                              exerciseDataModel: widget.exerciseDataModel,
                            ),
                      ),
                    );
                  },
                  child: Text(
                    'Close',
                    style: GoogleFonts.outfit(
                      color: widget.exerciseDataModel.color,
                    ),
                  ),
                ),
              ],
            ),
      );
    }
  }

  //TODO code to initialize the camera feed
  initializeCamera() async {
    //TODO initialize detector
    final option = PoseDetectorOptions(mode: PoseDetectionMode.stream);
    poseDetector = PoseDetector(options: option);

    controller = CameraController(
      cameras[0],
      ResolutionPreset.veryHigh,
      imageFormatGroup:
          Platform.isAndroid
              ? ImageFormatGroup.nv21
              : ImageFormatGroup.bgra8888,

      // imageFormatGroup:
      //     Platform.isAndroid
      //         ? ImageFormatGroup.nv21
      //         : ImageFormatGroup.bgra8888,
    );
    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      // controller.startImageStream(
      //   (image) => {
      //     if (!isBusy) {isBusy = true, img = image, doPoseEstimationOnFrame()},
      //   },
      // );
      controller.startImageStream((image) {
        if (!isBusy) {
          isBusy = true;
          img = image;
          doPoseEstimationOnFrame();
        }
      });
    });
  }

  //TODO pose detection on a frame
  List<Pose> _scanResults = [];
  CameraImage? img;

  doPoseEstimationOnFrame() async {
    if (!_exerciseStarted) {
      isBusy = false;
      return;
    }

    var inputImage = _inputImageFromCameraImage(img!);

    if (inputImage == null) {
      print('❌ InputImage is null — skipping frame');
      setState(() {
        isBusy = false;
      });
      return;
    }

    print('👉 Starting pose detection');

    try {
      final List<Pose> poses = await poseDetector.processImage(inputImage);
      print('✅ Poses = ${poses.length.toString()}');
      setState(() {
        _scanResults = poses;
        isBusy = false;
      });
      if (poses.length > 0) {
        if (widget.exerciseDataModel.type == ExerciseType.pushUps) {
          detectPushUp(poses.first.landmarks);
        } else if (widget.exerciseDataModel.type == ExerciseType.squats) {
          detectSquat(poses.first.landmarks);
        } else if (widget.exerciseDataModel.type ==
            ExerciseType.downwardDogPlank) {
          detectPlankToDownwardDog(poses.first);
        } else if (widget.exerciseDataModel.type == ExerciseType.jumpingJack) {
          detectJumpingJack(poses.first);
        } else if (widget.exerciseDataModel.type == ExerciseType.highKnees) {
          detectHighKnees(poses.first.landmarks);
        }
      }
    } catch (e) {
      print('❌ Error in pose detection: $e');
    }
  }

  //close all resources
  @override
  void dispose() {
    _timer.cancel();
    controller?.dispose();
    poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    if (controller != null && controller.value.isInitialized) {
      stackChildren.add(
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: CameraPreview(controller),
        ),
      );

      if (controller.value.previewSize != null) {
        final previewSize = controller.value.previewSize!;
        final isPortrait =
            MediaQuery.of(context).size.height >
            MediaQuery.of(context).size.width;
        final painterSize =
            isPortrait
                ? Size(previewSize.height, previewSize.width)
                : Size(previewSize.width, previewSize.height);
        stackChildren.add(
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CustomPaint(painter: PosePainter(_scanResults, painterSize)),
          ),
        );
      }

      if (!_exerciseStarted) {
        stackChildren.add(
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _exerciseStarted = true;
                  _timeLeft = widget.selectedLevel.durationInSeconds;
                  _currentCount = 0;
                  startTimer();
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: widget.exerciseDataModel.color,
              ),
              child: Text(
                'Start',
                style: GoogleFonts.outfit(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
        );
      }

      if (_exerciseStarted) {
        stackChildren.add(
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 70,
              width: 70,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: widget.exerciseDataModel.color,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Text(
                  '$_currentCount',
                  style: GoogleFonts.outfit(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ),
        );
      }
    }

    if (_exerciseStarted) {
      stackChildren.add(
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Timer container
              Container(
                margin: EdgeInsets.only(top: 50),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.exerciseDataModel.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Time: $_timeLeft seconds',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Container(
                height: 70,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(left: 10, right: 10, top: 20),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: widget.exerciseDataModel.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        '${widget.exerciseDataModel.title} - Level ${widget.selectedLevel.levelNumber}',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      Image(
                        image: AssetImage(
                          'assets/gif/${widget.exerciseDataModel.image}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    print("Scan results length: ${_scanResults.length}");

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 0),
        color: Colors.black,
        child: Stack(children: stackChildren),
      ),
    );
  }

  int pushUpCount = 0;
  bool isLowered = false;
  void detectPushUp(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = landmarks[PoseLandmarkType.rightElbow];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];

    if (leftShoulder == null ||
        rightShoulder == null ||
        leftElbow == null ||
        rightElbow == null ||
        leftWrist == null ||
        rightWrist == null ||
        leftHip == null ||
        rightHip == null) {
      return; // Skip if any landmark is missing
    }

    // Calculate elbow angles
    double leftElbowAngle = calculateAngle(leftShoulder, leftElbow, leftWrist);
    double rightElbowAngle = calculateAngle(
      rightShoulder,
      rightElbow,
      rightWrist,
    );
    double avgElbowAngle = (leftElbowAngle + rightElbowAngle) / 2;

    // Calculate torso alignment (ensuring a straight plank)
    double torsoAngle = calculateAngle(
      leftShoulder,
      leftHip,
      leftKnee ?? rightKnee!,
    );
    bool inPlankPosition =
        torsoAngle > 160 && torsoAngle < 180; // Slight flexibility

    if (avgElbowAngle < 90 && inPlankPosition) {
      // User is in the lowered push-up position
      isLowered = true;
    } else if (avgElbowAngle > 160 && isLowered && inPlankPosition) {
      // User returns to the starting position
      setState(() {
        _currentCount++;
      });
      isLowered = false;
    }
  }

  int squatCount = 0;
  bool isSquatting = false;
  void detectSquat(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

    if (leftHip == null ||
        rightHip == null ||
        leftKnee == null ||
        rightKnee == null ||
        leftAnkle == null ||
        rightAnkle == null ||
        leftShoulder == null ||
        rightShoulder == null) {
      return; // Skip detection if any key landmark is missing
    }

    // Calculate angles
    double leftKneeAngle = calculateAngle(leftHip, leftKnee, leftAnkle);
    double rightKneeAngle = calculateAngle(rightHip, rightKnee, rightAnkle);
    double avgKneeAngle = (leftKneeAngle + rightKneeAngle) / 2;

    double hipY = (leftHip.y + rightHip.y) / 2;
    double kneeY = (leftKnee.y + rightKnee.y) / 2;

    bool deepSquat = avgKneeAngle < 90; // Ensuring squat is deep enough

    if (deepSquat && hipY > kneeY) {
      if (!isSquatting) {
        isSquatting = true;
      }
    } else if (!deepSquat && isSquatting) {
      setState(() {
        _currentCount++;
      });
      isSquatting = false;
    }
  }

  int plankToDownwardDogCount = 0;
  bool isInDownwardDog = false;
  void detectPlankToDownwardDog(Pose pose) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftHip == null ||
        rightHip == null ||
        leftShoulder == null ||
        rightShoulder == null ||
        leftAnkle == null ||
        rightAnkle == null ||
        leftWrist == null ||
        rightWrist == null) {
      return; // Skip detection if any key landmark is missing
    }

    // **Step 1: Detect Plank Position**
    bool isPlank =
        (leftHip.y - leftShoulder.y).abs() < 30 &&
        (rightHip.y - rightShoulder.y).abs() < 30 &&
        (leftHip.y - leftAnkle.y).abs() > 100 &&
        (rightHip.y - rightAnkle.y).abs() > 100;

    // **Step 2: Detect Downward Dog Position**
    bool isDownwardDog =
        (leftHip.y < leftShoulder.y - 50) &&
        (rightHip.y < rightShoulder.y - 50) &&
        (leftAnkle.y > leftHip.y) &&
        (rightAnkle.y > rightHip.y);

    // **Step 3: Count Repetitions**
    if (isDownwardDog && !isInDownwardDog) {
      isInDownwardDog = true;
    } else if (isPlank && isInDownwardDog) {
      setState(() {
        _currentCount++;
      });
      isInDownwardDog = false;
    }
  }

  int jumpingJackCount = 0;
  bool isJumpingJack = false;
  // bool isJumpingJackOpen = false;
  void detectJumpingJack(Pose pose) {
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftAnkle == null ||
        rightAnkle == null ||
        leftHip == null ||
        rightHip == null ||
        leftShoulder == null ||
        rightShoulder == null ||
        leftWrist == null ||
        rightWrist == null) {
      return; // Skip detection if any landmark is missing
    }

    // Calculate distances
    double legSpread = (rightAnkle.x - leftAnkle.x).abs();
    double armHeight = (leftWrist.y + rightWrist.y) / 2; // Average wrist height
    double hipHeight = (leftHip.y + rightHip.y) / 2; // Average hip height
    double shoulderWidth = (rightShoulder.x - leftShoulder.x).abs();

    // Define thresholds based on shoulder width
    double legThreshold =
        shoulderWidth * 1.2; // Legs should be ~1.2x shoulder width apart
    double armThreshold =
        hipHeight - shoulderWidth * 0.5; // Arms should be above shoulders

    // Check if arms are raised and legs are spread
    bool armsUp = armHeight < armThreshold;
    bool legsApart = legSpread > legThreshold;

    // Detect full jumping jack cycle
    if (armsUp && legsApart && !isJumpingJack) {
      isJumpingJack = true;
    } else if (!armsUp && !legsApart && isJumpingJack) {
      setState(() {
        _currentCount++;
      });
      isJumpingJack = false;
    }
  }

  int highKneeCount = 0;
  bool isLeftKneeUp = false;
  bool isRightKneeUp = false;

  void detectHighKnees(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];

    if (leftHip == null ||
        rightHip == null ||
        leftKnee == null ||
        rightKnee == null) {
      return; // Skip detection if landmarks are missing
    }

    // LEFT KNEE HIGH CHECK
    if (leftKnee.y < leftHip.y - 20) {
      // small buffer to avoid flicker
      if (!isLeftKneeUp) {
        isLeftKneeUp = true;
      }
    } else if (isLeftKneeUp && leftKnee.y > leftHip.y + 20) {
      // Knee was up, now came down → count one rep
      setState(() {
        _currentCount++;
      });
      isLeftKneeUp = false;
    }

    // RIGHT KNEE HIGH CHECK
    if (rightKnee.y < rightHip.y - 20) {
      if (!isRightKneeUp) {
        isRightKneeUp = true;
      }
    } else if (isRightKneeUp && rightKnee.y > rightHip.y + 20) {
      setState(() {
        _currentCount++;
      });
      isRightKneeUp = false;
    }
  }

  // Function to calculate angle between three points (shoulder, elbow, wrist)
  double calculateAngle(
    PoseLandmark shoulder,
    PoseLandmark elbow,
    PoseLandmark wrist,
  ) {
    double a = distance(elbow, wrist);
    double b = distance(shoulder, elbow);
    double c = distance(shoulder, wrist);

    double angle = acos((b * b + a * a - c * c) / (2 * b * a)) * (180 / pi);
    return angle;
  }

  // Helper function to calculate Euclidean distance
  double distance(PoseLandmark p1, PoseLandmark p2) {
    return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );

      final camera = cameras[0];
      final sensorOrientation = camera.sensorOrientation;

      // Handle rotation
      final rotationCompensation =
          _orientations[controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;

      final adjustedRotation =
          camera.lensDirection == CameraLensDirection.front
              ? (sensorOrientation + rotationCompensation) % 360
              : (sensorOrientation - rotationCompensation + 360) % 360;

      final InputImageRotation rotation =
          InputImageRotationValue.fromRawValue(adjustedRotation)!;

      // ML Kit only supports NV21 on Android
      final format = InputImageFormat.nv21;

      final metadata = InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
      print("❌ Error converting image: $e");
      return null;
    }
  }

  //Show rectangles around detected objects
  Widget buildResult() {
    if (_scanResults == null ||
        controller == null ||
        !controller.value.isInitialized) {
      return Text('');
    }
    final Size imageSize = Size(
      controller.value.previewSize!.width,
      controller.value.previewSize!.height,
    );
    CustomPainter painter = PosePainter(_scanResults, imageSize);
    return CustomPaint(painter: painter);
  }
}

class PosePainter extends CustomPainter {
  PosePainter(this.poses, this.absoluteImageSize);

  final List<Pose> poses;
  final Size absoluteImageSize;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..color = Colors.green;

    final leftPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = Colors.yellow;

    final rightPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = Colors.blueAccent;

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
          Offset(landmark.x * scaleX, landmark.y * scaleY),
          1,
          paint,
        );
      });

      void paintLine(
        PoseLandmarkType type1,
        PoseLandmarkType type2,
        Paint paintType,
      ) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
          Offset(joint1.x * scaleX, joint1.y * scaleY),
          Offset(joint2.x * scaleX, joint2.y * scaleY),
          paintType,
        );
      }

      //Head & Face
      paintLine(PoseLandmarkType.leftEar, PoseLandmarkType.leftEye, leftPaint);
      paintLine(PoseLandmarkType.leftEye, PoseLandmarkType.rightEye, leftPaint);
      paintLine(
        PoseLandmarkType.rightEye,
        PoseLandmarkType.rightEar,
        rightPaint,
      );
      paintLine(PoseLandmarkType.nose, PoseLandmarkType.leftEye, leftPaint);
      paintLine(PoseLandmarkType.nose, PoseLandmarkType.rightEye, rightPaint);

      //Draw head-to-body connection
      paintLine(
        PoseLandmarkType.nose,
        PoseLandmarkType.leftShoulder,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.nose,
        PoseLandmarkType.rightShoulder,
        rightPaint,
      );

      // Drawing arms
      paintLine(
        PoseLandmarkType.rightWrist,
        PoseLandmarkType.rightElbow,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.rightElbow,
        PoseLandmarkType.rightShoulder,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.leftWrist,
        PoseLandmarkType.leftElbow,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftShoulder,
        leftPaint,
      );

      // Drawing body
      paintLine(
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightHip,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftHip,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.rightHip,
        PoseLandmarkType.leftHip,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.rightShoulder,
        leftPaint,
      );

      // Drawing legs
      paintLine(
        PoseLandmarkType.rightHip,
        PoseLandmarkType.rightKnee,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.rightKnee,
        PoseLandmarkType.rightAnkle,
        rightPaint,
      );
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(
        PoseLandmarkType.leftKnee,
        PoseLandmarkType.leftAnkle,
        leftPaint,
      );

      // Drawing Feet
      paintLine(
        PoseLandmarkType.leftAnkle,
        PoseLandmarkType.leftHeel,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.leftHeel,
        PoseLandmarkType.leftFootIndex,
        leftPaint,
      );

      paintLine(
        PoseLandmarkType.rightAnkle,
        PoseLandmarkType.rightHeel,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.rightHeel,
        PoseLandmarkType.rightFootIndex,
        rightPaint,
      );
    }

    print(
      "Painting ${poses.length} poses, canvas size: $size, image size: $absoluteImageSize",
    );
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}

// import 'dart:async';
// import 'dart:io';
// import 'dart:math';
//
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
// import 'package:image_picker_test/modul/live_camera_fitness_tracker/exercise_data_model.dart';
// import 'package:image_picker_test/modul/live_camera_fitness_tracker/level_selection_page.dart';
//
// import '../../main.dart';
//
// class LiveCameraFitnessTracker extends StatefulWidget {
//   final ExerciseDataModel exerciseDataModel;
//   final ExerciseLevel selectedLevel;
//   final int currentLevelIndex;
//   final List<ExerciseLevel> allLevels;
//
//   LiveCameraFitnessTracker({
//     super.key,
//     required this.exerciseDataModel,
//     required this.selectedLevel,
//     required this.currentLevelIndex,
//     required this.allLevels,
//   });
//
//   @override
//   State<LiveCameraFitnessTracker> createState() =>
//       _LiveCameraFitnessTrackerState();
// }
//
// class _LiveCameraFitnessTrackerState extends State<LiveCameraFitnessTracker> {
//   dynamic controller;
//   bool isBusy = false;
//   late Size size;
//   late Timer _timer;
//   int _timeLeft = 0;
//   int _currentCount = 0;
//   bool _isExerciseComplete = false;
//   bool _exerciseStarted = false;
//
//   //TODO declare detector
//   late PoseDetector poseDetector;
//
//   @override
//   void initState() {
//     super.initState();
//     initializeCamera();
//     _timeLeft = widget.selectedLevel.durationInSeconds;
//     startTimer();
//   }
//
//   void startTimer() {
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (_timeLeft <= 0) {
//         if (_exerciseStarted) {
//           checkExerciseResult();
//         }
//         timer.cancel();
//       } else {
//         setState(() {
//           _timeLeft--;
//         });
//       }
//     });
//   }
//
//   void checkExerciseResult() {
//     setState(() {
//       _isExerciseComplete = true;
//     });
//
//     if (_currentCount >= widget.selectedLevel.targetCount) {
//       // Mark current level as completed
//       setState(() {
//         widget.selectedLevel.markAsCompleted();
//       });
//
//       // Show success dialog
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder:
//             (context) => AlertDialog(
//               title: Text('Level Complete! 🎉'),
//               content: Text(
//                 'You completed ${_currentCount} ${widget.exerciseDataModel.title.toLowerCase()}!',
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context); // Close dialog
//                     if (widget.currentLevelIndex + 1 < widget.allLevels.length) {
//                       // Go to next level
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => LiveCameraFitnessTracker(
//                             exerciseDataModel: widget.exerciseDataModel,
//                             selectedLevel: widget.allLevels[widget.currentLevelIndex + 1],
//                             currentLevelIndex: widget.currentLevelIndex + 1,
//                             allLevels: widget.allLevels,
//                           ),
//                         ),
//                       );
//                     } else {
//                       // If no more levels, go back to level selection
//                       Navigator.pop(context);
//                     }
//                   },
//                   child: Text('Next Level'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context); // Close dialog
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => LevelSelectionPage(
//                           exerciseDataModel: widget.exerciseDataModel,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Text('Close'),
//                 ),
//               ],
//             ),
//       );
//     } else {
//       // Show failure dialog
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder:
//             (context) => AlertDialog(
//               title: Text('Level Failed 😔'),
//               content: Text(
//                 'You completed ${_currentCount} out of ${widget.selectedLevel.targetCount} ${widget.exerciseDataModel.title.toLowerCase()}.',
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context); // Close dialog
//                     setState(() {
//                       _timeLeft = widget.selectedLevel.durationInSeconds;
//                       _currentCount = 0;
//                       _isExerciseComplete = false;
//                       _exerciseStarted = false;
//                     });
//                     // Restart the timer after resetting state
//                     startTimer();
//                   },
//                   child: Text('Try Again'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context); // Close dialog
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => LevelSelectionPage(
//                           exerciseDataModel: widget.exerciseDataModel,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Text('Close'),
//                 ),
//               ],
//             ),
//       );
//     }
//   }
//
//   //TODO code to initialize the camera feed
//   initializeCamera() async {
//     //TODO initialize detector
//     final option = PoseDetectorOptions(mode: PoseDetectionMode.stream);
//     poseDetector = PoseDetector(options: option);
//
//     controller = CameraController(
//       cameras[0],
//       ResolutionPreset.veryHigh,
//       imageFormatGroup:
//           Platform.isAndroid
//               ? ImageFormatGroup.nv21
//               : ImageFormatGroup.bgra8888,
//
//       // imageFormatGroup:
//       //     Platform.isAndroid
//       //         ? ImageFormatGroup.nv21
//       //         : ImageFormatGroup.bgra8888,
//     );
//     await controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       // controller.startImageStream(
//       //   (image) => {
//       //     if (!isBusy) {isBusy = true, img = image, doPoseEstimationOnFrame()},
//       //   },
//       // );
//       controller.startImageStream((image) {
//         if (!isBusy) {
//           isBusy = true;
//           img = image;
//           doPoseEstimationOnFrame();
//         }
//       });
//     });
//   }
//
//   //TODO pose detection on a frame
//   List<Pose> _scanResults = [];
//   CameraImage? img;
//
//   doPoseEstimationOnFrame() async {
//     if (!_exerciseStarted) {
//       isBusy = false;
//       return;
//     }
//
//     var inputImage = _inputImageFromCameraImage(img!);
//
//     if (inputImage == null) {
//       print('❌ InputImage is null — skipping frame');
//       setState(() {
//         isBusy = false;
//       });
//       return;
//     }
//
//     print('👉 Starting pose detection');
//
//     try {
//       final List<Pose> poses = await poseDetector.processImage(inputImage);
//       print('✅ Poses = ${poses.length.toString()}');
//       setState(() {
//         _scanResults = poses;
//         isBusy = false;
//       });
//       if (poses.length > 0) {
//         if (widget.exerciseDataModel.type == ExerciseType.pushUps) {
//           detectPushUp(poses.first.landmarks);
//         } else if (widget.exerciseDataModel.type == ExerciseType.squats) {
//           detectSquat(poses.first.landmarks);
//         } else if (widget.exerciseDataModel.type ==
//             ExerciseType.downwardDogPlank) {
//           detectPlankToDownwardDog(poses.first);
//         } else if (widget.exerciseDataModel.type == ExerciseType.jumpingJack) {
//           detectJumpingJack(poses.first);
//         } else if (widget.exerciseDataModel.type == ExerciseType.highKnees) {
//           detectHighKnees(poses.first.landmarks);
//         }
//       }
//     } catch (e) {
//       print('❌ Error in pose detection: $e');
//     }
//   }
//
//   //close all resources
//   @override
//   void dispose() {
//     _timer.cancel();
//     controller?.dispose();
//     poseDetector.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<Widget> stackChildren = [];
//     if (controller != null && controller.value.isInitialized) {
//       stackChildren.add(
//         SizedBox(
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           child: CameraPreview(controller),
//         ),
//       );
//
//       if (controller.value.previewSize != null) {
//         final previewSize = controller.value.previewSize!;
//         final isPortrait =
//             MediaQuery.of(context).size.height >
//             MediaQuery.of(context).size.width;
//         final painterSize =
//             isPortrait
//                 ? Size(previewSize.height, previewSize.width)
//                 : Size(previewSize.width, previewSize.height);
//         stackChildren.add(
//           SizedBox(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             child: CustomPaint(painter: PosePainter(_scanResults, painterSize)),
//           ),
//         );
//       }
//
//       if (!_exerciseStarted) {
//         stackChildren.add(
//           Center(
//             child: ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _exerciseStarted = true;
//                   _timeLeft = widget.selectedLevel.durationInSeconds;
//                   _currentCount = 0;
//                   startTimer();
//                 });
//               },
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
//                 backgroundColor: widget.exerciseDataModel.color,
//               ),
//               child: Text(
//                 'Start',
//                 style: TextStyle(fontSize: 24, color: Colors.white),
//               ),
//             ),
//           ),
//         );
//       }
//
//       if (_exerciseStarted) {
//         stackChildren.add(
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               height: 70,
//               width: 70,
//               margin: EdgeInsets.only(bottom: 20),
//               decoration: BoxDecoration(
//                 color: widget.exerciseDataModel.color,
//                 borderRadius: BorderRadius.circular(50),
//               ),
//               child: Center(
//                 child: Text(
//                   '$_currentCount',
//                   style: TextStyle(fontSize: 20, color: Colors.white),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }
//     }
//
//     if (_exerciseStarted) {
//       stackChildren.add(
//         Align(
//           alignment: Alignment.topCenter,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Timer container
//               Container(
//                 margin: EdgeInsets.only(top: 50),
//                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: widget.exerciseDataModel.color,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   'Time: $_timeLeft seconds',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//
//               Container(
//                 height: 70,
//                 width: MediaQuery.of(context).size.width,
//                 margin: EdgeInsets.only(left: 20, right: 20, top: 20),
//                 padding: EdgeInsets.all(5),
//                 decoration: BoxDecoration(
//                   color: widget.exerciseDataModel.color,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Center(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Text(
//                         '${widget.exerciseDataModel.title} - Level ${widget.selectedLevel.levelNumber}',
//                         style: TextStyle(fontSize: 20, color: Colors.white),
//                       ),
//                       Image(
//                         image: AssetImage(
//                           'assets/gif/${widget.exerciseDataModel.image}',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     print("Scan results length: ${_scanResults.length}");
//
//     return Scaffold(
//       body: Container(
//         margin: const EdgeInsets.only(top: 0),
//         color: Colors.black,
//         child: Stack(children: stackChildren),
//       ),
//     );
//   }
//
//   int pushUpCount = 0;
//   bool isLowered = false;
//   void detectPushUp(Map<PoseLandmarkType, PoseLandmark> landmarks) {
//     final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
//     final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
//     final leftElbow = landmarks[PoseLandmarkType.leftElbow];
//     final rightElbow = landmarks[PoseLandmarkType.rightElbow];
//     final leftWrist = landmarks[PoseLandmarkType.leftWrist];
//     final rightWrist = landmarks[PoseLandmarkType.rightWrist];
//     final leftHip = landmarks[PoseLandmarkType.leftHip];
//     final rightHip = landmarks[PoseLandmarkType.rightHip];
//     final leftKnee = landmarks[PoseLandmarkType.leftKnee];
//     final rightKnee = landmarks[PoseLandmarkType.rightKnee];
//
//     if (leftShoulder == null ||
//         rightShoulder == null ||
//         leftElbow == null ||
//         rightElbow == null ||
//         leftWrist == null ||
//         rightWrist == null ||
//         leftHip == null ||
//         rightHip == null) {
//       return; // Skip if any landmark is missing
//     }
//
//     // Calculate elbow angles
//     double leftElbowAngle = calculateAngle(leftShoulder, leftElbow, leftWrist);
//     double rightElbowAngle = calculateAngle(
//       rightShoulder,
//       rightElbow,
//       rightWrist,
//     );
//     double avgElbowAngle = (leftElbowAngle + rightElbowAngle) / 2;
//
//     // Calculate torso alignment (ensuring a straight plank)
//     double torsoAngle = calculateAngle(
//       leftShoulder,
//       leftHip,
//       leftKnee ?? rightKnee!,
//     );
//     bool inPlankPosition =
//         torsoAngle > 160 && torsoAngle < 180; // Slight flexibility
//
//     if (avgElbowAngle < 90 && inPlankPosition) {
//       // User is in the lowered push-up position
//       isLowered = true;
//     } else if (avgElbowAngle > 160 && isLowered && inPlankPosition) {
//       // User returns to the starting position
//       setState(() {
//         _currentCount++;
//       });
//       isLowered = false;
//     }
//   }
//
//   int squatCount = 0;
//   bool isSquatting = false;
//   void detectSquat(Map<PoseLandmarkType, PoseLandmark> landmarks) {
//     final leftHip = landmarks[PoseLandmarkType.leftHip];
//     final rightHip = landmarks[PoseLandmarkType.rightHip];
//     final leftKnee = landmarks[PoseLandmarkType.leftKnee];
//     final rightKnee = landmarks[PoseLandmarkType.rightKnee];
//     final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
//     final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
//     final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
//     final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
//
//     if (leftHip == null ||
//         rightHip == null ||
//         leftKnee == null ||
//         rightKnee == null ||
//         leftAnkle == null ||
//         rightAnkle == null ||
//         leftShoulder == null ||
//         rightShoulder == null) {
//       return; // Skip detection if any key landmark is missing
//     }
//
//     // Calculate angles
//     double leftKneeAngle = calculateAngle(leftHip, leftKnee, leftAnkle);
//     double rightKneeAngle = calculateAngle(rightHip, rightKnee, rightAnkle);
//     double avgKneeAngle = (leftKneeAngle + rightKneeAngle) / 2;
//
//     double hipY = (leftHip.y + rightHip.y) / 2;
//     double kneeY = (leftKnee.y + rightKnee.y) / 2;
//
//     bool deepSquat = avgKneeAngle < 90; // Ensuring squat is deep enough
//
//     if (deepSquat && hipY > kneeY) {
//       if (!isSquatting) {
//         isSquatting = true;
//       }
//     } else if (!deepSquat && isSquatting) {
//       setState(() {
//         _currentCount++;
//       });
//       isSquatting = false;
//     }
//   }
//
//   int plankToDownwardDogCount = 0;
//   bool isInDownwardDog = false;
//   void detectPlankToDownwardDog(Pose pose) {
//     final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
//     final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
//     final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
//     final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
//     final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
//     final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
//     final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
//     final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
//
//     if (leftHip == null ||
//         rightHip == null ||
//         leftShoulder == null ||
//         rightShoulder == null ||
//         leftAnkle == null ||
//         rightAnkle == null ||
//         leftWrist == null ||
//         rightWrist == null) {
//       return; // Skip detection if any key landmark is missing
//     }
//
//     // **Step 1: Detect Plank Position**
//     bool isPlank =
//         (leftHip.y - leftShoulder.y).abs() < 30 &&
//         (rightHip.y - rightShoulder.y).abs() < 30 &&
//         (leftHip.y - leftAnkle.y).abs() > 100 &&
//         (rightHip.y - rightAnkle.y).abs() > 100;
//
//     // **Step 2: Detect Downward Dog Position**
//     bool isDownwardDog =
//         (leftHip.y < leftShoulder.y - 50) &&
//         (rightHip.y < rightShoulder.y - 50) &&
//         (leftAnkle.y > leftHip.y) &&
//         (rightAnkle.y > rightHip.y);
//
//     // **Step 3: Count Repetitions**
//     if (isDownwardDog && !isInDownwardDog) {
//       isInDownwardDog = true;
//     } else if (isPlank && isInDownwardDog) {
//       setState(() {
//         _currentCount++;
//       });
//       isInDownwardDog = false;
//     }
//   }
//
//   int jumpingJackCount = 0;
//   bool isJumpingJack = false;
//   // bool isJumpingJackOpen = false;
//   void detectJumpingJack(Pose pose) {
//     final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
//     final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
//     final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
//     final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
//     final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
//     final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
//     final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
//     final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
//
//     if (leftAnkle == null ||
//         rightAnkle == null ||
//         leftHip == null ||
//         rightHip == null ||
//         leftShoulder == null ||
//         rightShoulder == null ||
//         leftWrist == null ||
//         rightWrist == null) {
//       return; // Skip detection if any landmark is missing
//     }
//
//     // Calculate distances
//     double legSpread = (rightAnkle.x - leftAnkle.x).abs();
//     double armHeight = (leftWrist.y + rightWrist.y) / 2; // Average wrist height
//     double hipHeight = (leftHip.y + rightHip.y) / 2; // Average hip height
//     double shoulderWidth = (rightShoulder.x - leftShoulder.x).abs();
//
//     // Define thresholds based on shoulder width
//     double legThreshold =
//         shoulderWidth * 1.2; // Legs should be ~1.2x shoulder width apart
//     double armThreshold =
//         hipHeight - shoulderWidth * 0.5; // Arms should be above shoulders
//
//     // Check if arms are raised and legs are spread
//     bool armsUp = armHeight < armThreshold;
//     bool legsApart = legSpread > legThreshold;
//
//     // Detect full jumping jack cycle
//     if (armsUp && legsApart && !isJumpingJack) {
//       isJumpingJack = true;
//     } else if (!armsUp && !legsApart && isJumpingJack) {
//       setState(() {
//         _currentCount++;
//       });
//       isJumpingJack = false;
//     }
//   }
//
//   int highKneeCount = 0;
//   bool isLeftKneeUp = false;
//   bool isRightKneeUp = false;
//
//   void detectHighKnees(Map<PoseLandmarkType, PoseLandmark> landmarks) {
//     final leftHip = landmarks[PoseLandmarkType.leftHip];
//     final rightHip = landmarks[PoseLandmarkType.rightHip];
//     final leftKnee = landmarks[PoseLandmarkType.leftKnee];
//     final rightKnee = landmarks[PoseLandmarkType.rightKnee];
//
//     if (leftHip == null ||
//         rightHip == null ||
//         leftKnee == null ||
//         rightKnee == null) {
//       return; // Skip detection if landmarks are missing
//     }
//
//     // LEFT KNEE HIGH CHECK
//     if (leftKnee.y < leftHip.y - 20) {
//       // small buffer to avoid flicker
//       if (!isLeftKneeUp) {
//         isLeftKneeUp = true;
//       }
//     } else if (isLeftKneeUp && leftKnee.y > leftHip.y + 20) {
//       // Knee was up, now came down → count one rep
//       setState(() {
//         _currentCount++;
//       });
//       isLeftKneeUp = false;
//     }
//
//     // RIGHT KNEE HIGH CHECK
//     if (rightKnee.y < rightHip.y - 20) {
//       if (!isRightKneeUp) {
//         isRightKneeUp = true;
//       }
//     } else if (isRightKneeUp && rightKnee.y > rightHip.y + 20) {
//       setState(() {
//         _currentCount++;
//       });
//       isRightKneeUp = false;
//     }
//   }
//
//   // Function to calculate angle between three points (shoulder, elbow, wrist)
//   double calculateAngle(
//     PoseLandmark shoulder,
//     PoseLandmark elbow,
//     PoseLandmark wrist,
//   ) {
//     double a = distance(elbow, wrist);
//     double b = distance(shoulder, elbow);
//     double c = distance(shoulder, wrist);
//
//     double angle = acos((b * b + a * a - c * c) / (2 * b * a)) * (180 / pi);
//     return angle;
//   }
//
//   // Helper function to calculate Euclidean distance
//   double distance(PoseLandmark p1, PoseLandmark p2) {
//     return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
//   }
//
//   final _orientations = {
//     DeviceOrientation.portraitUp: 0,
//     DeviceOrientation.landscapeLeft: 90,
//     DeviceOrientation.portraitDown: 180,
//     DeviceOrientation.landscapeRight: 270,
//   };
//
//   InputImage? _inputImageFromCameraImage(CameraImage image) {
//     try {
//       final WriteBuffer allBytes = WriteBuffer();
//       for (Plane plane in image.planes) {
//         allBytes.putUint8List(plane.bytes);
//       }
//       final bytes = allBytes.done().buffer.asUint8List();
//
//       final Size imageSize = Size(
//         image.width.toDouble(),
//         image.height.toDouble(),
//       );
//
//       final camera = cameras[0];
//       final sensorOrientation = camera.sensorOrientation;
//
//       // Handle rotation
//       final rotationCompensation =
//           _orientations[controller!.value.deviceOrientation];
//       if (rotationCompensation == null) return null;
//
//       final adjustedRotation =
//           camera.lensDirection == CameraLensDirection.front
//               ? (sensorOrientation + rotationCompensation) % 360
//               : (sensorOrientation - rotationCompensation + 360) % 360;
//
//       final InputImageRotation rotation =
//           InputImageRotationValue.fromRawValue(adjustedRotation)!;
//
//       // ML Kit only supports NV21 on Android
//       final format = InputImageFormat.nv21;
//
//       final metadata = InputImageMetadata(
//         size: imageSize,
//         rotation: rotation,
//         format: format,
//         bytesPerRow: image.planes[0].bytesPerRow,
//       );
//
//       return InputImage.fromBytes(bytes: bytes, metadata: metadata);
//     } catch (e) {
//       print("❌ Error converting image: $e");
//       return null;
//     }
//   }
//
//   //Show rectangles around detected objects
//   Widget buildResult() {
//     if (_scanResults == null ||
//         controller == null ||
//         !controller.value.isInitialized) {
//       return Text('');
//     }
//     final Size imageSize = Size(
//       controller.value.previewSize!.width,
//       controller.value.previewSize!.height,
//     );
//     CustomPainter painter = PosePainter(_scanResults, imageSize);
//     return CustomPaint(painter: painter);
//   }
// }
//
// class PosePainter extends CustomPainter {
//   PosePainter(this.poses, this.absoluteImageSize);
//
//   final List<Pose> poses;
//   final Size absoluteImageSize;
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final double scaleX = size.width / absoluteImageSize.width;
//     final double scaleY = size.height / absoluteImageSize.height;
//
//     final paint =
//         Paint()
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 4.0
//           ..color = Colors.green;
//
//     final leftPaint =
//         Paint()
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 3.0
//           ..color = Colors.yellow;
//
//     final rightPaint =
//         Paint()
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 3.0
//           ..color = Colors.blueAccent;
//
//     for (final pose in poses) {
//       pose.landmarks.forEach((_, landmark) {
//         canvas.drawCircle(
//           Offset(landmark.x * scaleX, landmark.y * scaleY),
//           1,
//           paint,
//         );
//       });
//
//       void paintLine(
//         PoseLandmarkType type1,
//         PoseLandmarkType type2,
//         Paint paintType,
//       ) {
//         final PoseLandmark joint1 = pose.landmarks[type1]!;
//         final PoseLandmark joint2 = pose.landmarks[type2]!;
//         canvas.drawLine(
//           Offset(joint1.x * scaleX, joint1.y * scaleY),
//           Offset(joint2.x * scaleX, joint2.y * scaleY),
//           paintType,
//         );
//       }
//
//       //Head & Face
//       paintLine(PoseLandmarkType.leftEar, PoseLandmarkType.leftEye, leftPaint);
//       paintLine(PoseLandmarkType.leftEye, PoseLandmarkType.rightEye, leftPaint);
//       paintLine(
//         PoseLandmarkType.rightEye,
//         PoseLandmarkType.rightEar,
//         rightPaint,
//       );
//       paintLine(PoseLandmarkType.nose, PoseLandmarkType.leftEye, leftPaint);
//       paintLine(PoseLandmarkType.nose, PoseLandmarkType.rightEye, rightPaint);
//
//       //Draw head-to-body connection
//       paintLine(
//         PoseLandmarkType.nose,
//         PoseLandmarkType.leftShoulder,
//         leftPaint,
//       );
//       paintLine(
//         PoseLandmarkType.nose,
//         PoseLandmarkType.rightShoulder,
//         rightPaint,
//       );
//
//       // Drawing arms
//       paintLine(
//         PoseLandmarkType.rightWrist,
//         PoseLandmarkType.rightElbow,
//         rightPaint,
//       );
//       paintLine(
//         PoseLandmarkType.rightElbow,
//         PoseLandmarkType.rightShoulder,
//         rightPaint,
//       );
//       paintLine(
//         PoseLandmarkType.leftWrist,
//         PoseLandmarkType.leftElbow,
//         leftPaint,
//       );
//       paintLine(
//         PoseLandmarkType.leftElbow,
//         PoseLandmarkType.leftShoulder,
//         leftPaint,
//       );
//
//       // Drawing body
//       paintLine(
//         PoseLandmarkType.rightShoulder,
//         PoseLandmarkType.rightHip,
//         rightPaint,
//       );
//       paintLine(
//         PoseLandmarkType.leftShoulder,
//         PoseLandmarkType.leftHip,
//         leftPaint,
//       );
//       paintLine(
//         PoseLandmarkType.rightHip,
//         PoseLandmarkType.leftHip,
//         rightPaint,
//       );
//       paintLine(
//         PoseLandmarkType.leftShoulder,
//         PoseLandmarkType.rightShoulder,
//         leftPaint,
//       );
//
//       // Drawing legs
//       paintLine(
//         PoseLandmarkType.rightHip,
//         PoseLandmarkType.rightKnee,
//         rightPaint,
//       );
//       paintLine(
//         PoseLandmarkType.rightKnee,
//         PoseLandmarkType.rightAnkle,
//         rightPaint,
//       );
//       paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
//       paintLine(
//         PoseLandmarkType.leftKnee,
//         PoseLandmarkType.leftAnkle,
//         leftPaint,
//       );
//
//       // Drawing Feet
//       paintLine(
//         PoseLandmarkType.leftAnkle,
//         PoseLandmarkType.leftHeel,
//         leftPaint,
//       );
//       paintLine(
//         PoseLandmarkType.leftHeel,
//         PoseLandmarkType.leftFootIndex,
//         leftPaint,
//       );
//
//       paintLine(
//         PoseLandmarkType.rightAnkle,
//         PoseLandmarkType.rightHeel,
//         rightPaint,
//       );
//       paintLine(
//         PoseLandmarkType.rightHeel,
//         PoseLandmarkType.rightFootIndex,
//         rightPaint,
//       );
//     }
//
//     print(
//       "Painting ${poses.length} poses, canvas size: $size, image size: $absoluteImageSize",
//     );
//   }
//
//   @override
//   bool shouldRepaint(PosePainter oldDelegate) {
//     return oldDelegate.absoluteImageSize != absoluteImageSize ||
//         oldDelegate.poses != poses;
//   }
// }
