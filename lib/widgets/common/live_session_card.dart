import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../models/live_session_model.dart';
import 'custom_button.dart';

class LiveSessionCard extends StatelessWidget {
  final LiveSessionModel session;
  final VoidCallback? onJoin;
  final VoidCallback? onRemind;

  const LiveSessionCard({
    super.key,
    required this.session,
    this.onJoin,
    this.onRemind,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppTheme.primaryColor.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Course name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                session.courseName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentColor,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              session.description,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textColor.withOpacity(0.7),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 16),
            
            // Session details
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: AppTheme.textColor.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  session.instructorName,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.textColor.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${session.durationMinutes} min',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Time and action buttons
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDateTime(session.scheduledTime),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        session.isUpcoming 
                            ? 'starts_in'.tr + ' ${session.formattedScheduledTime}'
                            : session.isLive 
                                ? 'live_now'.tr
                                : 'session_ended'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: session.isLive 
                              ? Colors.red 
                              : AppTheme.textColor.withOpacity(0.6),
                          fontWeight: session.isLive 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Action buttons
                if (session.isLive) ...[
                  CustomButton(
                    text: 'join_now'.tr,
                    type: ButtonType.primary,
                    onPressed: onJoin,
                    width: 100,
                  ),
                ] else if (session.isUpcoming) ...[
                  CustomButton(
                    text: 'remind_me'.tr,
                    type: ButtonType.outline,
                    onPressed: onRemind,
                    width: 90,
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    text: 'join'.tr,
                    type: ButtonType.primary,
                    onPressed: onJoin,
                    width: 70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    String statusText;
    
    switch (session.status) {
      case LiveSessionStatus.live:
        chipColor = Colors.red;
        statusText = 'live'.tr;
        break;
      case LiveSessionStatus.scheduled:
        chipColor = AppTheme.primaryColor;
        statusText = 'scheduled'.tr;
        break;
      case LiveSessionStatus.ended:
        chipColor = Colors.grey;
        statusText = 'ended'.tr;
        break;
      case LiveSessionStatus.cancelled:
        chipColor = Colors.orange;
        statusText = 'cancelled'.tr;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (session.isLive) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: chipColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateStr;
    if (sessionDate == today) {
      dateStr = 'today'.tr;
    } else if (sessionDate == today.add(const Duration(days: 1))) {
      dateStr = 'tomorrow'.tr;
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    
    return '$dateStr at $timeStr';
  }
}
