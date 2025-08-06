import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blapp/config/app_theme.dart';
import 'package:blapp/controllers/admin_controller.dart';
import 'package:blapp/controllers/navigation_controller.dart';
import 'package:blapp/widgets/common/custom_card.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';

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
        title: Text('analytics'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'week', child: Text('this_week'.tr)),
              PopupMenuItem(value: 'month', child: Text('this_month'.tr)),
              PopupMenuItem(value: 'year', child: Text('this_year'.tr)),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getPeriodText()),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
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
            Tab(text: 'overview'.tr),
            Tab(text: 'users'.tr),
            Tab(text: 'courses'.tr),
            Tab(text: 'revenue'.tr),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildUsersTab(),
          _buildCoursesTab(),
          _buildRevenueTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'total_users'.tr,
                  '1,234',
                  '+12%',
                  Icons.people,
                  AppTheme.primaryColor,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'active_courses'.tr,
                  '89',
                  '+5%',
                  Icons.school,
                  AppTheme.accentColor,
                  isPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'total_revenue'.tr,
                  '\$45,678',
                  '+18%',
                  Icons.attach_money,
                  AppTheme.warningColor,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'completion_rate'.tr,
                  '78%',
                  '-2%',
                  Icons.trending_up,
                  Colors.purple,
                  isPositive: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity
          Text(
            'recent_activity'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildActivityList(),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'quick_actions'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Statistics
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'new_users'.tr,
                  '156',
                  '+23%',
                  Icons.person_add,
                  AppTheme.accentColor,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'active_users'.tr,
                  '892',
                  '+8%',
                  Icons.people_alt,
                  AppTheme.primaryColor,
                  isPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'students'.tr,
                  '1,045',
                  '+15%',
                  Icons.school,
                  Colors.blue,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'instructors'.tr,
                  '67',
                  '+3%',
                  Icons.person,
                  AppTheme.warningColor,
                  isPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // User Distribution Chart
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'user_distribution'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildUserDistributionChart(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Statistics
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'published_courses'.tr,
                  '89',
                  '+12%',
                  Icons.publish,
                  AppTheme.accentColor,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'pending_approval'.tr,
                  '15',
                  '+5%',
                  Icons.pending,
                  AppTheme.warningColor,
                  isPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'total_enrollments'.tr,
                  '3,456',
                  '+28%',
                  Icons.how_to_reg,
                  AppTheme.primaryColor,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'avg_rating'.tr,
                  '4.6',
                  '+0.2',
                  Icons.star,
                  Colors.orange,
                  isPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Popular Categories
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'popular_categories'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryChart(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Statistics
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'total_revenue'.tr,
                  '\$45,678',
                  '+18%',
                  Icons.attach_money,
                  AppTheme.accentColor,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'monthly_revenue'.tr,
                  '\$12,345',
                  '+25%',
                  Icons.trending_up,
                  AppTheme.primaryColor,
                  isPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'avg_course_price'.tr,
                  '\$89',
                  '+5%',
                  Icons.local_offer,
                  AppTheme.warningColor,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'conversion_rate'.tr,
                  '12.5%',
                  '+2.1%',
                  Icons.transform,
                  Colors.purple,
                  isPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Revenue Chart
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'revenue_trend'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRevenueChart(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color color, {
    required bool isPositive,
  }) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppTheme.accentColor : Colors.red)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: isPositive ? AppTheme.accentColor : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        change,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? AppTheme.accentColor : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    final activities = [
      {
        'title': 'New user registered',
        'subtitle': 'Ahmed Ali joined as Student',
        'time': '2 min ago',
        'icon': Icons.person_add,
        'color': AppTheme.accentColor,
      },
      {
        'title': 'Course approved',
        'subtitle': 'Flutter Development by Sara Mohammed',
        'time': '15 min ago',
        'icon': Icons.check_circle,
        'color': AppTheme.accentColor,
      },
      {
        'title': 'New enrollment',
        'subtitle': 'UI/UX Design - 5 new students',
        'time': '1 hour ago',
        'icon': Icons.school,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'Payment received',
        'subtitle': 'Course purchase - \$89',
        'time': '2 hours ago',
        'icon': Icons.payment,
        'color': AppTheme.warningColor,
      },
    ];

    return CustomCard(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: (activity['color'] as Color).withValues(
                alpha: 0.1,
              ),
              child: Icon(
                activity['icon'] as IconData,
                color: activity['color'] as Color,
                size: 20,
              ),
            ),
            title: Text(
              activity['title'] as String,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              activity['subtitle'] as String,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textColor.withValues(alpha: 0.7),
              ),
            ),
            trailing: Text(
              activity['time'] as String,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textColor.withValues(alpha: 0.5),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    final navController = Get.find<NavigationController>();

    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            'manage_users'.tr,
            Icons.people,
            AppTheme.primaryColor,
            () => navController.navigateAdmin(1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            'approve_courses'.tr,
            Icons.approval,
            AppTheme.accentColor,
            () => navController.navigateAdmin(2),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserDistributionChart() {
    return Column(
      children: [
        _buildProgressBar('students'.tr, 0.75, AppTheme.primaryColor),
        const SizedBox(height: 8),
        _buildProgressBar('instructors'.tr, 0.15, AppTheme.warningColor),
        const SizedBox(height: 8),
        _buildProgressBar('admins'.tr, 0.10, Colors.purple),
      ],
    );
  }

  Widget _buildCategoryChart() {
    return Column(
      children: [
        _buildProgressBar('technology'.tr, 0.40, AppTheme.primaryColor),
        const SizedBox(height: 8),
        _buildProgressBar('design'.tr, 0.25, AppTheme.accentColor),
        const SizedBox(height: 8),
        _buildProgressBar('business'.tr, 0.20, AppTheme.warningColor),
        const SizedBox(height: 8),
        _buildProgressBar('marketing'.tr, 0.15, Colors.purple),
      ],
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: AppTheme.textColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'revenue_chart_placeholder'.tr,
              style: TextStyle(
                color: AppTheme.textColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _getPeriodText() {
    switch (_selectedPeriod) {
      case 'week':
        return 'this_week'.tr;
      case 'month':
        return 'this_month'.tr;
      case 'year':
        return 'this_year'.tr;
      default:
        return 'this_week'.tr;
    }
  }
}
