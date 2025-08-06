import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/student_controller.dart';
import '../../models/forum_model.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/empty_state_widget.dart';

class ForumView extends StatefulWidget {
  const ForumView({super.key});

  @override
  State<ForumView> createState() => _ForumViewState();
}

class _ForumViewState extends State<ForumView> with TickerProviderStateMixin {
  late TabController _tabController;
  final StudentController controller = Get.find<StudentController>();
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('forum'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'all_posts'.tr),
            Tab(text: 'my_posts'.tr),
            Tab(text: 'discussions'.tr),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllPostsTab(),
          _buildMyPostsTab(),
          _buildDiscussionsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAllPostsTab() {
    final posts = _getMockForumPosts();
    
    if (posts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.forum_outlined,
        title: 'no_forum_posts'.tr,
        description: 'start_discussion'.tr,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildForumPostCard(post);
      },
    );
  }

  Widget _buildMyPostsTab() {
    final myPosts = _getMockForumPosts().where((post) => post.authorId == 'student_1').toList();
    
    if (myPosts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.post_add_outlined,
        title: 'no_posts_yet'.tr,
        description: 'create_first_post'.tr,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myPosts.length,
      itemBuilder: (context, index) {
        final post = myPosts[index];
        return _buildForumPostCard(post);
      },
    );
  }

  Widget _buildDiscussionsTab() {
    final discussions = _getMockForumPosts().where((post) => post.replies.isNotEmpty).toList();
    
    if (discussions.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.chat_bubble_outline,
        title: 'no_discussions'.tr,
        description: 'join_conversation'.tr,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: discussions.length,
      itemBuilder: (context, index) {
        final post = discussions[index];
        return _buildForumPostCard(post);
      },
    );
  }

  Widget _buildForumPostCard(ForumPostModel post) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  post.authorName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    Text(
                      _formatPostTime(post.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (post.courseId.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Course ${post.courseId}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Post title
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Post content
          Text(
            post.content,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textColor.withOpacity(0.8),
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 16),
          
          // Post actions
          Row(
            children: [
              _buildActionButton(
                icon: Icons.thumb_up_outlined,
                label: post.likesCount.toString(),
                onTap: () => _likePost(post),
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: post.replies.length.toString(),
                onTap: () => _showPostDetails(post),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showPostDetails(post),
                child: Column(
                  children: [
                    Text(
                      'view_details'.tr,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Course ${post.courseId}',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: AppTheme.textColor.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('create_post'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _postController,
              decoration: InputDecoration(
                labelText: 'post_title'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'post_content'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          CustomButton(
            text: 'post'.tr,
            type: ButtonType.primary,
            onPressed: () {
              _createPost();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showPostDetails(ForumPostModel post) {
    // Navigate to detailed post view with replies
    Get.snackbar(
      'post_details'.tr,
      'opening_post_details'.tr,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _createPost() {
    Get.snackbar(
      'post_created'.tr,
      'your_post_published'.tr,
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    _postController.clear();
  }

  void _likePost(ForumPostModel post) {
    Get.snackbar(
      'post_liked'.tr,
      'you_liked_post'.tr,
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  List<ForumPostModel> _getMockForumPosts() {
    return [
      ForumPostModel(
        id: 'post_1',
        title: 'How to handle state management in Flutter?',
        content: 'I\'m new to Flutter and struggling with state management. Can someone explain the difference between setState, Provider, and GetX?',
        authorId: 'student_2',
        authorName: 'Ahmed Hassan',
        courseId: 'course_1',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 5,
        replies: [
          ForumReplyModel(
            id: 'reply_1',
            postId: 'post_1',
            content: 'GetX is great for beginners! It\'s simple and powerful.',
            authorId: 'instructor_1',
            authorName: 'Dr. Sarah Johnson',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            likesCount: 3,
          ),
        ],
      ),
      ForumPostModel(
        id: 'post_2',
        title: 'Best practices for Flutter UI design',
        content: 'What are some best practices for creating beautiful and responsive UI in Flutter? Any recommended resources?',
        authorId: 'student_1',
        authorName: 'Current User',
        courseId: 'course_2',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likesCount: 8,
        replies: [],
      ),
      ForumPostModel(
        id: 'post_3',
        title: 'Question about quiz implementation',
        content: 'How can I implement a timer-based quiz system? Looking for guidance on the architecture.',
        authorId: 'student_3',
        authorName: 'Fatima Al-Zahra',
        courseId: 'course_1',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        likesCount: 3,
        replies: [
          ForumReplyModel(
            id: 'reply_2',
            postId: 'post_3',
            content: 'You can use Timer class from dart:async. Check the documentation for examples.',
            authorId: 'student_1',
            authorName: 'Current User',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            likesCount: 2,
          ),
        ],
      ),
    ];
  }

  String _formatPostTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just_now'.tr;
    }
  }
}
