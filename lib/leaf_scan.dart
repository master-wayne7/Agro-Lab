// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names
import 'dart:io';
import 'package:agrolab/home_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'encyclopedia_screen.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image/image.dart' as img;

import 'app_info_screen.dart';
import 'ai_chat_screen.dart';

class LeafScan extends StatefulWidget {
  final String modelName;
  //parameters passed from home screen
  const LeafScan({super.key, required this.modelName});

  @override
  // ignore: no_logic_in_create_state
  State<LeafScan> createState() => _LeafScanState(modelName);
}

class _LeafScanState extends State<LeafScan> {
  String modelName;
  _LeafScanState(this.modelName);
  Interpreter? _interpreter;
  List<String>? _labels;

  File? pickedImage;
  bool isButtonPressedCamera = false;
  bool isButtonPressedGallery = false;
  Color backgroundColor = Color(0xffe9edf1);
  Color secondaryColor = Color(0xffe1e6ec);
  Color accentColor = Color(0xff2d5765);

  List? results;
  String confidence = "";
  String name = "";
  String crop_name = "";
  String disease_name = "";
  String disease_url = "";
  bool result_visibility = false;
  String disease_severity = "";

  String ModelPathSelector() {
    // Using a map for cleaner and more maintainable code
    final Map<String, String> modelPaths = {
      'apple': 'assets/Apple',
      'bellpepper': 'assets/BellPepper',
      'cherry': 'assets/Cherry',
      'cotton': 'assets/Cotton',
      'coffee': 'assets/Coffee',
      'corn': 'assets/Corn',
      'grape': 'assets/Grape',
      'groundnut': 'assets/Groundnut',
      'peach': 'assets/Peach',
      'potato': 'assets/Potato',
      'rice': 'assets/Rice',
      'tomato': 'assets/Tomato',
      'soyabean': 'assets/SoyaBean',
      'sugarcane': 'assets/SugarCane',
      'wheat': 'assets/Wheat',
    };

    return modelPaths[modelName.toLowerCase()] ?? '';
  }

  Future getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        return;
      } else {
        final imageTemporary = File(image.path);
        setState(() {
          pickedImage = imageTemporary;
          applyModelOnImage(pickedImage!);
          result_visibility = true;
          isButtonPressedCamera = false;
          isButtonPressedGallery = false;
        });
      }
    } on PlatformException {
      // debugPrint("Failed to pick image: $e");
    }
  }

  void buttonPressedCamera() {
    setState(() {
      isButtonPressedCamera = !isButtonPressedCamera;
      getImage(ImageSource.camera);
    });
  }

  void buttonPressedGallery() {
    setState(() {
      isButtonPressedGallery = !isButtonPressedGallery;
      getImage(ImageSource.gallery);
    });
  }

  @override
  void initState() {
    super.initState();
    // debugPrint(modelName);
    initTflite();
  }

  @override
  void dispose() {
    super.dispose();
    closeModel();
  }

  Future<void> initTflite() async {
    try {
      await loadModel();
      await loadLabels();
      setState(() {});
    } catch (e) {
      debugPrint('Error initializing TFLite: $e');
    }
  }

  void printModelInfo() {
    if (_interpreter == null) {
      debugPrint('Interpreter is null');
      return;
    }

    try {
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);

      debugPrint('Input tensor shape: ${inputTensor.shape}');
      debugPrint('Input tensor type: ${inputTensor.type}');
      debugPrint('Output tensor shape: ${outputTensor.shape}');
      debugPrint('Output tensor type: ${outputTensor.type}');
      debugPrint('Number of labels: ${_labels?.length}');
    } catch (e) {
      debugPrint('Error getting model info: $e');
    }
  }

  Future<void> loadModel() async {
    String modelPath = ModelPathSelector();
    try {
      final interpreterOptions = InterpreterOptions();

      _interpreter = await Interpreter.fromAsset(
        '$modelPath/model_unquant.tflite',
        options: interpreterOptions,
      );

      debugPrint("Model loaded successfully");
      printModelInfo(); // Add this line
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  Future<void> loadLabels() async {
    String modelPath = ModelPathSelector();
    try {
      final labelData = await rootBundle.loadString('$modelPath/labels.txt');
      _labels = labelData.split('\n');
    } catch (e) {
      debugPrint('Error loading labels: $e');
    }
  }

  Future<void> applyModelOnImage(File file) async {
    if (_interpreter == null) return;

    try {
      // Read and process image
      final imageData = file.readAsBytesSync();
      final image = img.decodeImage(imageData);
      if (image == null) return;

      // Resize image to match model input size
      final resizedImage = img.copyResize(image, width: 224, height: 224);

      // Convert image to float32 buffer
      var buffer = Float32List(1 * 224 * 224 * 3);
      var index = 0;

      for (var y = 0; y < 224; y++) {
        for (var x = 0; x < 224; x++) {
          var pixel = resizedImage.getPixel(x, y);
          buffer[index++] = (pixel.r.toDouble() - 127.5) / 127.5;
          buffer[index++] = (pixel.g.toDouble() - 127.5) / 127.5;
          buffer[index++] = (pixel.b.toDouble() - 127.5) / 127.5;
        }
      }

      // Get input and output shapes from the interpreter
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      debugPrint("Input shape: $inputShape");
      debugPrint("Output shape: $outputShape");

      // Reshape input tensor
      var input = buffer.reshape(inputShape);

      // Create output tensor with correct shape
      var output = List.filled(outputShape.reduce((a, b) => a * b), 0.0).reshape(outputShape);

      // Run inference
      _interpreter!.run(input, output);

      // Process results
      var results = output[0] as List<double>;
      var maxScore = 0.0;
      var maxIndex = 0;

      for (var i = 0; i < results.length; i++) {
        if (results[i] > maxScore) {
          maxScore = results[i];
          maxIndex = i;
        }
      }

      setState(() {
        if (_labels != null && maxIndex < _labels!.length) {
          name = _labels![maxIndex];
          confidence = maxScore.toStringAsFixed(2);
          split_model_result();

          // Calculate disease severity based on confidence score
          calculateDiseaseSeverity(double.parse(confidence));
        }
      });
    } catch (e) {
      debugPrint('Error in applyModelOnImage: $e');
    }
  }

  void split_model_result() {
    List temp = name.split(' ');
    crop_name = temp[0];
    temp.removeAt(0);

    // Check if the first word of the disease is the same as the crop name
    // This handles cases like "Apple Apple Scab" -> should be just "Apple Scab"
    if (temp.isNotEmpty && temp[0].toLowerCase() == modelName.toLowerCase()) {
      temp.removeAt(0);
    }

    disease_name = temp.join(' ');

    // If disease name is empty, it might be a healthy plant
    if (disease_name.isEmpty) {
      disease_name = "healthy";
    }

    // debugPrint("Crop: $crop_name, Disease: $disease_name");
  }

  void calculateDiseaseSeverity(double confidenceScore) {
    if (disease_name.toLowerCase() == "healthy") {
      disease_severity = "0%";
      return;
    }

    // Convert confidence score to severity percentage
    // This is a simple estimation - you might want to refine this logic
    double severityPercentage = confidenceScore * 100;

    // Adjust severity based on confidence thresholds
    if (confidenceScore > 0.8) {
      severityPercentage = 75 + (confidenceScore - 0.8) * 125; // 75%-100% severity
    } else if (confidenceScore > 0.6) {
      severityPercentage = 50 + (confidenceScore - 0.6) * 125; // 50%-75% severity
    } else if (confidenceScore > 0.4) {
      severityPercentage = 25 + (confidenceScore - 0.4) * 125; // 25%-50% severity
    } else {
      severityPercentage = confidenceScore * 62.5; // 0%-25% severity
    }

    // Cap at 100%
    if (severityPercentage > 100) severityPercentage = 100;

    disease_severity = "${severityPercentage.toStringAsFixed(0)}%";
  }

  void closeModel() async {
    _interpreter?.close();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: backgroundColor,
      systemNavigationBarColor: secondaryColor,
    ));

    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: CurvedNavigationBar(
        onTap: (index) {
          //todo implement transition to other screens
          // debugPrint(index);
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Encyclopedia(),
              ),
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppInfoScreen(),
              ),
            );
          }
        },
        index: 1,
        backgroundColor: backgroundColor,
        color: secondaryColor,
        buttonBackgroundColor: backgroundColor,
        animationDuration: Duration(
          milliseconds: 300,
        ),
        items: [
          NeumorphicIcon(
            Icons.menu_book_rounded,
            style: NeumorphicStyle(
              color: accentColor,
              intensity: 20,
            ),
          ),
          NeumorphicIcon(
            Icons.home_rounded,
            style: NeumorphicStyle(
              color: accentColor,
              intensity: 20,
            ),
          ),
          NeumorphicIcon(
            Icons.info_rounded,
            style: NeumorphicStyle(
              color: accentColor,
              intensity: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/agrolabicon.svg',
                          width: 45,
                          height: 45,
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "AgroLab",
                            style: TextStyle(
                              fontFamily: 'intan',
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      'assets/tensorflow-icontext.svg',
                      width: 40,
                      height: 40,
                    ),
                  )
                ],
              ),
              Center(
                child: Neumorphic(
                  style: NeumorphicStyle(
                    border: NeumorphicBorder(
                      color: accentColor,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: pickedImage != null
                        ? Image.file(
                            pickedImage!,
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                          )
                        : LottieBuilder.asset(
                            'assets/plant.json',
                            width: 300,
                            height: 300,
                          ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    NeumorphicButton(
                      tooltip: 'Camera',
                      style: NeumorphicStyle(
                        color: Color(0xffe9edf1),
                      ),
                      pressed: isButtonPressedCamera,
                      onPressed: buttonPressedCamera,
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_rounded,
                            size: 64,
                            color: accentColor,
                          ),
                          Text(
                            'Camera',
                            style: TextStyle(
                              fontFamily: 'intan',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                    NeumorphicButton(
                      tooltip: 'Gallery',
                      style: NeumorphicStyle(
                        color: Color(0xffe9edf1),
                      ),
                      pressed: isButtonPressedGallery,
                      onPressed: buttonPressedGallery,
                      child: Column(
                        children: [
                          Icon(
                            Icons.image_rounded,
                            size: 64,
                            color: accentColor,
                          ),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              fontFamily: 'intan',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: !result_visibility,
                child: Neumorphic(
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                  ),
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                        child: Row(
                          children: [
                            NeumorphicIcon(
                              Icons.camera_alt_rounded,
                              style: NeumorphicStyle(
                                color: accentColor,
                              ),
                              size: 20,
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: 5,
                              ),
                              child: Text(
                                "Select a plant leaf image to view the results",
                                style: TextStyle(
                                  fontFamily: 'inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: Row(
                          children: [
                            NeumorphicIcon(
                              Icons.light_mode_rounded,
                              style: NeumorphicStyle(
                                color: accentColor,
                              ),
                              size: 20,
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: 5,
                              ),
                              child: Text(
                                'The image should be well lit and clear',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NeumorphicIcon(
                              Icons.hide_image_rounded,
                              style: NeumorphicStyle(
                                color: accentColor,
                              ),
                              size: 20,
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(5, 0, 10, 0),
                                child: Text(
                                  "Images other than specific plant leaves may give incorrect results",
                                  softWrap: true,
                                  maxLines: 10,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                  // textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: result_visibility,
                child: GestureDetector(
                  onTap: () async {
                    if (disease_name.toLowerCase() != "healthy") {
                      disease_url = "https://www.google.com/search?q=$modelName+${disease_name.replaceAll(' ', '+')}";
                      Uri url = Uri.parse(disease_url);
                      await launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
                    } else {
                      disease_url = "https://www.google.com/search?q=$modelName+plant+care+tips";
                      Uri url = Uri.parse(disease_url);
                      await launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
                    }
                  },
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      // color: backgroundColor,
                      // color: Colors.red.shade700,
                      lightSource: LightSource.topLeft,
                      intensity: 20,
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                    ),
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(50, 10, 50, 20),
                              child: NeumorphicText(
                                disease_name,
                                style: NeumorphicStyle(
                                  color: Colors.black,
                                  // color: Colors.green.shade800,
                                ),
                                textStyle: NeumorphicTextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Confidence : $confidence',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              disease_name.toLowerCase() != "healthy"
                                  ? Text(
                                      'Severity : $disease_severity',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: disease_severity.startsWith("7") || disease_severity.startsWith("8") || disease_severity.startsWith("9")
                                            ? Colors.red.shade800
                                            : disease_severity.startsWith("5") || disease_severity.startsWith("6")
                                                ? Colors.orange.shade800
                                                : Colors.green.shade800,
                                      ),
                                      textAlign: TextAlign.justify,
                                    )
                                  : Container(),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  NeumorphicIcon(
                                    Icons.info_rounded,
                                    style: NeumorphicStyle(
                                      color: accentColor,
                                    ),
                                    size: 15,
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        left: 5,
                                      ),
                                      child: Text(
                                        disease_name.toLowerCase() != "healthy" ? 'Tap on this card to read more about this disease' : 'Tap on this card for $modelName plant care tips',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.justify,
                                        softWrap: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Add AI Chat button only for infected plants
                              disease_name.toLowerCase() != "healthy"
                                  ? Column(
                                      children: [
                                        SizedBox(height: 15),
                                        NeumorphicButton(
                                          style: NeumorphicStyle(
                                            color: accentColor,
                                            depth: 2,
                                            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AIChatScreen(
                                                  cropName: modelName,
                                                  diseaseName: disease_name,
                                                  severity: disease_severity,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.smart_toy_rounded,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  "Ask AI for treatment",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
