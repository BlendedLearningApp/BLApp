import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../config/app_theme.dart';
import '../../controllers/student_controller.dart';
import '../../models/quiz_model.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/custom_button.dart';

class QuizView extends StatefulWidget {
  const QuizView({super.key});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  final StudentController controller = Get.find<StudentController>();
  QuizModel? currentQuiz;
  int currentQuestionIndex = 0;
  List<int?> selectedAnswers = [];
  Timer? _timer;
  int remainingTimeInSeconds = 0;
  bool isQuizCompleted = false;
  int? finalScore;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  void _initializeQuiz() {
    final quizId = Get.arguments as String?;
    if (quizId != null) {
      // Find quiz from enrolled courses
      for (final course in controller.enrolledCourses) {
        final quiz = course.quizzes.firstWhere(
          (q) => q.id == quizId,
          orElse: () => QuizModel(
            id: '',
            title: '',
            description: '',
            courseId: '',
            timeLimit: 0,
            passingScore: 0,
            createdAt: DateTime.now(),
            questions: [],
          ),
        );
        if (quiz.id.isNotEmpty) {
          currentQuiz = quiz;
          break;
        }
      }
    }

    if (currentQuiz != null) {
      selectedAnswers = List.filled(currentQuiz!.questions.length, null);
      remainingTimeInSeconds = currentQuiz!.timeLimit * 60;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTimeInSeconds > 0) {
        setState(() {
          remainingTimeInSeconds--;
        });
      } else {
        _submitQuiz();
      }
    });
  }

  void _submitQuiz() {
    _timer?.cancel();
    
    // Calculate score
    int correctAnswers = 0;
    for (int i = 0; i < currentQuiz!.questions.length; i++) {
      if (selectedAnswers[i] == currentQuiz!.questions[i].correctAnswerIndex) {
        correctAnswers++;
      }
    }
    
    finalScore = (correctAnswers / currentQuiz!.questions.length * 100).round();
    
    setState(() {
      isQuizCompleted = true;
    });

    // Show completion dialog
    _showQuizCompletionDialog();
  }

  void _showQuizCompletionDialog() {
    final passed = finalScore! >= currentQuiz!.passingScore;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          passed ? 'quiz_passed'.tr : 'quiz_failed'.tr,
          style: TextStyle(
            color: passed ? AppTheme.accentColor : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.check_circle : Icons.cancel,
              size: 64,
              color: passed ? AppTheme.accentColor : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'your_score'.tr + ': $finalScore%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'passing_score'.tr + ': ${currentQuiz!.passingScore}%',
              style: TextStyle(
                color: AppTheme.textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'view_results'.tr,
            type: ButtonType.outline,
            onPressed: () {
              Navigator.of(context).pop();
              // Stay on quiz view to show results
            },
          ),
          CustomButton(
            text: 'back_to_course'.tr,
            type: ButtonType.primary,
            onPressed: () {
              Navigator.of(context).pop();
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuiz == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('quiz'.tr),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(
            'quiz_not_found'.tr,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    if (isQuizCompleted) {
      return _buildQuizResultsView();
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(currentQuiz!.title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(
              child: Text(
                _formatTime(remainingTimeInSeconds),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'question'.tr + ' ${currentQuestionIndex + 1} of ${currentQuiz!.questions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    Text(
                      '${((currentQuestionIndex + 1) / currentQuiz!.questions.length * 100).round()}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / currentQuiz!.questions.length,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ],
            ),
          ),
          
          // Question content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildQuestionView(),
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (currentQuestionIndex > 0)
                  Expanded(
                    child: CustomButton(
                      text: 'previous'.tr,
                      type: ButtonType.outline,
                      onPressed: () {
                        setState(() {
                          currentQuestionIndex--;
                        });
                      },
                    ),
                  ),
                if (currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: currentQuestionIndex == currentQuiz!.questions.length - 1
                        ? 'submit_quiz'.tr
                        : 'next'.tr,
                    type: ButtonType.primary,
                    onPressed: selectedAnswers[currentQuestionIndex] != null
                        ? () {
                            if (currentQuestionIndex == currentQuiz!.questions.length - 1) {
                              _submitQuiz();
                            } else {
                              setState(() {
                                currentQuestionIndex++;
                              });
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView() {
    final question = currentQuiz!.questions[currentQuestionIndex];
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // Answer options
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedAnswers[currentQuestionIndex] == index;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedAnswers[currentQuestionIndex] = index;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected 
                          ? AppTheme.primaryColor 
                          : AppTheme.textColor.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected 
                        ? AppTheme.primaryColor.withOpacity(0.1) 
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? AppTheme.primaryColor 
                                : AppTheme.textColor.withOpacity(0.4),
                            width: 2,
                          ),
                          color: isSelected 
                              ? AppTheme.primaryColor 
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected 
                                ? AppTheme.primaryColor 
                                : AppTheme.textColor,
                            fontWeight: isSelected 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuizResultsView() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('quiz_results'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score summary
            CustomCard(
              child: Column(
                children: [
                  Icon(
                    finalScore! >= currentQuiz!.passingScore 
                        ? Icons.check_circle 
                        : Icons.cancel,
                    size: 64,
                    color: finalScore! >= currentQuiz!.passingScore 
                        ? AppTheme.accentColor 
                        : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$finalScore%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  Text(
                    finalScore! >= currentQuiz!.passingScore 
                        ? 'quiz_passed'.tr 
                        : 'quiz_failed'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: finalScore! >= currentQuiz!.passingScore 
                          ? AppTheme.accentColor 
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            CustomButton(
              text: 'back_to_course'.tr,
              type: ButtonType.primary,
              width: double.infinity,
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
