import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/instructor_controller.dart';
import '../../models/quiz_model.dart';
import '../../models/course_model.dart';

class EditQuizView extends StatefulWidget {
  final QuizModel quiz;
  final CourseModel course;

  const EditQuizView({super.key, required this.quiz, required this.course});

  @override
  State<EditQuizView> createState() => _EditQuizViewState();
}

class _EditQuizViewState extends State<EditQuizView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _timeLimitController;
  late TextEditingController _passingScoreController;

  final List<QuestionData> _questions = [];
  int _currentQuestionIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize controllers with existing quiz data
    _titleController = TextEditingController(text: widget.quiz.title);
    _descriptionController = TextEditingController(
      text: widget.quiz.description,
    );
    _timeLimitController = TextEditingController(
      text: widget.quiz.timeLimit.toString(),
    );
    _passingScoreController = TextEditingController(
      text: widget.quiz.passingScore.toString(),
    );

    // Load existing questions
    _loadExistingQuestions();

    print('📝 EditQuizView initialized for quiz: ${widget.quiz.title}');
    print('📊 Loaded ${widget.quiz.questions.length} existing questions');
  }

  void _loadExistingQuestions() {
    print('📝 Loading ${widget.quiz.questions.length} existing questions...');

    for (int index = 0; index < widget.quiz.questions.length; index++) {
      final question = widget.quiz.questions[index];
      final questionData = QuestionData();

      print('   Question ${index + 1}: ${question.question}');
      questionData.questionController.text = question.question;

      // Load options
      for (int i = 0; i < question.options.length && i < 4; i++) {
        questionData.optionControllers[i].text = question.options[i];
        print('     Option ${i + 1}: ${question.options[i]}');
      }

      questionData.correctAnswerIndex = question.correctAnswerIndex;
      questionData.explanationController.text = question.explanation;

      print('     Correct answer: ${question.correctAnswerIndex + 1}');
      print('     Explanation: ${question.explanation}');

      _questions.add(questionData);
    }

    if (_questions.isEmpty) {
      print('⚠️ No existing questions found, adding new question');
      _addNewQuestion();
    } else {
      print('✅ Loaded ${_questions.length} questions successfully');
      // Trigger UI update to show loaded questions
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeLimitController.dispose();
    _passingScoreController.dispose();
    _tabController.dispose();
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
    print('➕ Added new question. Total questions: ${_questions.length}');
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
      print(
        '🗑️ Removed question ${index + 1}. Total questions: ${_questions.length}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'edit_quiz'.tr,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              widget.course.title,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_questions.length} ${'questions'.tr}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'editing_quiz_details_and_questions'.tr,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primaryColor,
                tabs: [
                  Tab(icon: const Icon(Icons.info), text: 'quiz_info'.tr),
                  Tab(icon: const Icon(Icons.quiz), text: 'questions'.tr),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildQuizInfoTab(), _buildQuestionsTab()],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
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
                    flex: 2,
                    child: Obx(() {
                      final controller = Get.find<InstructorController>();
                      return ElevatedButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : _updateQuiz,
                        icon: controller.isLoading.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          controller.isLoading.value
                              ? 'updating'.tr
                              : 'update_quiz'.tr,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 48),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quiz Title
          Text(
            'quiz_title'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'enter_quiz_title'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'please_enter_quiz_title'.tr;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Quiz Description
          Text(
            'quiz_description'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'enter_quiz_description'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.description),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'please_enter_quiz_description'.tr;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Time Limit and Passing Score Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'time_limit_minutes'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _timeLimitController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '30',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.timer),
                        suffixText: 'min',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'required'.tr;
                        }
                        final number = int.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'invalid_number'.tr;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'passing_score_percent'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passingScoreController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '70',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.grade),
                        suffixText: '%',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'required'.tr;
                        }
                        final number = int.tryParse(value);
                        if (number == null || number <= 0 || number > 100) {
                          return 'invalid_percentage'.tr;
                        }
                        return null;
                      },
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

  Widget _buildQuestionsTab() {
    return Column(
      children: [
        // Questions Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'questions_list'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addNewQuestion,
                icon: const Icon(Icons.add, size: 16),
                label: Text('add_question'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Questions List
        Expanded(
          child: _questions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'no_questions_yet'.tr,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'add_questions_to_quiz'.tr,
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    return _buildQuestionCard(index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = _questions[index];
    final isSelected = index == _currentQuestionIndex;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          question.questionController.text.isEmpty
              ? '${'question'.tr} ${index + 1}'
              : question.questionController.text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
          ),
        ),
        subtitle: Text(
          '${question.optionControllers.where((c) => c.text.isNotEmpty).length}/4 ${'options'.tr}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (question.correctAnswerIndex != -1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'valid'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            if (_questions.length > 1)
              IconButton(
                onPressed: () => _removeQuestion(index),
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildQuestionForm(question, index),
          ),
        ],
        onExpansionChanged: (expanded) {
          if (expanded) {
            setState(() {
              _currentQuestionIndex = index;
            });
          }
        },
      ),
    );
  }

  Widget _buildQuestionForm(QuestionData question, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Text
        Text(
          'question_text'.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: question.questionController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'enter_your_question'.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'please_enter_question'.tr;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Options
        Text(
          'answer_options'.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
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
                    print(
                      '✅ Set correct answer for question ${index + 1}: Option ${value! + 1}',
                    );
                  },
                  activeColor: AppTheme.primaryColor,
                ),
                Expanded(
                  child: TextFormField(
                    controller: question.optionControllers[optionIndex],
                    decoration: InputDecoration(
                      hintText: '${'option'.tr} ${optionIndex + 1}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    validator: (value) {
                      if (optionIndex < 2 &&
                          (value == null || value.trim().isEmpty)) {
                        return 'required'.tr;
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
        Text(
          'explanation_optional'.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: question.explanationController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'explain_correct_answer'.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  void _updateQuiz() async {
    print('🎯 Update Quiz button pressed');
    print('📋 Form validation starting...');

    // Validate quiz info manually if form key is not available
    if (!_validateQuizInfo()) {
      print('❌ Quiz info validation failed');
      _tabController.animateTo(0); // Go to quiz info tab
      return;
    }

    // Also try form validation if available
    if (_formKey.currentState != null) {
      if (!_formKey.currentState!.validate()) {
        print('❌ Form validation failed');
        _tabController.animateTo(0); // Go to quiz info tab
        return;
      }
    }

    print('✅ Quiz info form validation passed');

    // Validate that all questions have at least one correct answer marked
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      if (question.questionController.text.trim().isEmpty) {
        print('❌ Question ${i + 1} is empty');
        Get.snackbar(
          'error'.tr,
          '${'question'.tr} ${i + 1}: ${'please_enter_question'.tr}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        _tabController.animateTo(1); // Go to questions tab
        return;
      }

      if (question.correctAnswerIndex == -1) {
        print('❌ Question ${i + 1} has no correct answer selected');
        Get.snackbar(
          'error'.tr,
          '${'question'.tr} ${i + 1}: ${'select_correct_answer'.tr}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        _tabController.animateTo(1); // Go to questions tab
        return;
      }
    }

    print('✅ All questions validation passed');
    print('📊 Quiz update details:');
    print('   Title: ${_titleController.text.trim()}');
    print('   Description: ${_descriptionController.text.trim()}');
    print('   Questions: ${_questions.length}');
    print('   Time limit: ${_timeLimitController.text} minutes');
    print('   Passing score: ${_passingScoreController.text}%');

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

    // Create updated quiz model
    final updatedQuiz = widget.quiz.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      questions: questions,
      timeLimit: int.parse(_timeLimitController.text),
      passingScore: int.parse(_passingScoreController.text),
    );

    print('🚀 Calling instructorController.updateQuiz...');
    await instructorController.updateQuiz(widget.course.id, updatedQuiz);

    print('🔙 Closing edit quiz screen...');
    Get.back();
  }

  bool _validateQuizInfo() {
    print('📋 Manual quiz info validation...');

    // Validate title
    if (_titleController.text.trim().isEmpty) {
      print('❌ Quiz title is empty');
      Get.snackbar(
        'error'.tr,
        'please_enter_quiz_title'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Validate description
    if (_descriptionController.text.trim().isEmpty) {
      print('❌ Quiz description is empty');
      Get.snackbar(
        'error'.tr,
        'please_enter_quiz_description'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Validate time limit
    final timeLimit = int.tryParse(_timeLimitController.text);
    if (timeLimit == null || timeLimit <= 0) {
      print('❌ Invalid time limit: ${_timeLimitController.text}');
      Get.snackbar(
        'error'.tr,
        'invalid_time_limit'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Validate passing score
    final passingScore = int.tryParse(_passingScoreController.text);
    if (passingScore == null || passingScore <= 0 || passingScore > 100) {
      print('❌ Invalid passing score: ${_passingScoreController.text}');
      Get.snackbar(
        'error'.tr,
        'invalid_passing_score'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    print('✅ Manual quiz info validation passed');
    return true;
  }
}

// Question Data Class (reused from create_quiz_view.dart)
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
