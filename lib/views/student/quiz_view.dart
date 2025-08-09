import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../config/app_theme.dart';
import '../../controllers/student_controller.dart';
import '../../models/quiz_model.dart';

import '../../services/supabase_service.dart';

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

  void _initializeQuiz() async {
    final quizId = Get.arguments as String?;
    if (quizId == null) {
      print('❌ No quiz ID provided');
      return;
    }

    try {
      print('🔍 Loading quiz with ID: $quizId');

      // First try to find quiz in enrolled courses (faster)
      for (final course in controller.enrolledCourses) {
        try {
          final quiz = course.quizzes.firstWhere((q) => q.id == quizId);
          if (quiz.id.isNotEmpty && quiz.questions.isNotEmpty) {
            print('✅ Found quiz in enrolled courses: ${quiz.title}');
            currentQuiz = quiz;
            break;
          }
        } catch (e) {
          // Quiz not found in this course, continue searching
          continue;
        }
      }

      // If not found in enrolled courses, fetch from database
      if (currentQuiz == null) {
        print(
          '🔍 Quiz not found in enrolled courses, fetching from database...',
        );
        final quiz = await SupabaseService.getQuizWithQuestions(quizId);
        if (quiz != null && quiz.questions.isNotEmpty) {
          print('✅ Found quiz in database: ${quiz.title}');
          currentQuiz = quiz;
        }
      }

      // Validate quiz data before proceeding
      if (currentQuiz != null && currentQuiz!.questions.isNotEmpty) {
        selectedAnswers = List.filled(currentQuiz!.questions.length, null);
        remainingTimeInSeconds = currentQuiz!.timeLimit * 60;
        _startTimer();
        print(
          '✅ Quiz initialized successfully with ${currentQuiz!.questions.length} questions',
        );
      } else {
        // Quiz not found or has no questions
        print('❌ Quiz not found or has no questions: $quizId');
      }
    } catch (e) {
      print('❌ Error initializing quiz: $e');
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

  void _handleNextQuestion() {
    if (currentQuiz == null || currentQuiz!.questions.isEmpty) return;

    if (currentQuestionIndex < currentQuiz!.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _showSubmitConfirmation();
    }
  }

  void _showSubmitConfirmation() {
    final unansweredCount = selectedAnswers
        .where((answer) => answer == null)
        .length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('submit_quiz'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('submit_quiz_confirmation'.tr),
            if (unansweredCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.warningColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppTheme.warningColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'unanswered_questions'.tr.replaceAll(
                          '{count}',
                          '$unansweredCount',
                        ),
                        style: TextStyle(
                          color: AppTheme.warningColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('review'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('submit'.tr),
          ),
        ],
      ),
    );
  }

  void _submitQuiz() async {
    _timer?.cancel();

    // Calculate score
    int correctAnswers = 0;
    int totalPoints = 0;
    int earnedPoints = 0;

    for (int i = 0; i < currentQuiz!.questions.length; i++) {
      totalPoints += currentQuiz!.questions[i].points;
      if (selectedAnswers[i] == currentQuiz!.questions[i].correctAnswerIndex) {
        correctAnswers++;
        earnedPoints += currentQuiz!.questions[i].points;
      }
    }

    finalScore = (correctAnswers / currentQuiz!.questions.length * 100).round();
    final isPassed = finalScore! >= currentQuiz!.passingScore;

    // Submit to backend
    try {
      final answers = <String, int>{};
      for (int i = 0; i < selectedAnswers.length; i++) {
        if (selectedAnswers[i] != null) {
          answers[currentQuiz!.questions[i].id] = selectedAnswers[i]!;
        }
      }

      final timeSpent = (currentQuiz!.timeLimit * 60) - remainingTimeInSeconds;
      await controller.submitQuiz(currentQuiz!.id, answers);

      // Update local state
      setState(() {
        isQuizCompleted = true;
      });
    } catch (e) {
      // Handle error but still show results
      setState(() {
        isQuizCompleted = true;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuiz == null || currentQuiz!.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('quiz'.tr),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 64,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                currentQuiz == null
                    ? 'quiz_not_found'.tr
                    : 'quiz_has_no_questions'.tr,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('go_back'.tr),
              ),
            ],
          ),
        ),
      );
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
      body: isQuizCompleted ? _buildResultsView() : _buildQuizView(),
    );
  }

  Widget _buildQuizView() {
    return Column(
      children: [
        // Progress Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Progress Bar
              Row(
                children: [
                  Text(
                    'question'.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${currentQuestionIndex + 1}/${currentQuiz!.questions.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'time_remaining'.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: remainingTimeInSeconds < 300
                          ? AppTheme.errorColor.withValues(alpha: 0.1)
                          : AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatTime(remainingTimeInSeconds),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: remainingTimeInSeconds < 300
                            ? AppTheme.errorColor
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value:
                    (currentQuestionIndex + 1) / currentQuiz!.questions.length,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
                minHeight: 6,
              ),
            ],
          ),
        ),

        // Question Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildQuestionCard(),
          ),
        ),

        // Navigation Buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (currentQuestionIndex > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex--;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('previous'.tr),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                flex: currentQuestionIndex > 0 ? 1 : 2,
                child: ElevatedButton(
                  onPressed: _handleNextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    currentQuestionIndex < currentQuiz!.questions.length - 1
                        ? 'next'.tr
                        : 'submit_quiz'.tr,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    // Validate bounds before accessing question
    if (currentQuiz == null ||
        currentQuiz!.questions.isEmpty ||
        currentQuestionIndex >= currentQuiz!.questions.length ||
        currentQuestionIndex < 0) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'question_not_available'.tr,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    final question = currentQuiz!.questions[currentQuestionIndex];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${currentQuestionIndex + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'question_points'.tr.replaceAll(
                      '{points}',
                      '${question.points}',
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Question Text
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Answer Options
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
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
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
      ),
    );
  }

  Widget _buildResultsView() {
    final correctAnswers = selectedAnswers
        .asMap()
        .entries
        .where(
          (entry) =>
              entry.value ==
              currentQuiz!.questions[entry.key].correctAnswerIndex,
        )
        .length;
    final totalQuestions = currentQuiz!.questions.length;
    final isPassed = finalScore! >= currentQuiz!.passingScore;
    final timeSpent = (currentQuiz!.timeLimit * 60) - remainingTimeInSeconds;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Results Header
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPassed
                      ? [
                          AppTheme.successColor,
                          AppTheme.successColor.withValues(alpha: 0.8),
                        ]
                      : [
                          AppTheme.errorColor,
                          AppTheme.errorColor.withValues(alpha: 0.8),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    isPassed ? Icons.celebration : Icons.sentiment_dissatisfied,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPassed ? 'quiz_passed'.tr : 'quiz_failed'.tr,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$finalScore%',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPassed
                        ? 'congratulations_message'.tr
                        : 'better_luck_message'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  title: 'correct_answers'.tr,
                  value: '$correctAnswers/$totalQuestions',
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.access_time,
                  title: 'time_taken'.tr,
                  value: _formatTime(timeSpent),
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.flag,
                  title: 'passing_score'.tr,
                  value: '${currentQuiz!.passingScore}%',
                  color: AppTheme.warningColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: isPassed ? Icons.trending_up : Icons.trending_down,
                  title: 'result'.tr,
                  value: isPassed ? 'passed'.tr : 'failed'.tr,
                  color: isPassed ? AppTheme.successColor : AppTheme.errorColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Question Review
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'question_review'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...currentQuiz!.questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    final selectedAnswer = selectedAnswers[index];
                    final isCorrect =
                        selectedAnswer == question.correctAnswerIndex;

                    return _buildQuestionReviewItem(
                      questionNumber: index + 1,
                      question: question.question,
                      selectedAnswer: selectedAnswer,
                      correctAnswer: question.correctAnswerIndex,
                      options: question.options,
                      isCorrect: isCorrect,
                      explanation: question.explanation,
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('back_to_course'.tr),
                ),
              ),
              if (!isPassed) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Reset quiz for retake
                      setState(() {
                        currentQuestionIndex = 0;
                        selectedAnswers = List.filled(
                          currentQuiz!.questions.length,
                          null,
                        );
                        remainingTimeInSeconds = currentQuiz!.timeLimit * 60;
                        isQuizCompleted = false;
                        finalScore = null;
                      });
                      _startTimer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('retake_quiz'.tr),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textColor.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionReviewItem({
    required int questionNumber,
    required String question,
    required int? selectedAnswer,
    required int correctAnswer,
    required List<String> options,
    required bool isCorrect,
    required String explanation,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppTheme.successColor.withValues(alpha: 0.05)
            : AppTheme.errorColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect
              ? AppTheme.successColor.withValues(alpha: 0.3)
              : AppTheme.errorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCorrect ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'question_number'.tr.replaceAll('{number}', '$questionNumber'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: const TextStyle(fontSize: 14, color: AppTheme.textColor),
          ),
          const SizedBox(height: 12),

          // Show selected and correct answers
          if (selectedAnswer != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCorrect
                    ? AppTheme.successColor.withValues(alpha: 0.1)
                    : AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${'your_answer'.tr}: ${options[selectedAnswer]}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isCorrect
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.help, color: AppTheme.warningColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'no_answer_selected'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (!isCorrect) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: AppTheme.successColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${'correct_answer'.tr}: ${options[correctAnswer]}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (explanation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: AppTheme.primaryColor, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'explanation'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    explanation,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
