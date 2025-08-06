class LiveSessionModel {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final String courseName;
  final String instructorId;
  final String instructorName;
  final DateTime scheduledTime;
  final int durationMinutes;
  final String meetingUrl;
  final LiveSessionStatus status;
  final List<String> attendeeIds;
  final DateTime createdAt;

  LiveSessionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.courseName,
    required this.instructorId,
    required this.instructorName,
    required this.scheduledTime,
    required this.durationMinutes,
    required this.meetingUrl,
    required this.status,
    required this.attendeeIds,
    required this.createdAt,
  });

  factory LiveSessionModel.fromJson(Map<String, dynamic> json) {
    return LiveSessionModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      courseId: json['courseId'],
      courseName: json['courseName'],
      instructorId: json['instructorId'],
      instructorName: json['instructorName'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      durationMinutes: json['durationMinutes'],
      meetingUrl: json['meetingUrl'],
      status: LiveSessionStatus.values.firstWhere(
        (e) => e.toString() == 'LiveSessionStatus.${json['status']}',
      ),
      attendeeIds: List<String>.from(json['attendeeIds']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseId': courseId,
      'courseName': courseName,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'scheduledTime': scheduledTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'meetingUrl': meetingUrl,
      'status': status.toString().split('.').last,
      'attendeeIds': attendeeIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isUpcoming => scheduledTime.isAfter(DateTime.now());
  bool get isLive => status == LiveSessionStatus.live;
  bool get hasEnded => status == LiveSessionStatus.ended;

  String get formattedScheduledTime {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes';
    } else {
      return 'Starting now';
    }
  }
}

enum LiveSessionStatus {
  scheduled,
  live,
  ended,
  cancelled,
}
