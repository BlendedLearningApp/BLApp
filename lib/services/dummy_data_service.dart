import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/video_model.dart';
import '../models/quiz_model.dart';
import '../models/worksheet_model.dart';
import '../models/forum_model.dart';

class DummyDataService {
  // Dummy Users
  static final List<UserModel> _users = [
    // Students
    UserModel(
      id: '1',
      email: 'student@blapp.com',
      name: 'Ahmed Al-Rashid',
      role: UserRole.student,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      profileImage: 'https://via.placeholder.com/150',
      isActive: true,
    ),
    UserModel(
      id: '4',
      email: 'layla.hassan@blapp.com',
      name: 'Layla Hassan',
      role: UserRole.student,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      profileImage: 'https://via.placeholder.com/150',
      isActive: true,
    ),
    UserModel(
      id: '5',
      email: 'omar.khalil@blapp.com',
      name: 'Omar Khalil',
      role: UserRole.student,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      profileImage: 'https://via.placeholder.com/150',
      isActive: true,
    ),
    UserModel(
      id: '6',
      email: 'fatima.ali@blapp.com',
      name: 'Fatima Ali',
      role: UserRole.student,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      profileImage: 'https://via.placeholder.com/150',
      isActive: true,
    ),

    // Instructors
    UserModel(
      id: '2',
      email: 'instructor@blapp.com',
      name: 'Dr. Sarah Johnson',
      role: UserRole.instructor,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      profileImage: 'https://via.placeholder.com/150',
      isActive: true,
    ),
    UserModel(
      id: '7',
      email: 'prof.ahmad@blapp.com',
      name: 'Prof. Ahmad Mahmoud',
      role: UserRole.instructor,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      profileImage: 'https://via.placeholder.com/150',
      isActive: true,
    ),
    UserModel(
      id: '8',
      email: 'dr.mona@blapp.com',
      name: 'Dr. Mona Farouk',
      role: UserRole.instructor,
      createdAt: DateTime.now().subtract(const Duration(days: 80)),
      profileImage: 'https://via.placeholder.com/150',
      isActive: true,
    ),

    // Admins
    UserModel(
      id: '3',
      email: 'admin@blapp.com',
      name: 'Mohammad Admin',
      role: UserRole.admin,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      profileImage: 'https://via.placeholder.com/150',
      isActive: true,
    ),
  ];

  // Dummy Courses
  static final List<CourseModel> _courses = [
    CourseModel(
      id: '1',
      title: 'Flutter Development Fundamentals',
      description:
          'Learn the basics of Flutter app development from scratch. This comprehensive course covers widgets, state management, and building beautiful UIs.',
      instructorId: '2',
      instructorName: 'Dr. Sarah Johnson',
      thumbnail: 'https://via.placeholder.com/300x200',
      category: 'Programming',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      isApproved: true,
      enrolledStudents: 150,
      rating: 4.8,
      videos: [
        VideoModel(
          id: '1',
          title: 'Introduction to Flutter',
          description:
              'Overview of Flutter framework and development environment setup.',
          youtubeUrl: 'https://www.youtube.com/watch?v=1gDhl4leEzA',
          youtubeVideoId: '1gDhl4leEzA',
          courseId: '1',
          orderIndex: 1,
          durationSeconds: 900,
          createdAt: DateTime.now().subtract(const Duration(days: 19)),
        ),
        VideoModel(
          id: '2',
          title: 'Widgets and Layouts',
          description:
              'Understanding Flutter widgets and creating responsive layouts.',
          youtubeUrl: 'https://www.youtube.com/watch?v=wE7khGHVkYY',
          youtubeVideoId: 'wE7khGHVkYY',
          courseId: '1',
          orderIndex: 2,
          durationSeconds: 1200,
          createdAt: DateTime.now().subtract(const Duration(days: 18)),
        ),
        VideoModel(
          id: '10',
          title: 'State Management in Flutter',
          description:
              'Learn about different state management approaches in Flutter.',
          youtubeUrl: 'https://www.youtube.com/watch?v=d_m5csmrf7I',
          youtubeVideoId: 'd_m5csmrf7I',
          courseId: '1',
          orderIndex: 3,
          durationSeconds: 1800,
          createdAt: DateTime.now().subtract(const Duration(days: 17)),
        ),
        VideoModel(
          id: '11',
          title: 'Navigation and Routing',
          description:
              'Implementing navigation between screens in Flutter apps.',
          youtubeUrl: 'https://www.youtube.com/watch?v=nyvwx7o277U',
          youtubeVideoId: 'nyvwx7o277U',
          courseId: '1',
          orderIndex: 4,
          durationSeconds: 1500,
          createdAt: DateTime.now().subtract(const Duration(days: 16)),
        ),
      ],
      quizzes: [
        QuizModel(
          id: '1',
          title: 'Flutter Basics Quiz',
          description: 'Test your understanding of Flutter fundamentals.',
          courseId: '1',
          timeLimit: 15,
          passingScore: 70,
          createdAt: DateTime.now().subtract(const Duration(days: 17)),
          questions: [
            QuestionModel(
              id: '1',
              question: 'What is Flutter?',
              options: [
                'A mobile app development framework',
                'A programming language',
                'A database system',
                'A web browser',
              ],
              correctAnswerIndex: 0,
              explanation:
                  'Flutter is Google\'s UI toolkit for building natively compiled applications.',
            ),
            QuestionModel(
              id: '2',
              question: 'Which programming language is used in Flutter?',
              options: ['Java', 'Kotlin', 'Dart', 'Swift'],
              correctAnswerIndex: 2,
              explanation:
                  'Flutter uses Dart programming language developed by Google.',
            ),
          ],
        ),
      ],
      worksheets: [
        WorksheetModel(
          id: '1',
          title: 'Flutter Setup Guide',
          description:
              'Step-by-step guide to setting up Flutter development environment',
          fileType: 'pdf',
          fileSize: '2.5 MB',
          fileUrl: 'https://example.com/flutter-setup-guide.pdf',
          courseId: '1',
          instructorId: '2',
          uploadedAt: DateTime.now().subtract(const Duration(days: 19)),
        ),
        WorksheetModel(
          id: '2',
          title: 'Widget Reference Sheet',
          description: 'Quick reference for commonly used Flutter widgets',
          fileType: 'pdf',
          fileSize: '1.8 MB',
          fileUrl: 'https://example.com/widget-reference.pdf',
          courseId: '1',
          instructorId: '2',
          uploadedAt: DateTime.now().subtract(const Duration(days: 18)),
        ),
        WorksheetModel(
          id: '3',
          title: 'Practice Exercises',
          description: 'Hands-on exercises for Flutter development',
          fileType: 'docx',
          fileSize: '850 KB',
          fileUrl: 'https://example.com/flutter-exercises.docx',
          courseId: '1',
          instructorId: '2',
          uploadedAt: DateTime.now().subtract(const Duration(days: 17)),
        ),
        WorksheetModel(
          id: '4',
          title: 'Project Template',
          description: 'Starter template for Flutter projects',
          fileType: 'zip',
          fileSize: '3.2 MB',
          fileUrl: 'https://example.com/flutter-template.zip',
          courseId: '1',
          instructorId: '2',
          uploadedAt: DateTime.now().subtract(const Duration(days: 16)),
        ),
      ],
    ),
    CourseModel(
      id: '2',
      title: 'Arabic Language Mastery',
      description:
          'Comprehensive Arabic language course covering grammar, vocabulary, and conversation skills.',
      instructorId: '2',
      instructorName: 'Dr. Sarah Johnson',
      thumbnail: 'https://via.placeholder.com/300x200',
      category: 'Language',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      isApproved: true,
      enrolledStudents: 89,
      rating: 4.6,
      videos: [
        VideoModel(
          id: '3',
          title: 'Arabic Alphabet',
          description: 'Learn the Arabic alphabet and basic pronunciation.',
          youtubeUrl: 'https://www.youtube.com/watch?v=F2mzsVFjOCs',
          youtubeVideoId: 'F2mzsVFjOCs',
          courseId: '2',
          orderIndex: 1,
          durationSeconds: 800,
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
      ],
      quizzes: [
        QuizModel(
          id: '2',
          title: 'Arabic Alphabet Quiz',
          description: 'Test your knowledge of Arabic letters.',
          courseId: '2',
          timeLimit: 10,
          passingScore: 80,
          createdAt: DateTime.now().subtract(const Duration(days: 13)),
          questions: [
            QuestionModel(
              id: '3',
              question: 'How many letters are in the Arabic alphabet?',
              options: ['26', '28', '30', '32'],
              correctAnswerIndex: 1,
              explanation: 'The Arabic alphabet consists of 28 letters.',
            ),
          ],
        ),
      ],
      worksheets: [
        WorksheetModel(
          id: '5',
          title: 'Arabic Alphabet Chart',
          description:
              'Visual chart of Arabic letters with pronunciation guide',
          fileType: 'pdf',
          fileSize: '1.2 MB',
          fileUrl: 'https://example.com/arabic-alphabet-chart.pdf',
          courseId: '2',
          instructorId: '2',
          uploadedAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
        WorksheetModel(
          id: '6',
          title: 'Writing Practice Sheets',
          description: 'Practice worksheets for Arabic letter writing',
          fileType: 'pdf',
          fileSize: '2.1 MB',
          fileUrl: 'https://example.com/arabic-writing-practice.pdf',
          courseId: '2',
          instructorId: '2',
          uploadedAt: DateTime.now().subtract(const Duration(days: 13)),
        ),
        WorksheetModel(
          id: '7',
          title: 'Vocabulary List',
          description: 'Common Arabic words and phrases with translations',
          fileType: 'xlsx',
          fileSize: '650 KB',
          fileUrl: 'https://example.com/arabic-vocabulary.xlsx',
          courseId: '2',
          instructorId: '2',
          uploadedAt: DateTime.now().subtract(const Duration(days: 12)),
        ),
      ],
    ),
    CourseModel(
      id: '3',
      title: 'Data Science with Python',
      description:
          'Learn data analysis, visualization, and machine learning using Python.',
      instructorId: '7',
      instructorName: 'Prof. Ahmad Mahmoud',
      thumbnail: 'https://via.placeholder.com/300x200',
      category: 'Data Science',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      isApproved: true,
      enrolledStudents: 85,
      rating: 4.6,
      videos: [
        VideoModel(
          id: '7',
          title: 'Introduction to Data Science',
          description: 'Overview of data science and Python basics.',
          youtubeUrl: 'https://www.youtube.com/watch?v=ua-CiDNNj30',
          youtubeVideoId: 'ua-CiDNNj30',
          courseId: '3',
          orderIndex: 1,
          durationSeconds: 1200,
          createdAt: DateTime.now().subtract(const Duration(days: 9)),
        ),
        VideoModel(
          id: '8',
          title: 'Pandas for Data Analysis',
          description: 'Learn to manipulate data with Pandas library.',
          youtubeUrl: 'https://www.youtube.com/watch?v=vmEHCJofslg',
          youtubeVideoId: 'vmEHCJofslg',
          courseId: '3',
          orderIndex: 2,
          durationSeconds: 1800,
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
      ],
      quizzes: [
        QuizModel(
          id: '3',
          title: 'Python Basics Quiz',
          description: 'Test your understanding of Python fundamentals.',
          courseId: '3',
          timeLimit: 20,
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
          questions: [
            QuestionModel(
              id: '7',
              question: 'What is the correct way to create a list in Python?',
              options: ['list = []', 'list = ()', 'list = {}', 'list = ""'],
              correctAnswerIndex: 0,
            ),
            QuestionModel(
              id: '8',
              question:
                  'Which library is commonly used for data analysis in Python?',
              options: ['NumPy', 'Pandas', 'Matplotlib', 'All of the above'],
              correctAnswerIndex: 3,
            ),
            QuestionModel(
              id: '9',
              question: 'What does the len() function return?',
              options: [
                'Length of object',
                'Type of object',
                'Value of object',
                'None',
              ],
              correctAnswerIndex: 0,
            ),
          ],
        ),
        QuizModel(
          id: '4',
          title: 'Data Analysis Quiz',
          description: 'Test your knowledge of data analysis concepts.',
          courseId: '3',
          timeLimit: 25,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          questions: [
            QuestionModel(
              id: '10',
              question: 'What is the primary purpose of data cleaning?',
              options: [
                'Remove errors',
                'Format data',
                'Handle missing values',
                'All of the above',
              ],
              correctAnswerIndex: 3,
            ),
            QuestionModel(
              id: '11',
              question: 'Which method is used to read CSV files in Pandas?',
              options: [
                'read_csv()',
                'load_csv()',
                'import_csv()',
                'get_csv()',
              ],
              correctAnswerIndex: 0,
            ),
          ],
        ),
      ],
      worksheets: [
        WorksheetModel(
          id: '8',
          title: 'Python Exercises',
          description: 'Practice problems for Python programming',
          fileType: 'pdf',
          fileSize: '1.2 MB',
          fileUrl: 'https://example.com/python-exercises.pdf',
          courseId: '3',
          instructorId: '7',
          uploadedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
    ),
    CourseModel(
      id: '4',
      title: 'Web Development with React',
      description:
          'Build modern web applications using React.js and related technologies.',
      instructorId: '8',
      instructorName: 'Dr. Mona Farouk',
      thumbnail: 'https://via.placeholder.com/300x200',
      category: 'Web Development',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      isApproved: true,
      enrolledStudents: 120,
      rating: 4.7,
      videos: [
        VideoModel(
          id: '9',
          title: 'React Fundamentals',
          description: 'Introduction to React components and JSX.',
          youtubeUrl: 'https://www.youtube.com/watch?v=Tn6-PIqc4UM',
          youtubeVideoId: 'Tn6-PIqc4UM',
          courseId: '4',
          orderIndex: 1,
          durationSeconds: 1500,
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
        VideoModel(
          id: '12',
          title: 'React Hooks',
          description: 'Understanding useState, useEffect, and custom hooks.',
          youtubeUrl: 'https://www.youtube.com/watch?v=O6P86uwfdR0',
          youtubeVideoId: 'O6P86uwfdR0',
          courseId: '4',
          orderIndex: 2,
          durationSeconds: 2100,
          createdAt: DateTime.now().subtract(const Duration(days: 13)),
        ),
        VideoModel(
          id: '13',
          title: 'React Router',
          description:
              'Implementing client-side routing in React applications.',
          youtubeUrl: 'https://www.youtube.com/watch?v=Law7wfdg_ls',
          youtubeVideoId: 'Law7wfdg_ls',
          courseId: '4',
          orderIndex: 3,
          durationSeconds: 1650,
          createdAt: DateTime.now().subtract(const Duration(days: 12)),
        ),
      ],
      quizzes: [
        QuizModel(
          id: '5',
          title: 'React Components Quiz',
          description: 'Test your understanding of React components.',
          courseId: '4',
          timeLimit: 15,
          createdAt: DateTime.now().subtract(const Duration(days: 13)),
          questions: [
            QuestionModel(
              id: '12',
              question: 'What is JSX?',
              options: [
                'JavaScript XML',
                'Java Syntax Extension',
                'JSON XML',
                'JavaScript Extension',
              ],
              correctAnswerIndex: 0,
            ),
            QuestionModel(
              id: '13',
              question: 'How do you create a functional component in React?',
              options: [
                'function Component()',
                'const Component = () => {}',
                'class Component',
                'Both A and B',
              ],
              correctAnswerIndex: 3,
            ),
          ],
        ),
      ],
      worksheets: [
        WorksheetModel(
          id: '9',
          title: 'React Component Patterns',
          description: 'Best practices and patterns for React components',
          fileType: 'pdf',
          fileSize: '1.8 MB',
          fileUrl: 'https://example.com/react-component-patterns.pdf',
          courseId: '4',
          instructorId: '8',
          uploadedAt: DateTime.now().subtract(const Duration(days: 13)),
        ),
        WorksheetModel(
          id: '10',
          title: 'React Hooks Reference',
          description: 'Complete guide to React Hooks with examples',
          fileType: 'pdf',
          fileSize: '2.3 MB',
          fileUrl: 'https://example.com/react-hooks-reference.pdf',
          courseId: '4',
          instructorId: '8',
          uploadedAt: DateTime.now().subtract(const Duration(days: 12)),
        ),
        WorksheetModel(
          id: '11',
          title: 'Project Starter Code',
          description: 'Boilerplate code for React projects',
          fileType: 'zip',
          fileSize: '4.5 MB',
          fileUrl: 'https://example.com/react-starter-code.zip',
          courseId: '4',
          instructorId: '8',
          uploadedAt: DateTime.now().subtract(const Duration(days: 11)),
        ),
      ],
    ),
    CourseModel(
      id: '5',
      title: 'Mobile App Design',
      description: 'Learn UI/UX principles for mobile application design.',
      instructorId: '2',
      instructorName: 'Dr. Sarah Johnson',
      thumbnail: 'https://via.placeholder.com/300x200',
      category: 'Design',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isApproved: false,
      enrolledStudents: 0,
      rating: 0.0,
      videos: [],
      quizzes: [
        QuizModel(
          id: '6',
          title: 'Design Principles Quiz',
          description: 'Test your knowledge of mobile design principles.',
          courseId: '5',
          timeLimit: 10,
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
          questions: [
            QuestionModel(
              id: '14',
              question: 'What is the recommended minimum touch target size?',
              options: ['24dp', '44dp', '48dp', '56dp'],
              correctAnswerIndex: 2,
            ),
          ],
        ),
      ],
      worksheets: [],
    ),
  ];

  // Dummy Forum Posts
  static final List<ForumPostModel> _forumPosts = [
    ForumPostModel(
      id: '1',
      title: 'Question about Flutter State Management',
      content:
          'I\'m having trouble understanding when to use setState vs Provider. Can someone explain the difference?',
      authorId: '1',
      authorName: 'Ahmed Al-Rashid',
      courseId: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likesCount: 5,
      replies: [
        ForumReplyModel(
          id: '1',
          postId: '1',
          content:
              'setState is for local widget state, while Provider is for app-wide state management. Use setState for simple UI updates and Provider for complex state sharing.',
          authorId: '2',
          authorName: 'Dr. Sarah Johnson',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          likesCount: 3,
        ),
      ],
    ),
    ForumPostModel(
      id: '2',
      title: 'Arabic Grammar Help',
      content:
          'Can someone help me understand the difference between فعل and اسم?',
      authorId: '1',
      authorName: 'Ahmed Al-Rashid',
      courseId: '2',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likesCount: 2,
      replies: [],
    ),
  ];

  // Quiz Submissions
  static final List<QuizSubmissionModel> _quizSubmissions = [
    QuizSubmissionModel(
      id: '1',
      quizId: '1',
      studentId: '1',
      answers: {'1': 0, '2': 2},
      score: 2,
      totalQuestions: 2,
      submittedAt: DateTime.now().subtract(const Duration(days: 5)),
      timeSpentMinutes: 8,
      passed: true,
    ),
  ];

  // Authentication Methods
  UserModel? authenticateUser(String email, String password) {
    try {
      // For demo purposes, we'll use simple password validation
      // In production, this would be properly hashed and validated
      final user = _users.firstWhere((user) => user.email == email);

      // Demo password validation - in real app, use proper password hashing
      String expectedPassword;
      switch (user.role) {
        case UserRole.student:
          expectedPassword = 'student123';
          break;
        case UserRole.instructor:
          expectedPassword = 'instructor123';
          break;
        case UserRole.admin:
          expectedPassword = 'admin123';
          break;
      }

      if (password == expectedPassword) {
        return user;
      } else {
        return null; // Invalid password
      }
    } catch (e) {
      return null; // User not found
    }
  }

  // User Methods
  List<UserModel> getAllUsers() => List.from(_users);

  UserModel? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  UserModel? getUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  void updateUser(UserModel user) {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
    }
  }

  // Get user by email (static method for compatibility)
  static UserModel? getUserByEmailStatic(String email) {
    try {
      return _users.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  void createUser(UserModel user) {
    _users.add(user);
  }

  void deleteUser(String id) {
    _users.removeWhere((user) => user.id == id);
  }

  // Course Methods
  List<CourseModel> getAllCourses() => List.from(_courses);

  List<CourseModel> getApprovedCourses() =>
      _courses.where((course) => course.isApproved).toList();

  List<CourseModel> getPendingCourses() =>
      _courses.where((course) => !course.isApproved).toList();

  List<CourseModel> getCoursesByInstructor(String instructorId) =>
      _courses.where((course) => course.instructorId == instructorId).toList();

  List<CourseModel> getEnrolledCourses(String studentId) {
    // Mock enrolled courses for student - return more courses for better demo
    return _courses.where((course) => course.isApproved).take(4).toList();
  }

  CourseModel? getCourseById(String id) {
    try {
      return _courses.firstWhere((course) => course.id == id);
    } catch (e) {
      return null;
    }
  }

  void createCourse(CourseModel course) {
    _courses.add(course);
  }

  void updateCourse(CourseModel course) {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
    }
  }

  void deleteCourse(String id) {
    _courses.removeWhere((course) => course.id == id);
  }

  void approveCourse(String id) {
    final course = getCourseById(id);
    if (course != null) {
      updateCourse(course.copyWith(isApproved: true));
    }
  }

  // Video Methods
  List<VideoModel> getVideosByCourse(String courseId) {
    final course = getCourseById(courseId);
    return course?.videos ?? [];
  }

  void addVideoToCourse(String courseId, VideoModel video) {
    final course = getCourseById(courseId);
    if (course != null) {
      final updatedVideos = List<VideoModel>.from(course.videos)..add(video);
      updateCourse(course.copyWith(videos: updatedVideos));
    }
  }

  void updateVideo(String courseId, VideoModel video) {
    final course = getCourseById(courseId);
    if (course != null) {
      final updatedVideos = course.videos
          .map((v) => v.id == video.id ? video : v)
          .toList();
      updateCourse(course.copyWith(videos: updatedVideos));
    }
  }

  void deleteVideo(String courseId, String videoId) {
    final course = getCourseById(courseId);
    if (course != null) {
      final updatedVideos = course.videos
          .where((v) => v.id != videoId)
          .toList();
      updateCourse(course.copyWith(videos: updatedVideos));
    }
  }

  // Quiz Methods
  List<QuizModel> getQuizzesByCourse(String courseId) {
    final course = getCourseById(courseId);
    return course?.quizzes ?? [];
  }

  QuizModel? getQuizById(String quizId) {
    for (final course in _courses) {
      try {
        return course.quizzes.firstWhere((quiz) => quiz.id == quizId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  void addQuizToCourse(String courseId, QuizModel quiz) {
    final course = getCourseById(courseId);
    if (course != null) {
      final updatedQuizzes = List<QuizModel>.from(course.quizzes)..add(quiz);
      updateCourse(course.copyWith(quizzes: updatedQuizzes));
    }
  }

  void updateQuiz(String courseId, QuizModel quiz) {
    final course = getCourseById(courseId);
    if (course != null) {
      final updatedQuizzes = course.quizzes
          .map((q) => q.id == quiz.id ? quiz : q)
          .toList();
      updateCourse(course.copyWith(quizzes: updatedQuizzes));
    }
  }

  void deleteQuiz(String courseId, String quizId) {
    final course = getCourseById(courseId);
    if (course != null) {
      final updatedQuizzes = course.quizzes
          .where((q) => q.id != quizId)
          .toList();
      updateCourse(course.copyWith(quizzes: updatedQuizzes));
    }
  }

  // Quiz Submission Methods
  List<QuizSubmissionModel> getQuizSubmissions(String quizId) =>
      _quizSubmissions
          .where((submission) => submission.quizId == quizId)
          .toList();

  List<QuizSubmissionModel> getStudentSubmissions(String studentId) =>
      _quizSubmissions
          .where((submission) => submission.studentId == studentId)
          .toList();

  void submitQuiz(QuizSubmissionModel submission) {
    _quizSubmissions.add(submission);
  }

  // Forum Methods
  List<ForumPostModel> getForumPosts(String courseId) =>
      _forumPosts.where((post) => post.courseId == courseId).toList();

  ForumPostModel? getForumPostById(String postId) {
    try {
      return _forumPosts.firstWhere((post) => post.id == postId);
    } catch (e) {
      return null;
    }
  }

  void createForumPost(ForumPostModel post) {
    _forumPosts.add(post);
  }

  void addReplyToPost(String postId, ForumReplyModel reply) {
    final postIndex = _forumPosts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _forumPosts[postIndex];
      final updatedReplies = List<ForumReplyModel>.from(post.replies)
        ..add(reply);
      _forumPosts[postIndex] = post.copyWith(replies: updatedReplies);
    }
  }

  void likePost(String postId) {
    final postIndex = _forumPosts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _forumPosts[postIndex];
      _forumPosts[postIndex] = post.copyWith(
        likesCount: post.likesCount + 1,
        isLiked: true,
      );
    }
  }

  // Analytics Methods
  Map<String, dynamic> getSystemAnalytics() {
    return {
      'total_users': _users.length,
      'total_courses': _courses.length,
      'approved_courses': _courses.where((c) => c.isApproved).length,
      'pending_courses': _courses.where((c) => !c.isApproved).length,
      'total_students': _users.where((u) => u.role == UserRole.student).length,
      'total_instructors': _users
          .where((u) => u.role == UserRole.instructor)
          .length,
      'total_admins': _users.where((u) => u.role == UserRole.admin).length,
      'total_quiz_submissions': _quizSubmissions.length,
      'total_forum_posts': _forumPosts.length,
    };
  }

  Map<String, dynamic> getCourseAnalytics(String courseId) {
    final course = getCourseById(courseId);
    if (course == null) return {};

    final courseSubmissions = _quizSubmissions
        .where((s) => course.quizzes.any((q) => q.id == s.quizId))
        .toList();

    return {
      'enrolled_students': course.enrolledStudents,
      'total_videos': course.videos.length,
      'total_quizzes': course.quizzes.length,
      'quiz_submissions': courseSubmissions.length,
      'average_score': courseSubmissions.isNotEmpty
          ? courseSubmissions.map((s) => s.percentage).reduce((a, b) => a + b) /
                courseSubmissions.length
          : 0.0,
      'completion_rate': course.enrolledStudents > 0
          ? (courseSubmissions.length / course.enrolledStudents) * 100
          : 0.0,
    };
  }
}
