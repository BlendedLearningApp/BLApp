import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blapp/config/app_theme.dart';
import 'package:blapp/controllers/admin_controller.dart';
import 'package:blapp/widgets/common/custom_card.dart';

class SystemSettingsView extends StatefulWidget {
  const SystemSettingsView({super.key});

  @override
  State<SystemSettingsView> createState() => _SystemSettingsViewState();
}

class _SystemSettingsViewState extends State<SystemSettingsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Settings state
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _maintenanceMode = false;
  bool _userRegistration = true;
  bool _courseAutoApproval = false;
  String _defaultLanguage = 'en';
  String _timeZone = 'UTC';
  int _sessionTimeout = 30;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('system_settings'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveSettings(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: [
            Tab(text: 'general'.tr),
            Tab(text: 'notifications'.tr),
            Tab(text: 'security'.tr),
            Tab(text: 'maintenance'.tr),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(),
          _buildNotificationsTab(),
          _buildSecurityTab(),
          _buildMaintenanceTab(),
        ],
      ),
    );
  }
  
  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System Information
          Text(
            'system_information'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow('app_version'.tr, '1.0.0'),
                  const Divider(),
                  _buildInfoRow('database_version'.tr, '2.1.5'),
                  const Divider(),
                  _buildInfoRow('server_status'.tr, 'online'.tr, 
                    valueColor: AppTheme.accentColor),
                  const Divider(),
                  _buildInfoRow('last_backup'.tr, '2 hours ago'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // General Settings
          Text(
            'general_settings'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Default Language
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'default_language'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DropdownButton<String>(
                        value: _defaultLanguage,
                        items: [
                          DropdownMenuItem(
                            value: 'en',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🇺🇸'),
                                const SizedBox(width: 8),
                                Text('english'.tr),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'ar',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🇸🇦'),
                                const SizedBox(width: 8),
                                Text('arabic'.tr),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _defaultLanguage = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  
                  // Time Zone
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'time_zone'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DropdownButton<String>(
                        value: _timeZone,
                        items: [
                          DropdownMenuItem(
                            value: 'UTC',
                            child: Text('UTC'),
                          ),
                          DropdownMenuItem(
                            value: 'Asia/Riyadh',
                            child: Text('Asia/Riyadh'),
                          ),
                          DropdownMenuItem(
                            value: 'America/New_York',
                            child: Text('America/New_York'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _timeZone = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  
                  // User Registration
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'allow_user_registration'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'allow_new_users_register'.tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _userRegistration,
                        onChanged: (value) {
                          setState(() {
                            _userRegistration = value;
                          });
                        },
                        activeColor: AppTheme.accentColor,
                      ),
                    ],
                  ),
                  const Divider(),
                  
                  // Course Auto Approval
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'course_auto_approval'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'automatically_approve_courses'.tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _courseAutoApproval,
                        onChanged: (value) {
                          setState(() {
                            _courseAutoApproval = value;
                          });
                        },
                        activeColor: AppTheme.accentColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'notification_settings'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Email Notifications
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'email_notifications'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'send_email_notifications'.tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _emailNotifications,
                        onChanged: (value) {
                          setState(() {
                            _emailNotifications = value;
                          });
                        },
                        activeColor: AppTheme.accentColor,
                      ),
                    ],
                  ),
                  const Divider(),
                  
                  // Push Notifications
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'push_notifications'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'send_push_notifications'.tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _pushNotifications,
                        onChanged: (value) {
                          setState(() {
                            _pushNotifications = value;
                          });
                        },
                        activeColor: AppTheme.accentColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Email Templates
          Text(
            'email_templates'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Column(
              children: [
                _buildTemplateItem('welcome_email'.tr, 'welcome_email_desc'.tr),
                const Divider(height: 1),
                _buildTemplateItem('course_approval'.tr, 'course_approval_desc'.tr),
                const Divider(height: 1),
                _buildTemplateItem('password_reset'.tr, 'password_reset_desc'.tr),
                const Divider(height: 1),
                _buildTemplateItem('assignment_reminder'.tr, 'assignment_reminder_desc'.tr),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'security_settings'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Session Timeout
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'session_timeout'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'session_timeout_desc'.tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      DropdownButton<int>(
                        value: _sessionTimeout,
                        items: [
                          DropdownMenuItem(value: 15, child: Text('15 ' + 'minutes'.tr)),
                          DropdownMenuItem(value: 30, child: Text('30 ' + 'minutes'.tr)),
                          DropdownMenuItem(value: 60, child: Text('1 ' + 'hour'.tr)),
                          DropdownMenuItem(value: 120, child: Text('2 ' + 'hours'.tr)),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sessionTimeout = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Security Actions
          Text(
            'security_actions'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Column(
              children: [
                _buildActionItem(
                  'force_password_reset'.tr,
                  'force_all_users_reset'.tr,
                  Icons.security,
                  Colors.orange,
                  () => _showConfirmationDialog('force_password_reset'.tr),
                ),
                const Divider(height: 1),
                _buildActionItem(
                  'clear_all_sessions'.tr,
                  'logout_all_users'.tr,
                  Icons.logout,
                  Colors.red,
                  () => _showConfirmationDialog('clear_all_sessions'.tr),
                ),
                const Divider(height: 1),
                _buildActionItem(
                  'view_security_logs'.tr,
                  'view_system_security_logs'.tr,
                  Icons.visibility,
                  AppTheme.primaryColor,
                  () => _viewSecurityLogs(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMaintenanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'maintenance_mode'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'enable_maintenance_mode'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'maintenance_mode_desc'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _maintenanceMode,
                    onChanged: (value) {
                      if (value) {
                        _showMaintenanceModeDialog();
                      } else {
                        setState(() {
                          _maintenanceMode = false;
                        });
                      }
                    },
                    activeColor: AppTheme.warningColor,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // System Maintenance
          Text(
            'system_maintenance'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Column(
              children: [
                _buildActionItem(
                  'backup_database'.tr,
                  'create_system_backup'.tr,
                  Icons.backup,
                  AppTheme.accentColor,
                  () => _backupDatabase(),
                ),
                const Divider(height: 1),
                _buildActionItem(
                  'clear_cache'.tr,
                  'clear_system_cache'.tr,
                  Icons.clear_all,
                  AppTheme.primaryColor,
                  () => _clearCache(),
                ),
                const Divider(height: 1),
                _buildActionItem(
                  'optimize_database'.tr,
                  'optimize_database_performance'.tr,
                  Icons.tune,
                  Colors.purple,
                  () => _optimizeDatabase(),
                ),
                const Divider(height: 1),
                _buildActionItem(
                  'system_health_check'.tr,
                  'run_system_diagnostics'.tr,
                  Icons.health_and_safety,
                  Colors.green,
                  () => _runHealthCheck(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: valueColor ?? AppTheme.textColor.withValues(alpha: 0.7),
            fontWeight: valueColor != null ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTemplateItem(String title, String description) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.textColor.withValues(alpha: 0.7),
        ),
      ),
      trailing: const Icon(Icons.edit, size: 20),
      onTap: () => _editTemplate(title),
    );
  }
  
  Widget _buildActionItem(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.textColor.withValues(alpha: 0.7),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
  
  void _saveSettings() {
    Get.snackbar(
      'settings_saved'.tr,
      'settings_saved_successfully'.tr,
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
    );
  }
  
  void _editTemplate(String template) {
    Get.snackbar(
      'edit_template'.tr,
      'editing_template'.tr.replaceAll('{template}', template),
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }
  
  void _showConfirmationDialog(String action) {
    Get.dialog(
      AlertDialog(
        title: Text('confirm_action'.tr),
        content: Text('confirm_action_desc'.tr.replaceAll('{action}', action)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'action_completed'.tr,
                'action_completed_successfully'.tr,
                backgroundColor: AppTheme.accentColor,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }
  
  void _showMaintenanceModeDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('enable_maintenance_mode'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('maintenance_mode_warning'.tr),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'maintenance_message'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _maintenanceMode = true;
              });
              Get.back();
              Get.snackbar(
                'maintenance_mode_enabled'.tr,
                'system_in_maintenance_mode'.tr,
                backgroundColor: AppTheme.warningColor,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningColor),
            child: Text('enable'.tr),
          ),
        ],
      ),
    );
  }
  
  void _viewSecurityLogs() {
    Get.snackbar(
      'security_logs'.tr,
      'viewing_security_logs'.tr,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }
  
  void _backupDatabase() {
    Get.snackbar(
      'backup_started'.tr,
      'database_backup_in_progress'.tr,
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
    );
  }
  
  void _clearCache() {
    Get.snackbar(
      'cache_cleared'.tr,
      'system_cache_cleared_successfully'.tr,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }
  
  void _optimizeDatabase() {
    Get.snackbar(
      'optimization_started'.tr,
      'database_optimization_in_progress'.tr,
      backgroundColor: Colors.purple,
      colorText: Colors.white,
    );
  }
  
  void _runHealthCheck() {
    Get.snackbar(
      'health_check_started'.tr,
      'running_system_diagnostics'.tr,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
