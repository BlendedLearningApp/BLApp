import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/video_model.dart';

/// Simple and reliable video player widget for students using WebView
/// Based on the working instructor video review implementation
class VideoPlayerWidget extends StatefulWidget {
  final VideoModel video;
  final VoidCallback? onVideoCompleted;
  final Function(int watchTime)? onProgressUpdate;
  final bool autoPlay;
  final bool showControls;

  const VideoPlayerWidget({
    super.key,
    required this.video,
    this.onVideoCompleted,
    this.onProgressUpdate,
    this.autoPlay = false,
    this.showControls = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    print('🎥 VideoPlayerWidget: Building for video: ${widget.video.title}');
    print('🎥 VideoPlayerWidget: YouTube URL: ${widget.video.youtubeUrl}');
    print(
      '🎥 VideoPlayerWidget: YouTube Video ID: ${widget.video.youtubeVideoId}',
    );

    // Validate video ID
    if (!widget.video.hasValidVideoId) {
      print('❌ VideoPlayerWidget: Invalid video ID');
      return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'invalid_video_id'.tr,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final videoId = widget.video.bestVideoId;
    print('🎥 VideoPlayerWidget: Using video ID: $videoId');

    // Use the same simple approach as the working instructor implementation
    final embedUrl =
        'https://www.youtube.com/embed/$videoId?autoplay=${widget.autoPlay ? 1 : 0}&controls=${widget.showControls ? 1 : 0}&rel=0&showinfo=0&modestbranding=1';
    print('🎥 VideoPlayerWidget: Loading URL: $embedUrl');

    final webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🎥 VideoPlayerWidget: Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('🎥 VideoPlayerWidget: Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ VideoPlayerWidget: Loading error: ${error.description}');
            Get.snackbar(
              'error'.tr,
              'failed_to_load_video'.tr,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow YouTube domains
            if (request.url.contains('youtube.com') ||
                request.url.contains('youtu.be') ||
                request.url.contains('googlevideo.com')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(embedUrl));

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: WebViewWidget(controller: webViewController),
        ),
      ),
    );
  }
}
