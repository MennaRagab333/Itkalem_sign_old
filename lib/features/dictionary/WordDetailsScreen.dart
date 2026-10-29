import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';

class WordDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> wordData;

  const WordDetailsScreen({super.key, required this.wordData});

  @override
  State<WordDetailsScreen> createState() => _WordDetailsScreenState();
}

class _WordDetailsScreenState extends State<WordDetailsScreen> {
  late VideoPlayerController _controller;
  bool _isError = false;
  double _currentSpeed = 1.0;
  final ImagePicker _picker = ImagePicker();
  final String baseUrl = "https://itkalemsign.runasp.net";

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    String rawPath = widget.wordData['videoUrl'] ?? widget.wordData['imageUrl'] ?? '';
    String fullUrl = rawPath.startsWith('http') ? rawPath : "$baseUrl$rawPath";

    _controller = VideoPlayerController.networkUrl(Uri.parse(fullUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
          _controller.setLooping(false);
        }
      }).catchError((error) {
        if (mounted) {
          setState(() => _isError = true);
        }
      });

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    await _picker.pickVideo(source: ImageSource.camera);
  }

  void _toggleSpeed() {
    setState(() {
      if (_currentSpeed == 1.0) _currentSpeed = 1.5;
      else if (_currentSpeed == 1.5) _currentSpeed = 2.0;
      else _currentSpeed = 1.0;
      _controller.setPlaybackSpeed(_currentSpeed);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color appPrimaryColor = theme.primaryColor;
    final Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final bool isFinished = _controller.value.isInitialized &&
        (_controller.value.position >= _controller.value.duration);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.wordData['word'] ?? '',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                height: 380,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: _isError
                      ? _buildErrorWidget(textColor)
                      : _controller.value.isInitialized
                      ? Stack(
                    fit: StackFit.expand,
                    children: [
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: _buildProgressBar(appPrimaryColor),
                      ),
                    ],
                  )
                      : Center(child: CircularProgressIndicator(color: appPrimaryColor)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIconControl(Icons.replay, "إعادة", textColor, () {
                          _controller.seekTo(Duration.zero);
                          _controller.play();
                        }),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isFinished) {
                                _controller.seekTo(Duration.zero);
                                _controller.play();
                              } else {
                                _controller.value.isPlaying ? _controller.pause() : _controller.play();
                              }
                            });
                          },
                          child: Container(
                            height: 75, width: 75,
                            decoration: BoxDecoration(
                              color: appPrimaryColor, shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: appPrimaryColor.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))
                              ],
                            ),
                            child: Icon(
                                isFinished ? Icons.replay : (_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                                color: Colors.white, size: 45
                            ),
                          ),
                        ),
                        _buildIconControl(Icons.speed, "${_currentSpeed}x", textColor, _toggleSpeed),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'يرجى التركيز على حركة الإشارة الموضحة في الفيديو لتعلمها بشكل صحيح.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: textColor.withOpacity(0.7), height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check_circle_outline, size: 24, color: Colors.white),
                      label: const Text(
                        "تم فهم الإشارة",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appPrimaryColor,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 3,
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)]),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VideoProgressIndicator(_controller, allowScrubbing: true, colors: VideoProgressColors(playedColor: color, bufferedColor: Colors.white24, backgroundColor: Colors.white12)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_controller.value.position), style: const TextStyle(color: Colors.white, fontSize: 11)),
              Text(_formatDuration(_controller.value.duration), style: const TextStyle(color: Colors.white, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconControl(IconData icon, String label, Color textColor, VoidCallback onTap) {
    return Column(
      children: [
        IconButton(onPressed: onTap, icon: Icon(icon, color: textColor.withOpacity(0.7), size: 32)),
        Text(label, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildErrorWidget(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 10),
          Text("عذراً، حدث خطأ في تشغيل الفيديو", style: TextStyle(color: textColor)),
        ],
      ),
    );
  }
}