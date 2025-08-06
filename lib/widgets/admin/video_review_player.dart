import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../models/video_model.dart';
import '../../utils/youtube_utils.dart';

/// WebView-based video review player for YouTube videos
/// This replaces the youtube_player_flutter to avoid type conversion issues
class VideoReviewPlayer extends StatefulWidget {
  final VideoModel video;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const VideoReviewPlayer({
    super.key,
    required this.video,
    this.onApprove,
    this.onReject,
  });

  @override
  State<VideoReviewPlayer> createState() => _VideoReviewPlayerState();
}

class _VideoReviewPlayerState extends State<VideoReviewPlayer> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // Validate video ID
    if (!widget.video.hasValidVideoId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'error'.tr,
          'invalid_video_id'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back();
      });
      return;
    }

    final videoId = widget.video.bestVideoId;
    _loadVideoWithFallback(videoId);
  }

  void _loadVideoWithFallback(String videoId) {
    // Try YouTube embed first
    final embedUrl =
        'https://www.youtube.com/embed/$videoId?autoplay=0&controls=1&rel=0&showinfo=0&modestbranding=1';

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
            log('Loading video: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            log('Video loaded successfully: ${widget.video.title}');
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
            log('Error loading video: ${error.description}');

            // Try alternative URL formats
            if (error.errorCode == -2) {
              // NAME_NOT_RESOLVED
              _tryAlternativeUrls(videoId);
            }
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
      );

    _loadUrl(embedUrl);
  }

  void _tryAlternativeUrls(String videoId) {
    final alternativeUrls = [
      'https://www.youtube-nocookie.com/embed/$videoId?autoplay=0&controls=1&rel=0&showinfo=0&modestbranding=1',
      'https://m.youtube.com/watch?v=$videoId',
      'https://youtu.be/$videoId',
    ];

    _loadUrlWithRetry(alternativeUrls, 0);
  }

  void _loadUrlWithRetry(List<String> urls, int index) {
    if (index >= urls.length) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      return;
    }

    log('Trying alternative URL: ${urls[index]}');
    _loadUrl(urls[index]);

    // If this fails, try the next URL after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (_hasError && mounted) {
        _loadUrlWithRetry(urls, index + 1);
      }
    });
  }

  void _loadUrl(String url) {
    try {
      _webViewController.loadRequest(Uri.parse(url));
    } catch (e) {
      log('Error loading URL: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // WebView controller doesn't need explicit disposal
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Video Player
            Expanded(flex: 3, child: _buildVideoPlayer()),

            // Video Information and Controls
            Expanded(flex: 2, child: _buildVideoInfo()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.video_library, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'video_review'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                'failed_to_load_video'.tr,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isLoading = true;
                  });
                  _initializeWebView();
                },
                child: Text('retry'.tr),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
          child: WebViewWidget(controller: _webViewController),
        ),
        if (_isLoading)
          Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Title and Description
          Text(
            widget.video.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            widget.video.description,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textColor.withValues(alpha: 0.7),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Video Metadata
          _buildVideoMetadata(),

          const Spacer(),

          // Review Action Buttons
          if (widget.onApprove != null || widget.onReject != null)
            _buildReviewActions(),
        ],
      ),
    );
  }

  Widget _buildVideoMetadata() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${'video_id'.tr}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(widget.video.bestVideoId),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${'duration'.tr}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(YouTubeUtils.formatDuration(widget.video.durationSeconds)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewActions() {
    return Row(
      children: [
        if (widget.onReject != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showRejectDialog,
              icon: const Icon(Icons.close, size: 18),
              label: Text('reject'.tr),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        if (widget.onReject != null && widget.onApprove != null)
          const SizedBox(width: 12),
        if (widget.onApprove != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showApproveDialog,
              icon: const Icon(Icons.check, size: 18),
              label: Text('approve'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showApproveDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('approve_video'.tr),
        content: Text(
          'approve_video_confirmation'.tr.replaceAll(
            '{video}',
            widget.video.title,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.back();
              widget.onApprove?.call();

              final adminController = Get.find<AdminController>();
              adminController.approveVideo(widget.video.id);

              Get.snackbar(
                'success'.tr,
                'video_approved_successfully'.tr,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.accentColor,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: Text('approve'.tr),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('reject_video'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'reject_video_confirmation'.tr.replaceAll(
                '{video}',
                widget.video.title,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'rejection_reason'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.back();
              widget.onReject?.call();

              Get.snackbar(
                'success'.tr,
                'video_rejected_successfully'.tr,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('reject'.tr),
          ),
        ],
      ),
    );
  }
}
