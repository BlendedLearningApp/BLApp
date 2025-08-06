import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../config/app_theme.dart';
import '../../controllers/student_controller.dart';
import '../../models/quiz_model.dart';


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
      body: const Center(
        child: Text('Quiz implementation - See quiz_view_complete.dart for full version'),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
