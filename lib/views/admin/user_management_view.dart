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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
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
          tabs: [
            Tab(text: 'all_users'.tr),
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
        role.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getRoleColor(role),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'yesterday';
    } else if (difference < 30) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _handleUserAction(
    String action,
    UserModel user,
    AdminController controller,
  ) {
    switch (action) {
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
    // Mock implementation
    Get.snackbar(
      'success'.tr,
      'User ${user.name} has been ${newStatus ? "activated" : "deactivated"}',
      snackPosition: SnackPosition.BOTTOM,
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
          TextButton(
            onPressed: () {
              // Mock implementation
              Get.back();
              Get.snackbar(
                'success'.tr,
                'User ${user.name} has been deleted',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }
}
