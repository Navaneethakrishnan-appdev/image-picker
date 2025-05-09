import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ImagePicker imagePicker;
  File? _image;
  late PoseDetector poseDetector;
  var image;
  List<Pose> poses = [];
  String poseMessage = '';

  //TODO declare detector
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    //TODO initialize detector
    final options = PoseDetectorOptions(
      model: PoseDetectionModel.accurate,
      mode: PoseDetectionMode.single,
    );
    poseDetector = PoseDetector(options: options);
  }

  @override
  void dispose() {
    super.dispose();
  }

  //TODO capture image using camera
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      doPoseDetection();
      //
      await poseDetectionMessage();
    }
  }

  //TODO choose image using gallery
  _imgFromGallery() async {
    XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      doPoseDetection();
      //
      await poseDetectionMessage();
    }
  }

  //TODO pose detection code here
  doPoseDetection() async {
    drawPose();
    InputImage inputImage = InputImage.fromFile(_image!);
    poses = await poseDetector.processImage(inputImage);
    setState(() {
      poses;
    });

    for (Pose pose in poses) {
      // to access all landmarks
      pose.landmarks.forEach((_, landmark) {
        final type = landmark.type;
        final x = landmark.x;
        final y = landmark.y;
        print(
          "Landmark=>=>=>" +
              landmark.type.name +
              "  " +
              landmark.x.toString() +
              "  " +
              landmark.y.toString(),
        );
      });

      // to access specific landmarks
      final landmark = pose.landmarks[PoseLandmarkType.nose];
    }
  }

  drawPose() async {
    var bytes = await _image!.readAsBytes();
    image = await decodeImageFromList(bytes);
    setState(() {
      image;
    });
  }

  Future<void> poseDetectionMessage() async {
    await drawPose(); // Ensure pose drawing is complete

    final inputImage = InputImage.fromFile(_image!);
    poses = await poseDetector.processImage(inputImage);

    String message = 'Unknown Pose or Form Improper';

    if (poses.isNotEmpty) {
      final pose = poses[0];
      final landmarks = pose.landmarks;

      // Safe null checks for landmarks
      final lw = landmarks[PoseLandmarkType.leftWrist];
      final rw = landmarks[PoseLandmarkType.rightWrist];
      final ls = landmarks[PoseLandmarkType.leftShoulder];
      final rs = landmarks[PoseLandmarkType.rightShoulder];
      final lh = landmarks[PoseLandmarkType.leftHip];
      final rh = landmarks[PoseLandmarkType.rightHip];
      final lk = landmarks[PoseLandmarkType.leftKnee];
      final rk = landmarks[PoseLandmarkType.rightKnee];
      final la = landmarks[PoseLandmarkType.leftAnkle];
      final ra = landmarks[PoseLandmarkType.rightAnkle];
      final nose = landmarks[PoseLandmarkType.nose];

      final points = [lw, rw, ls, rs, lh, rh, lk, rk, la, ra];
      if (points.every((p) => p != null)) {
        final leftWrist = lw!;
        final rightWrist = rw!;
        final leftShoulder = ls!;
        final rightShoulder = rs!;
        final leftHip = lh!;
        final rightHip = rh!;
        final leftKnee = lk!;
        final rightKnee = rk!;
        final leftAnkle = la!;
        final rightAnkle = ra!;

        // 🌳 Vrksasana (Tree Pose)
        bool oneLegUp =
            ((leftAnkle.y - leftKnee.y).abs() < 40 && leftKnee.y < leftHip.y) ||
            ((rightAnkle.y - rightKnee.y).abs() < 40 &&
                rightKnee.y < rightHip.y);
        bool handsTogetherAboveHead =
            (leftWrist.y < leftShoulder.y &&
                rightWrist.y < rightShoulder.y &&
                (leftWrist.x - rightWrist.x).abs() < 40);
        if (oneLegUp) {
          message =
              handsTogetherAboveHead
                  ? 'Vrksasana (Tree Pose): Proper Form'
                  : 'Vrksasana (Tree Pose): Improper Form – Hands not together above head';
        }
        // 🏔️ Tadasana (Mountain Pose)
        else if (leftWrist.y > leftHip.y &&
            rightWrist.y > rightHip.y &&
            leftShoulder.y < leftHip.y &&
            rightShoulder.y < rightHip.y) {
          message = 'Tadasana (Mountain Pose): Proper Form';
        }
        // ⚔️ Virabhadrasana II (Warrior II)
        else if (_isArmHorizontal(leftShoulder, leftWrist) &&
            _isArmHorizontal(rightShoulder, rightWrist)) {
          message =
              _legsApart(leftHip, rightHip, leftAnkle, rightAnkle)
                  ? 'Virabhadrasana II (Warrior II): Proper Form'
                  : 'Virabhadrasana II (Warrior II): Improper Form – Legs not wide enough';
        }
        // 🙌 Urdhva Hastasana (Raised Hands Pose)
        else if (leftWrist.y < leftShoulder.y &&
            rightWrist.y < rightShoulder.y &&
            (leftWrist.x - rightWrist.x).abs() < 60) {
          bool upright =
              (leftShoulder.x - leftHip.x).abs() < 30 &&
              (rightShoulder.x - rightHip.x).abs() < 30;
          message =
              upright
                  ? 'Urdhva Hastasana (Raised Hands Pose): Proper Form'
                  : 'Urdhva Hastasana (Raised Hands Pose): Improper Form – Keep body straight';
        }
        // 🐶 Adho Mukha Svanasana (Downward-Facing Dog)
        else if (hipAboveHandsAndFeet(
          leftHip,
          rightHip,
          leftWrist,
          rightWrist,
          leftAnkle,
          rightAnkle,
        )) {
          message = 'Adho Mukha Svanasana (Downward Dog): Proper Form';
        }
        // 🔺 Trikonasana (Triangle Pose)
        else if (_isArmVertical(leftShoulder, leftWrist) &&
            _isArmVertical(rightShoulder, rightWrist) &&
            _legsApart(leftHip, rightHip, leftAnkle, rightAnkle)) {
          message = 'Trikonasana (Triangle Pose): Proper Form';
        }
        // 🧘 Virabhadrasana I (Warrior I)
        else if (_isArmRaised(leftWrist, leftShoulder) &&
            _isArmRaised(rightWrist, rightShoulder) &&
            _oneKneeBent(leftKnee, rightKnee, leftHip, rightHip)) {
          message = 'Virabhadrasana I (Warrior I): Proper Form';
        }
        // 🐍 Bhujangasana (Cobra Pose)
        else if (_isUpperBodyLifted(
              leftShoulder,
              rightShoulder,
              leftHip,
              rightHip,
            ) &&
            leftKnee.y > leftHip.y &&
            rightKnee.y > rightHip.y) {
          message = 'Bhujangasana (Cobra Pose): Proper Form';
        }
        // 🙇 Balasana (Child Pose)
        else if (nose != null &&
            leftWrist.y > leftShoulder.y &&
            rightWrist.y > rightShoulder.y &&
            nose.y < leftHip.y &&
            leftAnkle.y < leftHip.y) {
          message = 'Balasana (Child Pose): Proper Form';
        }
        // 🏋️‍♂️ Setu Bandhasana (Bridge Pose) - New Pose
        else if (leftHip.y > leftKnee.y &&
            rightHip.y > rightKnee.y &&
            leftAnkle.y > leftKnee.y &&
            rightAnkle.y > rightKnee.y &&
            leftShoulder.y < leftHip.y &&
            rightShoulder.y < rightHip.y) {
          message = 'Setu Bandhasana (Bridge Pose): Proper Form';
        }
      }
    }

    setState(() {
      poseMessage = message;
    });
  }

  // Example helper functions (if not already defined)
  bool _isArmHorizontal(PoseLandmark shoulder, PoseLandmark wrist) {
    return (shoulder.y - wrist.y).abs() <
        50; // Example threshold for horizontal arm
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //TODO display image
          Container(
            margin: const EdgeInsets.only(top: 100),
            child: Container(
              child:
                  image != null
                      ? Center(
                        child: FittedBox(
                          child: SizedBox(
                            width: image.width.toDouble(),
                            height: image.width.toDouble(),
                            child: CustomPaint(
                              painter: posePainter(image, poses),
                            ),
                          ),
                        ),

                        // Image.file(
                        //   _image!,
                        //   height: MediaQuery.of(context).size.height - 300,
                        // ),
                      )
                      : SizedBox(
                        height: MediaQuery.of(context).size.height - 300,
                        child: Image.asset('assets/images/bg.jpg'),
                      ),
            ),
          ),

          // Expanded(
          //   child: Container(
          //     height: 100,
          //     width: 500,
          //     decoration: BoxDecoration(color: Colors.white),
          //     child: Center(
          //       child: Text(
          //         poseMessage,
          //         style: TextStyle(color: Colors.black, fontSize: 20),
          //       ),
          //     ),
          //   ),
          // ),
          Visibility(
            visible:
                _image != null, // Message box visible only after image upload
            child: Container(
              height: 100, // Set a specific smaller height for the message box
              width: 350, // Adjusted width to make the box smaller
              margin: EdgeInsets.all(
                8,
              ), // Reduced margin for a more compact look
              decoration: BoxDecoration(
                color: Colors.black26,
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
                  color: Colors.white, // Border color
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          16, // Smaller font size for a more compact message
                      fontWeight: FontWeight.w500, // Lighter boldness
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          //TODO bottom section
          Padding(
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.photo, color: Colors.black, size: 30),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.limeAccent,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 50,
                        width: 50,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    _imgFromCamera();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.camera, color: Colors.black, size: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class posePainter extends CustomPainter {
  var image;
  List<Pose> poses;
  posePainter(this.image, this.poses);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    canvas.drawImage(image, Offset.zero, Paint());

    Paint paint = Paint();
    paint.color = Colors.green;
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 4;

    Paint leftPaint = Paint();
    leftPaint.color = Colors.yellow;
    leftPaint.style = PaintingStyle.fill;
    leftPaint.strokeWidth = 2;

    Paint rightPaint = Paint();
    rightPaint.color = Colors.purple;
    rightPaint.style = PaintingStyle.fill;
    rightPaint.strokeWidth = 2;

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

// File? image;
// late ImagePicker imagePicker;
//
// @override
// void initState() {
//   // TODO: implement initState
//   super.initState();
//   imagePicker = ImagePicker();
// }
//
// chooseImage() async {
//   XFile? selectedImage = await imagePicker.pickImage(
//     source: ImageSource.gallery,
//   );
//   if (selectedImage != null) {
//     image = File(selectedImage.path);
//     setState(() {
//       image;
//     });
//   }
// }
//
// captureImage() async {
//   XFile? selectedImage = await imagePicker.pickImage(
//     source: ImageSource.camera,
//   );
//   if (selectedImage != null) {
//     image = File(selectedImage.path);
//     setState(() {
//       image;
//     });
//   }
// }

// appBar: AppBar(
//   backgroundColor: Colors.green,
//   title: Text('Home', style: TextStyle(color: Colors.white)),
// ),
// body: Center(
//   child: Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Container(
//         height: 350,
//         width: 250,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2), // shadow color
//               spreadRadius: 2, // how much the shadow spreads
//               blurRadius: 10, // softness of the shadow
//               offset: Offset(4, 4), // x and y offset
//             ),
//           ],
//         ),
//         child:
//             image == null
//                 ? Icon(Icons.image_outlined, size: 150)
//                 : Image.file(image!, fit: BoxFit.cover),
//       ),
//       SizedBox(height: 50),
//       ElevatedButton(
//         onPressed: () {
//           chooseImage();
//         },
//         onLongPress: () {
//           captureImage();
//         },
//         style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//         child: Text(
//           'Choose/Capture',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//     ],
//   ),
// ),
