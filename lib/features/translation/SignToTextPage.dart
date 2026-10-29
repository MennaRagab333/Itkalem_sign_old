import 'dart:ui';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class SignToTextPage extends StatefulWidget {
  const SignToTextPage({super.key});

  @override
  State<SignToTextPage> createState() => _SignToTextPageState();
}

class _SignToTextPageState extends State<SignToTextPage> {
  final ImagePicker _picker = ImagePicker();
  final FlutterTts _flutterTts = FlutterTts();
  CameraController? _cameraController;

  String _statusMessage = "بانتظار الترجمة...";
  bool _isProcessing = false;

  final String sondosApiUrl = "https://sondosm-arabic-sign-language-api.hf.space/predict";
  final String omarApiUrl = "https://omaramer155-itkalem-api.hf.space/predict";

  final Map<String, String> _alphabetTranslation = {
    "Alef": "أ", "Beh": "ب", "Teh": "ت", "Theh": "ث", "Jeem": "ج",
    "Hah": "ح", "Khah": "خ", "Dal": "د", "Thal": "ذ", "Reh": "ر",
    "Zain": "ز", "Seen": "س", "Sheen": "ش", "Sad": "ص", "Dad": "ض",
    "Tah": "ط", "Zah": "ظ", "Ain": "ع", "Ghain": "غ", "Feh": "ف",
    "Qaf": "ق", "Kaf": "ك", "Lam": "ل", "Meem": "م", "Noon": "ن",
    "Heh": "هـ", "Waw": "و", "Yeh": "ي", "Laa": "لا", "Teh_Marbuta": "ة",
    "0": "٠", "1": "١", "2": "٢", "3": "٣", "4": "٤",
    "5": "٥", "6": "٦", "7": "٧", "8": "٨", "9": "٩",  "10": "١٠"
  };

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  String _translateAlphabet(String englishResult) {
    return _alphabetTranslation[englishResult] ?? englishResult;
  }

  Future<void> _uploadToSondos(File imageFile) async {
    setState(() { _isProcessing = true; _statusMessage = "جاري تحليل الحرف..."; });
    try {
      var request = http.MultipartRequest('POST', Uri.parse(sondosApiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String engResult = data['prediction'] ?? data['label'] ?? "";
        setState(() {
          _statusMessage = _translateAlphabet(engResult);
        });
        // _speak();
      }
    } catch (e) {
      setState(() => _statusMessage = "خطأ في الاتصال");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _uploadToOmar(File videoFile) async {
    setState(() { _isProcessing = true; _statusMessage = "جاري تحليل الحركة..."; });
    try {
      var request = http.MultipartRequest('POST', Uri.parse(omarApiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));
      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['prediction'] != null) {
          setState(() {
            _statusMessage = data['prediction'].toString();
          });
          // _speak();
        } else {
          setState(() => _statusMessage = "لم يتم التعرف");
        }
      } else {
        setState(() => _statusMessage = "فشل التحليل: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _statusMessage = "خطأ في الاتصال بالسيرفر");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) _uploadToSondos(File(image.path));
  }

  Future<void> _recordVideo() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
      setState(() {});
    }
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    await _initCamera();
    if (video != null) _uploadToOmar(File(video.path));
  }

  Future<void> _pickVideoFromGallery() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) _uploadToOmar(File(video.path));
  }

  // Future<void> _speak() async {
  //   if (_statusMessage.isEmpty) return;
  //
  //   bool isEnglish = RegExp(r'^[a-zA-Z0-9\s.,!?]+$').hasMatch(_statusMessage);
  //
  //   try {
  //     await _flutterTts.stop();
  //     await _flutterTts.setLanguage(isEnglish ? "en-US" : "ar-SA");
  //     await _flutterTts.setSpeechRate(0.5);
  //     await _flutterTts.setVolume(1.0);
  //     await _flutterTts.setPitch(1.0);
  //
  //     var result = await _flutterTts.speak(_statusMessage);
  //     if (result == 0) {
  //       print("TTS Failed to start");
  //     }
  //   } catch (e) {
  //     print("Error in TTS: $e");
  //   }
  // }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _statusMessage));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم نسخ النص")));
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: _cameraController != null && _cameraController!.value.isInitialized
                            ? CameraPreview(_cameraController!)
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    if (_isProcessing)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: const CircularProgressIndicator(color: Colors.white),
                      ),
                    Positioned(
                      bottom: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _circleAction(Icons.image, Colors.white24, 55, _pickImage),
                          const SizedBox(width: 15),
                          _circleAction(Icons.videocam, Theme.of(context).primaryColor, 85, _recordVideo, iconSize: 40),
                          const SizedBox(width: 15),
                          _circleAction(Icons.video_library, Colors.white24, 55, _pickVideoFromGallery),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(25)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(onPressed: _copyToClipboard, icon: const Icon(Icons.copy)),
                          const SizedBox(width: 18),
                          // IconButton(
                          //     onPressed: _speak,
                          //     icon: const Icon(Icons.volume_up, size: 28)
                          // ),
                        ],
                      ),
                      Text("الترجمة الآلية", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Text(_statusMessage, textAlign: TextAlign.right, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleAction(IconData icon, Color bg, double size, VoidCallback action, {double iconSize = 28}) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}