import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blapp/config/app_theme.dart';
import 'package:blapp/controllers/instructor_controller.dart';
import 'package:blapp/widgets/common/custom_card.dart';
import 'package:blapp/widgets/common/custom_button.dart';
import 'package:blapp/widgets/common/loading_widget.dart';
import 'package:blapp/models/course_model.dart';

class CreateCourseView extends StatefulWidget {
  const CreateCourseView({super.key});

  @override
  State<CreateCourseView> createState() => _CreateCourseViewState();
}

class _CreateCourseViewState extends State<CreateCourseView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedLevel = 'beginner';
  String _selectedCategory = 'technology';
  String? _selectedThumbnail;
  bool _isPublished = false;

  final List<String> _thumbnailOptions = [
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=300',
    'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=300',
    'https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?w=300',
    'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=300',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instructorController = Get.find<InstructorController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('create_course'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => _saveDraft(instructorController),
            child: Text(
              'save_draft'.tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (instructorController.isLoading.value) {
          return const LoadingWidget();
        }

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Basic Info Section
                _buildSectionHeader('course_information'.tr, Icons.info),
                const SizedBox(height: 12),
                _buildBasicInfoSection(),

                const SizedBox(height: 24),

                // Course Details Section
                _buildSectionHeader('course_details'.tr, Icons.details),
                const SizedBox(height: 12),
                _buildDetailsSection(),

                const SizedBox(height: 24),

                // Thumbnail Section
                _buildSectionHeader('course_thumbnail'.tr, Icons.image),
                const SizedBox(height: 12),
                _buildThumbnailSection(),

                const SizedBox(height: 24),

                // Publishing Options
                _buildSectionHeader('publishing_options'.tr, Icons.publish),
                const SizedBox(height: 12),
                _buildPublishingSection(),

                const SizedBox(height: 32),

                // Action Buttons
                _buildActionButtons(instructorController),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'course_title'.tr,
                hintText: 'enter_course_title'.tr,
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'please_enter_course_title'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'course_description'.tr,
                hintText: 'enter_detailed_description'.tr,
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'please_enter_course_description'.tr;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                // Use column layout on small screens, row on larger screens
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'price'.tr,
                          hintText: '0.00',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please_enter_price'.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _durationController,
                        decoration: InputDecoration(
                          labelText: 'duration_hours'.tr,
                          hintText: 'eg_10'.tr,
                          prefixIcon: const Icon(Icons.schedule),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please_enter_duration'.tr;
                          }
                          return null;
                        },
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'price'.tr,
                            hintText: '0.00',
                            prefixIcon: const Icon(Icons.attach_money),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter price';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          decoration: InputDecoration(
                            labelText: 'duration_hours'.tr,
                            hintText: 'e.g., 10',
                            prefixIcon: const Icon(Icons.schedule),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter duration';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                // Use Column layout for smaller screens
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedLevel,
                        decoration: InputDecoration(
                          labelText: 'course_level'.tr,
                          prefixIcon: const Icon(Icons.trending_up),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ['beginner', 'intermediate', 'advanced'].map((
                          level,
                        ) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(level.tr),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLevel = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'category'.tr,
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items:
                            [
                              'technology',
                              'business',
                              'design',
                              'marketing',
                              'science',
                              'language',
                            ].map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.tr),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ],
                  );
                } else {
                  // Use Row layout for larger screens
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedLevel,
                          decoration: InputDecoration(
                            labelText: 'course_level'.tr,
                            prefixIcon: const Icon(Icons.trending_up),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: ['beginner', 'intermediate', 'advanced'].map((
                            level,
                          ) {
                            return DropdownMenuItem(
                              value: level,
                              child: Text(level.tr),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLevel = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'category'.tr,
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items:
                              [
                                'technology',
                                'business',
                                'design',
                                'marketing',
                                'science',
                                'language',
                              ].map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category.tr),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailSection() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'select_thumbnail'.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid: 1 column on very small screens, 2 on medium, 3+ on large
                int crossAxisCount = 2;
                if (constraints.maxWidth < 400) {
                  crossAxisCount = 1;
                } else if (constraints.maxWidth > 800) {
                  crossAxisCount = 3;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _thumbnailOptions.length,
                  itemBuilder: (context, index) {
                    final thumbnail = _thumbnailOptions[index];
                    final isSelected = _selectedThumbnail == thumbnail;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedThumbnail = thumbnail;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.withValues(alpha: 0.3),
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Stack(
                            children: [
                              Image.network(
                                thumbnail,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                      child: const Icon(Icons.image),
                                    ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishingSection() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('publish_immediately'.tr),
              subtitle: Text(
                _isPublished
                    ? 'Course will be visible to students immediately'
                    : 'Course will be saved as draft',
                style: TextStyle(
                  color: AppTheme.textColor.withValues(alpha: 0.7),
                ),
              ),
              value: _isPublished,
              onChanged: (value) {
                setState(() {
                  _isPublished = value;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
            if (!_isPublished) ...[
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.info_outline,
                  color: AppTheme.warningColor,
                ),
                title: Text(
                  'draft_info'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'You can publish this course later from your course management',
                  style: TextStyle(
                    color: AppTheme.textColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(InstructorController controller) {
    return Column(
      children: [
        CustomButton(
          text: _isPublished ? 'create_and_publish'.tr : 'create_course'.tr,
          onPressed: () => _createCourse(controller),
          icon: _isPublished ? Icons.publish : Icons.add,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _previewCourse(),
          icon: const Icon(Icons.preview),
          label: Text('preview_course'.tr),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: const BorderSide(color: AppTheme.primaryColor),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  void _saveDraft(InstructorController controller) {
    if (_titleController.text.isNotEmpty) {
      // Save draft logic here
      Get.snackbar(
        'success'.tr,
        'Draft saved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _createCourse(InstructorController controller) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedThumbnail == null) {
        Get.snackbar(
          'error'.tr,
          'please_select_thumbnail'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      try {
        // Use the controller's createCourse method
        await controller.createCourse(
          _titleController.text,
          _descriptionController.text,
          _selectedCategory,
          thumbnail: _selectedThumbnail,
          isPublished: _isPublished,
        );

        // Clear form after successful creation
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedThumbnail = null;
          _selectedCategory = 'technology';
          _isPublished = false;
        });

        Get.snackbar(
          'success'.tr,
          _isPublished
              ? 'course_created_and_published_successfully'.tr
              : 'course_created_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'error'.tr,
          'failed_to_create_course'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void _previewCourse() {
    if (_titleController.text.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'please_enter_title_to_preview'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Preview course logic here
    Get.snackbar(
      'info'.tr,
      'Course preview feature coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
