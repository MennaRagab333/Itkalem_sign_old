import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final VoidCallback onBack;

  const VideoPlayerScreen({super.key, required this.videoUrl, required this.title, required this.onBack});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isError = false;
  double _currentSpeed = 1.0;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.setLooping(false);
          _controller.play();
        }
      }).catchError((error) {
        if (mounted) {
          setState(() => _isError = true);
        }
      });

    _controller.addListener(() {
      if (mounted) {
        if (_controller.value.position >= _controller.value.duration) {
          _controller.pause();
          setState(() {});
        } else {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  void _toggleSpeed() {
    setState(() {
      if (_currentSpeed == 1.0) _currentSpeed = 1.5;
      else if (_currentSpeed == 1.5) _currentSpeed = 2.0;
      else _currentSpeed = 1.0;
      _controller.setPlaybackSpeed(_currentSpeed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final bool isFinished = _controller.value.position >= _controller.value.duration;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
          onPressed: widget.onBack,
        ),
        title: Text(
          widget.title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: _isError
          ? _buildErrorWidget(textColor)
          : !_controller.value.isInitialized
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Stack(
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
                      child: _buildProgressBar(primaryColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIconControl(Icons.speed, "${_currentSpeed}x", textColor, _toggleSpeed),
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
                            color: primaryColor, shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
                          ),
                          child: Icon(isFinished ? Icons.replay : (_controller.value.isPlaying ? Icons.pause : Icons.play_arrow), color: Colors.white, size: 45),
                        ),
                      ),
                      _buildIconControl(Icons.replay, "إعادة", textColor, () {
                        _controller.seekTo(Duration.zero);
                        _controller.play();
                      }),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 26),
                    label: const Text("تم فهم الإشارة", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)]),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VideoProgressIndicator(_controller, allowScrubbing: true, colors: VideoProgressColors(playedColor: primaryColor, bufferedColor: Colors.white24, backgroundColor: Colors.white12)),
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
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 10),
          Text("عذراً، حدث خطأ في تشغيل الفيديو", style: TextStyle(color: textColor)),
        ],
      ),
    );
  }
}