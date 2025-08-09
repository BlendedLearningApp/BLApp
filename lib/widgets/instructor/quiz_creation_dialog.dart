import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/instructor_controller.dart';
import '../../models/quiz_model.dart';
import '../../models/course_model.dart';

class QuizCreationDialog extends StatefulWidget {
  final CourseModel course;

  const QuizCreationDialog({super.key, required this.course});

  @override
  State<QuizCreationDialog> createState() => _QuizCreationDialogState();
}

class _QuizCreationDialogState extends State<QuizCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeLimitController = TextEditingController(text: '30');
  final _passingScoreController = TextEditingController(text: '70');

  final List<QuestionData> _questions = [];
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _addNewQuestion();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeLimitController.dispose();
    _passingScoreController.dispose();
    for (final question in _questions) {
      question.dispose();
    }
    super.dispose();
  }

  void _addNewQuestion() {
    setState(() {
      _questions.add(QuestionData());
      _currentQuestionIndex = _questions.length - 1;
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length > 1) {
      setState(() {
        _questions[index].dispose();
        _questions.removeAt(index);
        if (_currentQuestionIndex >= _questions.length) {
          _currentQuestionIndex = _questions.length - 1;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: Get.width * 0.95,
        height: Get.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuizBasicInfo(),
                      const SizedBox(height: 24),
                      _buildQuestionsSection(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.quiz, color: AppTheme.primaryColor, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'create_quiz'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              Text(
                'create_quiz_for_course'.tr,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
      ],
    );
  }

  Widget _buildQuizBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Course info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.school, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${'course'.tr}: ${widget.course.title}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quiz title
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'quiz_title'.tr,
            hintText: 'enter_quiz_title'.tr,
            prefixIcon: const Icon(Icons.title),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'quiz_title_required'.tr;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Quiz description
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'quiz_description'.tr,
            hintText: 'enter_quiz_description'.tr,
            prefixIcon: const Icon(Icons.description),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'quiz_description_required'.tr;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Time limit and passing score
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _timeLimitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'time_limit_minutes'.tr,
                  prefixIcon: const Icon(Icons.timer),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'time_limit_required'.tr;
                  }
                  final timeLimit = int.tryParse(value);
                  if (timeLimit == null || timeLimit <= 0) {
                    return 'invalid_time_limit'.tr;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _passingScoreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'passing_score_percent'.tr,
                  prefixIcon: const Icon(Icons.percent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'passing_score_required'.tr;
                  }
                  final score = int.tryParse(value);
                  if (score == null || score < 0 || score > 100) {
                    return 'invalid_passing_score'.tr;
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'questions'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addNewQuestion,
              icon: const Icon(Icons.add, size: 18),
              label: Text('add_question'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_questions.isNotEmpty) ...[
          // Question tabs
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final isSelected = index == _currentQuestionIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentQuestionIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${'question'.tr} ${index + 1}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Current question editor
          _buildQuestionEditor(
            _questions[_currentQuestionIndex],
            _currentQuestionIndex,
          ),
        ],
      ],
    );
  }

  Widget _buildQuestionEditor(QuestionData question, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${'question'.tr} ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_questions.length > 1)
                IconButton(
                  onPressed: () => _removeQuestion(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Question text
          TextFormField(
            controller: question.questionController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'question_text'.tr,
              hintText: 'enter_your_question'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'question_text_required'.tr;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Answer options
          Text(
            'answer_options'.tr,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          ...List.generate(4, (optionIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Radio<int>(
                    value: optionIndex,
                    groupValue: question.correctAnswerIndex,
                    onChanged: (value) {
                      setState(() {
                        question.correctAnswerIndex = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: question.optionControllers[optionIndex],
                      decoration: InputDecoration(
                        labelText: '${'option'.tr} ${optionIndex + 1}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'option_required'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Explanation (optional)
          TextFormField(
            controller: question.explanationController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'explanation_optional'.tr,
              hintText: 'explain_correct_answer'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(0, 48),
            ),
            child: Text('cancel'.tr),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GetBuilder<InstructorController>(
            builder: (controller) => ElevatedButton(
              onPressed: controller.isLoading.value ? null : _createQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(0, 48),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('create_quiz'.tr),
            ),
          ),
        ),
      ],
    );
  }

  void _createQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate that all questions have at least one correct answer marked
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      if (question.correctAnswerIndex == -1) {
        Get.snackbar(
          'error'.tr,
          '${'question'.tr} ${i + 1}: ${'select_correct_answer'.tr}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    final instructorController = Get.find<InstructorController>();

    // Convert QuestionData to QuestionModel
    final questions = _questions
        .map(
          (q) => QuestionModel(
            id: '',
            question: q.questionController.text.trim(),
            options: q.optionControllers.map((c) => c.text.trim()).toList(),
            correctAnswerIndex: q.correctAnswerIndex,
            explanation: q.explanationController.text.trim(),
            points: 1,
          ),
        )
        .toList();

    await instructorController.createQuiz(
      widget.course.id,
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      questions,
      int.parse(_timeLimitController.text),
      int.parse(_passingScoreController.text),
    );

    Get.back();
  }
}

class QuestionData {
  final TextEditingController questionController = TextEditingController();
  final List<TextEditingController> optionControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final TextEditingController explanationController = TextEditingController();
  int correctAnswerIndex = -1;

  void dispose() {
    questionController.dispose();
    for (final controller in optionControllers) {
      controller.dispose();
    }
    explanationController.dispose();
  }
}
