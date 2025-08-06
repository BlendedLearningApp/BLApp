import 'dart:developer';

/// Utility class for handling YouTube video ID validation and conversion
/// This ensures all video IDs are properly formatted strings to prevent
/// the "type 'int' is not a subtype of type 'String'" error
class YouTubeUtils {
  /// Validates and sanitizes a YouTube video ID
  /// Returns a valid 11-character string or null if invalid
  static String? validateAndSanitizeVideoId(dynamic videoId) {
    if (videoId == null) return null;

    // Convert to string and trim whitespace
    String id = videoId.toString().trim();

    // Check if it's a valid YouTube video ID format
    if (id.length == 11 && RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(id)) {
      return id;
    }

    return null;
  }

  /// Extracts and validates video ID from a YouTube URL
  /// Uses regex patterns to extract video IDs from various YouTube URL formats
  static String? extractVideoIdFromUrl(String url) {
    if (url.isEmpty) return null;

    try {
      // Regex patterns for different YouTube URL formats
      final regexPatterns = [
        RegExp(
          r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
        ),
        RegExp(r'youtube\.com\/watch\?v=([^&\s]+)'),
        RegExp(r'youtu\.be\/([^?&\s]+)'),
        RegExp(r'youtube\.com\/embed\/([^?&\s]+)'),
      ];

      for (final regex in regexPatterns) {
        final match = regex.firstMatch(url);
        if (match != null && match.group(1) != null) {
          final videoId = validateAndSanitizeVideoId(match.group(1));
          if (videoId != null) {
            return videoId;
          }
        }
      }
    } catch (e) {
      log('Error extracting video ID from URL: $e');
    }

    return null;
  }

  /// Gets the best available video ID from URL and fallback ID
  /// Prioritizes URL extraction over stored ID for accuracy
  static String? getBestVideoId(String? youtubeUrl, dynamic youtubeVideoId) {
    // Try to extract from URL first
    if (youtubeUrl != null && youtubeUrl.isNotEmpty) {
      final extractedId = extractVideoIdFromUrl(youtubeUrl);
      if (extractedId != null) {
        return extractedId;
      }
    }

    // Fallback to stored video ID
    return validateAndSanitizeVideoId(youtubeVideoId);
  }

  /// Validates if a video ID is in the correct YouTube format
  static bool isValidVideoId(dynamic videoId) {
    return validateAndSanitizeVideoId(videoId) != null;
  }

  /// Creates a YouTube embed URL for WebView
  /// Returns a properly formatted embed URL or null if video ID is invalid
  static String? createEmbedUrl(
    String? youtubeUrl,
    dynamic youtubeVideoId, {
    bool autoPlay = false,
    bool showControls = true,
    bool showRelated = false,
    bool showInfo = false,
    bool modestBranding = true,
  }) {
    final validVideoId = getBestVideoId(youtubeUrl, youtubeVideoId);

    if (validVideoId == null) {
      log('Invalid video ID: URL=$youtubeUrl, ID=$youtubeVideoId');
      return null;
    }

    final params = <String, String>{
      'autoplay': autoPlay ? '1' : '0',
      'controls': showControls ? '1' : '0',
      'rel': showRelated ? '1' : '0',
      'showinfo': showInfo ? '1' : '0',
      'modestbranding': modestBranding ? '1' : '0',
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return 'https://www.youtube.com/embed/$validVideoId?$queryString';
  }

  /// Formats duration in seconds to MM:SS format
  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Validates YouTube URL format
  static bool isValidYouTubeUrl(String url) {
    if (url.isEmpty) return false;

    final youtubeUrlPattern = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com|youtu\.be)/.+',
      caseSensitive: false,
    );

    return youtubeUrlPattern.hasMatch(url) &&
        extractVideoIdFromUrl(url) != null;
  }

  /// Converts various YouTube URL formats to a standard watch URL
  static String? normalizeYouTubeUrl(String url) {
    final videoId = extractVideoIdFromUrl(url);
    if (videoId == null) return null;

    return 'https://www.youtube.com/watch?v=$videoId';
  }

  /// Gets thumbnail URL for a YouTube video
  static String getThumbnailUrl(
    String videoId, {
    String quality = 'hqdefault',
  }) {
    final validId = validateAndSanitizeVideoId(videoId);
    if (validId == null) return '';

    return 'https://img.youtube.com/vi/$validId/$quality.jpg';
  }
}
