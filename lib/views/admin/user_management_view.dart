import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blapp/config/app_theme.dart';
import 'package:blapp/controllers/admin_controller.dart';
import 'package:blapp/widgets/common/custom_card.dart';

import 'package:blapp/widgets/common/loading_widget.dart';
import 'package:blapp/widgets/common/empty_state_widget.dart';
import 'package:blapp/models/user_model.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  UserRole? _selectedRoleFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Add listener to refresh data when tabs change
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final adminController = Get.find<AdminController>();

      // Refresh data when switching to pending approvals tab (index 1)
      if (_tabController.index == 1) {
        // Use the more efficient refresh method for pending approvals
        adminController.refreshPendingApprovals();
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('user_management'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showCreateUserDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminController.loadAdminData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: [
            Tab(text: 'all_users'.tr),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('pending_approvals'.tr),
                  const SizedBox(width: 4),
                  Obx(() {
                    final pendingCount =
                        adminController.pendingApprovalUsers.length;
                    if (pendingCount > 0) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$pendingCount',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            Tab(text: 'active_users'.tr),
            Tab(text: 'inactive_users'.tr),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilterSection(),

          // Users List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersList(adminController, null), // All users
                _buildPendingApprovalsList(
                  adminController,
                ), // Pending approvals
                _buildUsersList(adminController, true), // Active users
                _buildUsersList(adminController, false), // Inactive users
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.withValues(alpha: 0.1),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'search_users'.tr,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // Role Filter
          Row(
            children: [
              Text(
                'filter_by_role'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRoleFilterChip('All', null),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip('Students', UserRole.student),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip('Instructors', UserRole.instructor),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip('Admins', UserRole.admin),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilterChip(String label, UserRole? role) {
    final isSelected = _selectedRoleFilter == role;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRoleFilter = selected ? role : null;
        });
      },
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildPendingApprovalsList(AdminController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget();
      }

      final pendingUsers = controller.pendingApprovalUsers;

      if (pendingUsers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.green.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'no_pending_user_approvals'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textColor.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'All users have been reviewed!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textColor.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshPendingApprovals(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingUsers.length,
          itemBuilder: (context, index) {
            final user = pendingUsers[index];
            return _buildPendingUserCard(user, controller);
          },
        ),
      );
    });
  }

  Widget _buildUsersList(AdminController controller, bool? activeFilter) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget();
      }

      var users = controller.allUsers.where((user) {
        // Apply active filter
        if (activeFilter != null && user.isActive != activeFilter) {
          return false;
        }

        // Apply role filter
        if (_selectedRoleFilter != null && user.role != _selectedRoleFilter) {
          return false;
        }

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          return user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query);
        }

        return true;
      }).toList();

      if (users.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.people_outline,
          title: 'No Users Found',
          description: _searchQuery.isNotEmpty
              ? 'No users found matching your search'
              : 'No users found',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(user, controller);
        },
      );
    });
  }

  Widget _buildUserCard(UserModel user, AdminController controller) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 25,
                  backgroundColor: _getRoleColor(
                    user.role,
                  ).withValues(alpha: 0.2),
                  child: user.profileImage != null
                      ? ClipOval(
                          child: Image.network(
                            user.profileImage!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              _getRoleIcon(user.role),
                              color: _getRoleColor(user.role),
                            ),
                          ),
                        )
                      : Icon(
                          _getRoleIcon(user.role),
                          color: _getRoleColor(user.role),
                        ),
                ),
                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusChip(user.isActive),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildRoleChip(user.role),
                          const SizedBox(width: 8),
                          _buildApprovalStatusChip(user.approvalStatus),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Joined ${_formatDate(user.createdAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textColor.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions Menu
                PopupMenuButton<String>(
                  onSelected: (action) =>
                      _handleUserAction(action, user, controller),
                  itemBuilder: (context) => [
                    // Approval actions (only for pending users)
                    if (user.approvalStatus == 'pending_approval') ...[
                      PopupMenuItem(
                        value: 'approve',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 20,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text('approve'.tr),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'reject',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cancel,
                              size: 20,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text('reject'.tr),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                    ],
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 20),
                          const SizedBox(width: 8),
                          Text('edit'.tr),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: user.isActive ? 'deactivate' : 'activate',
                      child: Row(
                        children: [
                          Icon(
                            user.isActive ? Icons.block : Icons.check_circle,
                            size: 20,
                            color: user.isActive
                                ? Colors.red
                                : AppTheme.accentColor,
                          ),
                          const SizedBox(width: 8),
                          Text(user.isActive ? 'deactivate'.tr : 'activate'.tr),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'reset_password',
                      child: Row(
                        children: [
                          const Icon(Icons.lock_reset, size: 20),
                          const SizedBox(width: 8),
                          Text('reset_password'.tr),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'delete'.tr,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingUserCard(UserModel user, AdminController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _getRoleColor(
                    user.role,
                  ).withValues(alpha: 0.2),
                  child: user.profileImage != null
                      ? ClipOval(
                          child: Image.network(
                            user.profileImage!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              _getRoleIcon(user.role),
                              color: _getRoleColor(user.role),
                              size: 30,
                            ),
                          ),
                        )
                      : Icon(
                          _getRoleIcon(user.role),
                          color: _getRoleColor(user.role),
                          size: 30,
                        ),
                ),
                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'PENDING',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildRoleChip(user.role),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppTheme.textColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(user.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveUser(user, controller),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: Text('approve'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectUser(user, controller),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: Text('reject'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.accentColor.withValues(alpha: 0.2)
            : Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'active'.tr : 'inactive'.tr,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isActive ? AppTheme.accentColor : Colors.red,
        ),
      ),
    );
  }

  Widget _buildRoleChip(UserRole role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getRoleColor(role),
        ),
      ),
    );
  }

  Widget _buildApprovalStatusChip(String approvalStatus) {
    Color color;
    String text;

    switch (approvalStatus) {
      case 'pending_approval':
        color = Colors.orange;
        text = 'PENDING';
        break;
      case 'approved':
        color = Colors.green;
        text = 'APPROVED';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'REJECTED';
        break;
      default:
        color = Colors.grey;
        text = 'UNKNOWN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return AppTheme.primaryColor;
      case UserRole.instructor:
        return AppTheme.warningColor;
      case UserRole.admin:
        return Colors.purple;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school;
      case UserRole.instructor:
        return Icons.person;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  void _approveUser(UserModel user, AdminController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('approve_user'.tr),
        content: Text('Are you sure you want to approve ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.approveUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('approve'.tr),
          ),
        ],
      ),
    );
  }

  void _rejectUser(UserModel user, AdminController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('reject_user'.tr),
        content: Text('Are you sure you want to reject ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.rejectUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('reject'.tr),
          ),
        ],
      ),
    );
  }

  void _handleUserAction(
    String action,
    UserModel user,
    AdminController controller,
  ) {
    switch (action) {
      case 'approve':
        _approveUser(user, controller);
        break;
      case 'reject':
        _rejectUser(user, controller);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'activate':
      case 'deactivate':
        _toggleUserStatus(user, controller);
        break;
      case 'reset_password':
        _resetUserPassword(user);
        break;
      case 'delete':
        _deleteUser(user, controller);
        break;
    }
  }

  void _showCreateUserDialog(BuildContext context) {
    // Implementation for create user dialog
    Get.snackbar(
      'info'.tr,
      'Create user dialog will be implemented',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showEditUserDialog(UserModel user) {
    // Implementation for edit user dialog
    Get.snackbar(
      'info'.tr,
      'Edit user dialog for ${user.name} will be implemented',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _toggleUserStatus(UserModel user, AdminController controller) {
    final newStatus = !user.isActive;
    final action = newStatus ? 'activate' : 'deactivate';

    Get.dialog(
      AlertDialog(
        title: Text('${action}_user'.tr),
        content: Text('Are you sure you want to $action ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.toggleUserActiveStatus(user.id, newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? Colors.green : Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(action.tr),
          ),
        ],
      ),
    );
  }

  void _resetUserPassword(UserModel user) {
    // Mock implementation
    Get.snackbar(
      'success'.tr,
      'Password reset email sent to ${user.email}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _deleteUser(UserModel user, AdminController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_user'.tr),
        content: Text(
          'Are you sure you want to delete ${user.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }
}
