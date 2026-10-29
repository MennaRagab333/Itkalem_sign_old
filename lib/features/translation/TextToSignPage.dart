import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TextToSignPage extends StatefulWidget {
  const TextToSignPage({super.key});

  @override
  State<TextToSignPage> createState() => _TextToSignPageState();
}

class _TextToSignPageState extends State<TextToSignPage> {
  bool isResultReady = false;
  final TextEditingController _textController = TextEditingController();
  VideoPlayerController? _videoController;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  double _playbackSpeed = 1.0;

  final Map<String, String> _signDictionary = {
    "شارع": "assets/videos/street.mp4",
    "شوارع": "assets/videos/street.mp4",
    "أرقام": "assets/videos/numbers.mp4",
    "ارقام": "assets/videos/numbers.mp4",
    "ساعة": "assets/videos/watch.mp4",
    "ساعه": "assets/videos/watch.mp4",
  };

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: "ar-EG",
          onResult: (val) => setState(() {
            _textController.text = val.recognizedWords;
            if (val.finalResult) _isListening = false;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _processTranslation() {
    String input = _textController.text.trim();
    if (_signDictionary.containsKey(input)) {
      _initVideo(_signDictionary[input]!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("عذراً، كلمة '$input' غير متوفرة حالياً"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _initVideo(String path) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.asset(path)
      ..initialize().then((_) {
        setState(() {
          isResultReady = true;
          _playbackSpeed = 1.0;
        });
        _videoController!.setLooping(false);
        _videoController!.play();
      });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isResultReady ? _buildResultView() : _buildInputView(),
    );
  }

  Widget _buildInputView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 20),
          Text(
            "تحويل النص أو الصوت إلى لغة إشارة",
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "أدخل النص أو سجل صوتك لمشاهدة رسوم لغة الإشارة",
            textDirection: TextDirection.rtl,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          const SizedBox(height: 30),
          Text(
            "أدخل النص:",
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _textController,
            maxLines: 4,
            textAlign: TextAlign.right,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: "اكتب شيئاً هنا...",
              hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              fillColor: Theme.of(context).cardColor,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "أو",
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _listen,
            icon: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: _isListening ? Colors.red : Theme.of(context).primaryColor
            ),
            label: Text(
              _isListening ? "جاري الاستماع..." : "تسجيل الصوت",
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).cardColor,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _processTranslation,
            icon: const Icon(Icons.auto_awesome),
            label: const Text("إنشاء فيديو الإشارة"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Container(
            height: 350,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  if (_videoController != null && _videoController!.value.isInitialized)
                    AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  _buildVideoControls(),
                ],
              ),
            ),
          ),
          if (_videoController != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                // تغيير لون شريط التقدم للأزرق (لون التطبيق)
                colors: VideoProgressColors(
                  playedColor: Theme.of(context).primaryColor,
                  bufferedColor: Colors.grey.shade300,
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "النص الأصلي",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "\"${_textController.text}\"",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        _videoController?.pause();
                        setState(() => isResultReady = false);
                      },
                      child: Text(
                        "مسح وإعادة المحاولة",
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PopupMenuButton<double>(
            initialValue: _playbackSpeed,
            icon: const Icon(Icons.speed, color: Colors.white),
            onSelected: (speed) {
              setState(() {
                _playbackSpeed = speed;
                _videoController?.setPlaybackSpeed(speed);
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0.5, child: Text("0.5x")),
              const PopupMenuItem(value: 1.0, child: Text("1.0x")),
              const PopupMenuItem(value: 2.0, child: Text("2.0x")),
            ],
          ),
          IconButton(
            icon: Icon(
              (_videoController?.value.isPlaying ?? false)
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              color: Colors.white,
              size: 40,
            ),
            onPressed: () {
              setState(() {
                _videoController!.value.isPlaying
                    ? _videoController?.pause()
                    : _videoController?.play();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.replay, color: Colors.white),
            onPressed: () {
              _videoController?.seekTo(Duration.zero);
              _videoController?.play();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}