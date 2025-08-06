import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/app_theme.dart';
import '../../controllers/student_controller.dart';
import '../../models/course_model.dart';
import '../../models/video_model.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../utils/youtube_utils.dart';

class CourseDetailView extends StatefulWidget {
  const CourseDetailView({super.key});

  @override
  State<CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends State<CourseDetailView> {
  final StudentController controller = Get.find<StudentController>();
  WebViewController? _webViewController;
  CourseModel? currentCourse;
  int selectedVideoIndex = 0;

  // Video progress tracking
  Map<String, double> videoProgress = {};
  Map<String, bool> videoCompleted = {};
  bool isVideoPlaying = false;
  bool _isVideoPlayerReady = false;
  Duration currentPosition = Duration.zero;
  Duration videoDuration = Duration.zero;

  // Worksheet tracking
  Map<String, bool> worksheetDownloaded = {};
  Map<String, bool> worksheetCompleted = {};

  @override
  void initState() {
    super.initState();
    // Get course from arguments or use first enrolled course
    final courseId = Get.arguments as String?;
    currentCourse = courseId != null
        ? controller.enrolledCourses.firstWhere((c) => c.id == courseId)
        : controller.enrolledCourses.isNotEmpty
        ? controller.enrolledCourses.first
        : null;

    if (currentCourse?.videos.isNotEmpty == true) {
      _initializeWebViewPlayer(currentCourse!.videos.first);
    }
  }

  void _initializeWebViewPlayer(VideoModel video) {
    // Validate video ID
    if (!video.hasValidVideoId) {
      Get.snackbar(
        'error'.tr,
        'invalid_video_id'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final videoId = video.bestVideoId;
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
              isVideoPlaying = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isVideoPlayerReady = true;
            });
          },
          onWebResourceError: (WebResourceError error) {
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
  }

  // Simplified video state tracking for WebView
  void _markVideoAsWatched(VideoModel video) {
    setState(() {
      videoCompleted[video.id] = true;
      videoProgress[video.id] = 1.0;
    });
    _showVideoCompletedDialog(video);
  }

  void _showVideoCompletedDialog(VideoModel video) {
    Get.snackbar(
      'video_completed'.tr,
      'video_completed_message'.tr.replaceAll('{title}', video.title),
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoItem(VideoModel video, int index) {
    final isSelected = index == selectedVideoIndex;
    final isCompleted = videoCompleted[video.id] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.accentColor
                : AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.play_arrow,
            color: isCompleted ? Colors.white : AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          video.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _formatDuration(video.durationSeconds),
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textColor.withValues(alpha: 0.6),
          ),
        ),
        onTap: () {
          setState(() {
            selectedVideoIndex = index;
          });
          _initializeWebViewPlayer(video);
        },
      ),
    );
  }

  Widget _buildQuizItem(quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.quiz, color: AppTheme.accentColor, size: 20),
        ),
        title: Text(
          quiz.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${quiz.questions.length} ${'questions'.tr} • ${quiz.timeLimit} ${'minutes'.tr}',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textColor.withValues(alpha: 0.6),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Get.toNamed('/quiz', arguments: quiz.id);
        },
      ),
    );
  }

  Widget _buildResourceItem(worksheet) {
    final isDownloaded = worksheetDownloaded[worksheet.id] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isDownloaded ? Icons.check_circle : Icons.description,
            color: isDownloaded ? AppTheme.accentColor : Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          worksheet.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${worksheet.fileType?.toUpperCase() ?? 'PDF'} • ${worksheet.fileSize ?? 'Unknown size'} • ${worksheet.description ?? 'No description'}',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textColor.withValues(alpha: 0.6),
          ),
        ),
        trailing: Icon(
          isDownloaded ? Icons.open_in_new : Icons.download,
          size: 16,
          color: AppTheme.primaryColor,
        ),
        onTap: () {
          _downloadResource(worksheet);
        },
      ),
    );
  }

  double _calculateProgress() {
    if (currentCourse!.videos.isEmpty) return 0.0;
    final completedVideos = currentCourse!.videos
        .where((video) => videoCompleted[video.id] ?? false)
        .length;
    return completedVideos / currentCourse!.videos.length;
  }

  void _downloadResource(worksheet) {
    setState(() {
      worksheetDownloaded[worksheet.id] = true;
    });
    Get.snackbar(
      'success'.tr,
      'resource_downloaded'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _seekToPosition(double progress) {
    // WebView doesn't support programmatic seeking
    // This is a limitation of the WebView approach
    Get.snackbar(
      'info'.tr,
      'seek_not_supported'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _playNextVideo() {
    if (selectedVideoIndex < currentCourse!.videos.length - 1) {
      setState(() {
        selectedVideoIndex++;
      });
      _initializeWebViewPlayer(currentCourse!.videos[selectedVideoIndex]);
    }
  }

  void _playPreviousVideo() {
    if (selectedVideoIndex > 0) {
      setState(() {
        selectedVideoIndex--;
      });
      _initializeWebViewPlayer(currentCourse!.videos[selectedVideoIndex]);
    }
  }

  @override
  void dispose() {
    // WebView controller doesn't need explicit disposal
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentCourse == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('course_detail'.tr),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(
            'no_course_selected'.tr,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(currentCourse!.title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Row(
        children: [
          // Left Sidebar - Course Content
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Course Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentCourse!.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${'by'.tr} ${currentCourse!.instructorName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'course_progress'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: _calculateProgress(),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(_calculateProgress() * 100).toInt()}% ${'complete'.tr}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Course Content List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Videos Section
                      if (currentCourse!.videos.isNotEmpty) ...[
                        _buildSectionHeader(
                          'course_videos'.tr,
                          Icons.play_circle_outline,
                        ),
                        const SizedBox(height: 8),
                        ...currentCourse!.videos.asMap().entries.map((entry) {
                          final index = entry.key;
                          final video = entry.value;
                          return _buildVideoItem(video, index);
                        }).toList(),
                        const SizedBox(height: 24),
                      ],

                      // Quizzes Section
                      if (currentCourse!.quizzes.isNotEmpty) ...[
                        _buildSectionHeader('course_quizzes'.tr, Icons.quiz),
                        const SizedBox(height: 8),
                        ...currentCourse!.quizzes
                            .map((quiz) => _buildQuizItem(quiz))
                            .toList(),
                        const SizedBox(height: 24),
                      ],

                      // Worksheets Section
                      if (currentCourse!.worksheets.isNotEmpty) ...[
                        _buildSectionHeader(
                          'course_resources'.tr,
                          Icons.description,
                        ),
                        const SizedBox(height: 8),
                        ...currentCourse!.worksheets
                            .map((worksheet) => _buildResourceItem(worksheet))
                            .toList(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Video Player Section
                if (currentCourse!.videos.isNotEmpty &&
                    _webViewController != null) ...[
                  Container(
                    height: 250,
                    color: Colors.black,
                    child: WebViewWidget(controller: _webViewController!),
                  ),

                  // Video Controls and Info
                  Container(
                    color: Colors.black87,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Video Title and Status
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentCourse!
                                        .videos[selectedVideoIndex]
                                        .title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_formatDuration(currentPosition.inSeconds)} / ${_formatDuration(videoDuration.inSeconds)}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (videoCompleted[currentCourse!
                                    .videos[selectedVideoIndex]
                                    .id] ==
                                true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'completed'.tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Video Navigation Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: selectedVideoIndex > 0
                                  ? _playPreviousVideo
                                  : null,
                              icon: Icon(
                                Icons.skip_previous,
                                color: selectedVideoIndex > 0
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // WebView doesn't support programmatic play/pause
                                Get.snackbar(
                                  'info'.tr,
                                  'use_video_controls'.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                              icon: Icon(
                                isVideoPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  selectedVideoIndex <
                                      currentCourse!.videos.length - 1
                                  ? _playNextVideo
                                  : null,
                              icon: Icon(
                                Icons.skip_next,
                                color:
                                    selectedVideoIndex <
                                        currentCourse!.videos.length - 1
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // Course Info Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course Title and Instructor
                        Text(
                          currentCourse!.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'by ${currentCourse!.instructorName}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textColor.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Course Description
                        Text(
                          'description'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentCourse!.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textColor.withValues(alpha: 0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Videos List
                        if (currentCourse!.videos.isNotEmpty)
                          Column(
                            children: [
                              Text(
                                'course_videos'.tr,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: currentCourse!.videos.length,
                                itemBuilder: (context, index) {
                                  final video = currentCourse!.videos[index];
                                  final isSelected =
                                      index == selectedVideoIndex;
                                  final isCompleted =
                                      videoCompleted[video.id] == true;
                                  final progress =
                                      videoProgress[video.id] ?? 0.0;

                                  return CustomCard(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    backgroundColor: isSelected
                                        ? AppTheme.primaryColor.withValues(
                                            alpha: 0.1,
                                          )
                                        : Colors.white,
                                    onTap: () {
                                      setState(() {
                                        selectedVideoIndex = index;
                                      });
                                      _initializeWebViewPlayer(video);
                                    },
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Stack(
                                              children: [
                                                Container(
                                                  width: 60,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.primaryColor
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    isSelected
                                                        ? Icons
                                                              .play_circle_filled
                                                        : Icons
                                                              .play_circle_outline,
                                                    color:
                                                        AppTheme.primaryColor,
                                                  ),
                                                ),
                                                if (isCompleted)
                                                  Positioned(
                                                    top: -2,
                                                    right: -2,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            2,
                                                          ),
                                                      decoration:
                                                          const BoxDecoration(
                                                            color: AppTheme
                                                                .accentColor,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                      child: const Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 12,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          video.title,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: isSelected
                                                                ? AppTheme
                                                                      .primaryColor
                                                                : AppTheme
                                                                      .textColor,
                                                          ),
                                                        ),
                                                      ),
                                                      if (isCompleted)
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                                vertical: 2,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: AppTheme
                                                                .accentColor
                                                                .withValues(
                                                                  alpha: 0.1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            'completed'.tr,
                                                            style: const TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppTheme
                                                                  .accentColor,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${_formatDuration(video.durationSeconds)} • ${video.description}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppTheme.textColor
                                                          .withValues(
                                                            alpha: 0.6,
                                                          ),
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Progress Bar
                                        if (progress > 0)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      '${'progress'.tr}: ${(progress * 100).toInt()}%',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: AppTheme
                                                            .textColor
                                                            .withValues(
                                                              alpha: 0.7,
                                                            ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    if (progress > 0 &&
                                                        !isCompleted)
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            selectedVideoIndex =
                                                                index;
                                                          });
                                                          _initializeWebViewPlayer(
                                                            video,
                                                          );
                                                        },
                                                        child: Text(
                                                          'resume'.tr,
                                                          style: const TextStyle(
                                                            fontSize: 10,
                                                            color: AppTheme
                                                                .primaryColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                LinearProgressIndicator(
                                                  value: progress,
                                                  backgroundColor: Colors.grey
                                                      .withValues(alpha: 0.3),
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(
                                                        isCompleted
                                                            ? AppTheme
                                                                  .accentColor
                                                            : AppTheme
                                                                  .primaryColor,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                        const SizedBox(height: 24),

                        // Worksheets Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'worksheets'.tr,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textColor,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _showWorksheetUploadDialog,
                              icon: const Icon(Icons.add, size: 16),
                              label: Text('add_worksheet'.tr),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (currentCourse!.worksheets.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: currentCourse!.worksheets.length,
                            itemBuilder: (context, index) {
                              final worksheet =
                                  currentCourse!.worksheets[index];
                              final isDownloaded =
                                  worksheetDownloaded[worksheet.id] ?? false;
                              final isCompleted =
                                  worksheetCompleted[worksheet.id] ?? false;

                              return CustomCard(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: _buildEnhancedWorksheetItem(
                                  worksheet,
                                  isDownloaded,
                                  isCompleted,
                                ),
                              );
                            },
                          )
                        else
                          CustomCard(
                            child: EmptyStateWidget(
                              icon: Icons.description_outlined,
                              title: 'no_worksheets_available'.tr,
                              description:
                                  'worksheets_will_be_added_by_instructor'.tr,
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Quizzes Section
                        if (currentCourse!.quizzes.isNotEmpty)
                          Column(
                            children: [
                              Text(
                                'quizzes'.tr,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: currentCourse!.quizzes.length,
                                itemBuilder: (context, index) {
                                  final quiz = currentCourse!.quizzes[index];
                                  return CustomCard(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentColor
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.quiz,
                                            color: AppTheme.accentColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                quiz.title,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.textColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${quiz.questions.length} questions • ${quiz.timeLimit} min',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.textColor
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        CustomButton(
                                          text: 'take_quiz'.tr,
                                          type: ButtonType.primary,
                                          onPressed: () {
                                            Get.toNamed(
                                              '/student/quiz',
                                              arguments: quiz.id,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
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

  Widget _buildEnhancedWorksheetItem(
    dynamic worksheet,
    bool isDownloaded,
    bool isCompleted,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getWorksheetIcon(worksheet.fileType ?? 'pdf'),
                      color: AppTheme.secondaryColor,
                      size: 24,
                    ),
                  ),
                  if (isCompleted)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            worksheet.title ?? 'Untitled Worksheet',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'completed'.tr,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${worksheet.fileType?.toUpperCase() ?? 'PDF'} • ${worksheet.fileSize ?? 'Unknown size'} • ${worksheet.description ?? 'No description'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textColor.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (worksheet.uploadedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${'uploaded_on'.tr}: ${_formatDate(worksheet.uploadedAt)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _downloadWorksheet(worksheet),
                  icon: Icon(
                    isDownloaded ? Icons.download_done : Icons.download,
                    size: 16,
                  ),
                  label: Text(isDownloaded ? 'downloaded'.tr : 'download'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDownloaded
                        ? AppTheme.accentColor
                        : AppTheme.primaryColor,
                    side: BorderSide(
                      color: isDownloaded
                          ? AppTheme.accentColor
                          : AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _viewWorksheet(worksheet),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: Text('view'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _toggleWorksheetCompletion(worksheet),
                icon: Icon(
                  isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                  color: isCompleted ? AppTheme.accentColor : Colors.grey,
                ),
                tooltip: isCompleted
                    ? 'mark_incomplete'.tr
                    : 'mark_complete'.tr,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getWorksheetIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.description;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'unknown'.tr;
    return '${date.day}/${date.month}/${date.year}';
  }

  void _downloadWorksheet(dynamic worksheet) {
    setState(() {
      worksheetDownloaded[worksheet.id] = true;
    });

    Get.snackbar(
      'download_started'.tr,
      'downloading_worksheet'.tr.replaceAll(
        '{title}',
        worksheet.title ?? 'worksheet',
      ),
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      icon: const Icon(Icons.download, color: Colors.white),
      duration: const Duration(seconds: 2),
    );

    // Simulate download completion after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Get.snackbar(
        'download_complete'.tr,
        'worksheet_downloaded_successfully'.tr,
        backgroundColor: AppTheme.accentColor,
        colorText: Colors.white,
        icon: const Icon(Icons.download_done, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    });
  }

  void _viewWorksheet(dynamic worksheet) {
    Get.snackbar(
      'opening_worksheet'.tr,
      'opening_worksheet_viewer'.tr,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      icon: const Icon(Icons.visibility, color: Colors.white),
      duration: const Duration(seconds: 2),
    );

    // TODO: Implement actual worksheet viewer
    // This would typically open a PDF viewer or document viewer
  }

  void _toggleWorksheetCompletion(dynamic worksheet) {
    setState(() {
      worksheetCompleted[worksheet.id] =
          !(worksheetCompleted[worksheet.id] ?? false);
    });

    final isCompleted = worksheetCompleted[worksheet.id] ?? false;
    Get.snackbar(
      isCompleted ? 'worksheet_completed'.tr : 'worksheet_marked_incomplete'.tr,
      isCompleted
          ? 'worksheet_marked_as_completed'.tr
          : 'worksheet_marked_as_incomplete'.tr,
      backgroundColor: isCompleted ? AppTheme.accentColor : Colors.orange,
      colorText: Colors.white,
      icon: Icon(
        isCompleted ? Icons.check_circle : Icons.remove_circle,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 2),
    );
  }

  void _showWorksheetUploadDialog() {
    Get.snackbar(
      'feature_coming_soon'.tr,
      'worksheet_upload_instructor_only'.tr,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }
}
