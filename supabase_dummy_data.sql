-- =====================================================
-- BLApp - Dummy Test Data
-- =====================================================
-- This file contains comprehensive test data for all tables
-- Note: In production, profiles will be created automatically via trigger when users sign up

-- =====================================================
-- 1. PROFILES DATA (Test Users)
-- =====================================================

-- Insert test profiles (these would normally be created via auth.users signup)
INSERT INTO profiles (id, email, name, role, profile_image, is_active, created_at) VALUES
-- Students
('11111111-1111-1111-1111-111111111111', 'ahmed.rashid@blapp.com', 'Ahmed Al-Rashid', 'student', 'https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/profiles/student1.jpg', true, NOW() - INTERVAL '30 days'),
('11111111-1111-1111-1111-111111111112', 'layla.hassan@blapp.com', 'Layla Hassan', 'student', 'https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/profiles/student2.jpg', true, NOW() - INTERVAL '15 days'),
('11111111-1111-1111-1111-111111111113', 'omar.khalil@blapp.com', 'Omar Khalil', 'student', 'https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/profiles/student3.jpg', true, NOW() - INTERVAL '10 days'),

-- Instructors
('22222222-2222-2222-2222-222222222221', 'sarah.johnson@blapp.com', 'Dr. Sarah Johnson', 'instructor', 'https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/profiles/instructor1.jpg', true, NOW() - INTERVAL '60 days'),
('22222222-2222-2222-2222-222222222222', 'mohamed.ali@blapp.com', 'Prof. Mohamed Ali', 'instructor', 'https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/profiles/instructor2.jpg', true, NOW() - INTERVAL '45 days'),
('22222222-2222-2222-2222-222222222223', 'fatima.zahra@blapp.com', 'Dr. Fatima Zahra', 'instructor', 'https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/profiles/instructor3.jpg', true, NOW() - INTERVAL '50 days'),

-- Admins
('33333333-3333-3333-3333-333333333331', 'admin@blapp.com', 'System Administrator', 'admin', 'https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/profiles/admin1.jpg', true, NOW() - INTERVAL '90 days');

-- =====================================================
-- 2. COURSES DATA
-- =====================================================

INSERT INTO courses (id, title, description, instructor_id, thumbnail, category, is_approved, enrolled_students, rating, created_at) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 
 'Flutter Development Fundamentals', 
 'Learn the basics of Flutter app development from scratch. This comprehensive course covers widgets, state management, and building beautiful UIs.',
 '22222222-2222-2222-2222-222222222221',
 'https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/courses/flutter-course.jpg',
 'Programming',
 true,
 150,
 4.8,
 NOW() - INTERVAL '20 days'),

('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
 'Arabic Language Basics',
 'Master the fundamentals of Arabic language including alphabet, pronunciation, and basic grammar rules.',
 '22222222-2222-2222-2222-222222222222',
 'https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/courses/arabic-course.jpg',
 'Language',
 true,
 89,
 4.6,
 NOW() - INTERVAL '25 days'),

('cccccccc-cccc-cccc-cccc-cccccccccccc',
 'Mathematics for Engineers',
 'Advanced mathematics concepts essential for engineering students including calculus, linear algebra, and differential equations.',
 '22222222-2222-2222-2222-222222222223',
 'https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/courses/math-course.jpg',
 'Mathematics',
 true,
 67,
 4.7,
 NOW() - INTERVAL '18 days'),

('dddddddd-dddd-dddd-dddd-dddddddddddd',
 'React Web Development',
 'Build modern web applications using React.js, including hooks, state management, and component architecture.',
 '22222222-2222-2222-2222-222222222221',
 'https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/courses/react-course.jpg',
 'Programming',
 false,
 0,
 0.0,
 NOW() - INTERVAL '5 days');

-- =====================================================
-- 3. VIDEOS DATA
-- =====================================================

INSERT INTO videos (id, title, description, youtube_url, youtube_video_id, course_id, order_index, duration_seconds, thumbnail, created_at) VALUES
-- Flutter Course Videos
('vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvv01', 'Introduction to Flutter', 'Overview of Flutter framework and development environment setup.', 'https://www.youtube.com/watch?v=1gDhl4leEzA', '1gDhl4leEzA', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1, 1200, 'https://img.youtube.com/vi/1gDhl4leEzA/maxresdefault.jpg', NOW() - INTERVAL '19 days'),
('vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvv02', 'Flutter Widgets Basics', 'Understanding StatelessWidget and StatefulWidget fundamentals.', 'https://www.youtube.com/watch?v=wE7khGHVkYY', 'wE7khGHVkYY', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 2, 1800, 'https://img.youtube.com/vi/wE7khGHVkYY/maxresdefault.jpg', NOW() - INTERVAL '18 days'),
('vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvv03', 'State Management in Flutter', 'Learn about setState, Provider, and other state management solutions.', 'https://www.youtube.com/watch?v=d_m5csmrf7I', 'd_m5csmrf7I', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 3, 2400, 'https://img.youtube.com/vi/d_m5csmrf7I/maxresdefault.jpg', NOW() - INTERVAL '17 days'),

-- Arabic Course Videos
('vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvv04', 'Arabic Alphabet Introduction', 'Learn the 28 letters of the Arabic alphabet and their pronunciation.', 'https://www.youtube.com/watch?v=YUew1xiwBWs', 'YUew1xiwBWs', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 1, 1500, 'https://img.youtube.com/vi/YUew1xiwBWs/maxresdefault.jpg', NOW() - INTERVAL '24 days'),
('vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvv05', 'Arabic Grammar Basics', 'Understanding nouns, verbs, and sentence structure in Arabic.', 'https://www.youtube.com/watch?v=kx_bVNER7zQ', 'kx_bVNER7zQ', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 2, 2100, 'https://img.youtube.com/vi/kx_bVNER7zQ/maxresdefault.jpg', NOW() - INTERVAL '23 days'),

-- Math Course Videos
('vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvv06', 'Calculus Fundamentals', 'Introduction to limits, derivatives, and integrals.', 'https://www.youtube.com/watch?v=WUvTyaaNkzM', 'WUvTyaaNkzM', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 1, 3600, 'https://img.youtube.com/vi/WUvTyaaNkzM/maxresdefault.jpg', NOW() - INTERVAL '17 days'),
('vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvv07', 'Linear Algebra Basics', 'Vectors, matrices, and linear transformations explained.', 'https://www.youtube.com/watch?v=fNk_zzaMoSs', 'fNk_zzaMoSs', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 2, 2700, 'https://img.youtube.com/vi/fNk_zzaMoSs/maxresdefault.jpg', NOW() - INTERVAL '16 days');

-- =====================================================
-- 4. QUIZZES DATA
-- =====================================================

INSERT INTO quizzes (id, title, description, course_id, time_limit, passing_score, is_active, created_at) VALUES
('qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqq01', 'Flutter Basics Quiz', 'Test your understanding of Flutter fundamentals.', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 15, 70, true, NOW() - INTERVAL '17 days'),
('qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqq02', 'Arabic Alphabet Quiz', 'Test your knowledge of Arabic letters.', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 10, 80, true, NOW() - INTERVAL '13 days'),
('qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqq03', 'Calculus Assessment', 'Evaluate your calculus knowledge.', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 30, 75, true, NOW() - INTERVAL '15 days');

-- =====================================================
-- 5. QUESTIONS DATA
-- =====================================================

INSERT INTO questions (id, quiz_id, question, options, correct_answer_index, explanation, points, order_index) VALUES
-- Flutter Quiz Questions
('qqqqaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqq01', 'What is Flutter?', '["A mobile app development framework", "A programming language", "A database system", "A web browser"]', 0, 'Flutter is Google''s UI toolkit for building natively compiled applications.', 1, 1),
('qqqqaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaab', 'qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqq01', 'Which programming language is used in Flutter?', '["Java", "Dart", "Swift", "Kotlin"]', 1, 'Flutter uses Dart programming language developed by Google.', 1, 2),

-- Arabic Quiz Questions
('qqqqbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqq02', 'How many letters are in the Arabic alphabet?', '["26", "28", "30", "32"]', 1, 'The Arabic alphabet consists of 28 letters.', 1, 1),
('qqqqbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqq02', 'Arabic is written from:', '["Left to right", "Right to left", "Top to bottom", "Bottom to top"]', 1, 'Arabic is written from right to left.', 1, 2),

-- Math Quiz Questions
('qqqqcccc-cccc-cccc-cccc-cccccccccccc', 'qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqq03', 'What is the derivative of x²?', '["x", "2x", "x²", "2x²"]', 1, 'The derivative of x² is 2x using the power rule.', 1, 1);

-- =====================================================
-- 6. WORKSHEETS DATA
-- =====================================================

INSERT INTO worksheets (id, title, description, file_type, file_size, file_url, course_id, instructor_id, is_active, uploaded_at) VALUES
('wwwwwwww-wwww-wwww-wwww-wwwwwwwwww01', 'Flutter Development Guide', 'Comprehensive guide to Flutter development best practices.', 'PDF', '2.5 MB', 'https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/worksheets/flutter-guide.pdf', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222221', true, NOW() - INTERVAL '16 days'),
('wwwwwwww-wwww-wwww-wwww-wwwwwwwwww02', 'Arabic Writing Practice', 'Practice sheets for Arabic letter writing and formation.', 'PDF', '1.8 MB', 'https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/worksheets/arabic-practice.pdf', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', true, NOW() - INTERVAL '22 days'),
('wwwwwwww-wwww-wwww-wwww-wwwwwwwwww03', 'Calculus Formula Sheet', 'Essential calculus formulas and theorems reference.', 'PDF', '1.2 MB', 'https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/worksheets/calculus-formulas.pdf', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '22222222-2222-2222-2222-222222222223', true, NOW() - INTERVAL '14 days');

-- =====================================================
-- 7. ENROLLMENTS DATA
-- =====================================================

INSERT INTO enrollments (id, student_id, course_id, enrolled_at, progress) VALUES
-- Ahmed's enrollments
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeee01', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NOW() - INTERVAL '25 days', 75.0),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeee02', '11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NOW() - INTERVAL '20 days', 45.0),

-- Layla's enrollments
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeee03', '11111111-1111-1111-1111-111111111112', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NOW() - INTERVAL '12 days', 30.0),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeee04', '11111111-1111-1111-1111-111111111112', 'cccccccc-cccc-cccc-cccc-cccccccccccc', NOW() - INTERVAL '8 days', 60.0),

-- Omar's enrollments
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeee05', '11111111-1111-1111-1111-111111111113', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NOW() - INTERVAL '7 days', 20.0);

-- =====================================================
-- 8. VIDEO PROGRESS DATA
-- =====================================================

INSERT INTO video_progress (id, student_id, video_id, is_watched, watch_time_seconds, completed_at) VALUES
-- Ahmed's video progress
('pppppppp-pppp-pppp-pppp-pppppppppp01', '11111111-1111-1111-1111-111111111111', 'vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvv01', true, 1200, NOW() - INTERVAL '24 days'),
('pppppppp-pppp-pppp-pppp-pppppppppp02', '11111111-1111-1111-1111-111111111111', 'vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvv02', true, 1800, NOW() - INTERVAL '22 days'),
('pppppppp-pppp-pppp-pppp-pppppppppp03', '11111111-1111-1111-1111-111111111111', 'vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvv03', false, 800, NULL),

-- Layla's video progress
('pppppppp-pppp-pppp-pppp-pppppppppp04', '11111111-1111-1111-1111-111111111112', 'vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvv01', true, 1200, NOW() - INTERVAL '11 days'),
('pppppppp-pppp-pppp-pppp-pppppppppp05', '11111111-1111-1111-1111-111111111112', 'vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvv06', true, 3600, NOW() - INTERVAL '6 days'),

-- Omar's video progress
('pppppppp-pppp-pppp-pppp-pppppppppp06', '11111111-1111-1111-1111-111111111113', 'vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvv04', true, 1500, NOW() - INTERVAL '5 days');

-- =====================================================
-- 9. QUIZ SUBMISSIONS DATA
-- =====================================================

INSERT INTO quiz_submissions (id, quiz_id, student_id, answers, score, total_questions, time_spent_minutes, passed, submitted_at) VALUES
-- Ahmed's quiz submissions
('ssssssss-ssss-ssss-ssss-ssssssssss01', 'qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqq01', '11111111-1111-1111-1111-111111111111', '{"qqqqaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa": 0, "qqqqaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaab": 1}', 2, 2, 8, true, NOW() - INTERVAL '20 days'),
('ssssssss-ssss-ssss-ssss-ssssssssss02', 'qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqq02', '11111111-1111-1111-1111-111111111111', '{"qqqqbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb": 1, "qqqqbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2": 1}', 2, 2, 6, true, NOW() - INTERVAL '18 days'),

-- Layla's quiz submissions
('ssssssss-ssss-ssss-ssss-ssssssssss03', 'qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqq01', '11111111-1111-1111-1111-111111111112', '{"qqqqaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa": 0, "qqqqaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaab": 0}', 1, 2, 12, false, NOW() - INTERVAL '10 days'),
('ssssssss-ssss-ssss-ssss-ssssssssss04', 'qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqq03', '11111111-1111-1111-1111-111111111112', '{"qqqqcccc-cccc-cccc-cccc-cccccccccccc": 1}', 1, 1, 15, true, NOW() - INTERVAL '5 days');

-- =====================================================
-- 10. FORUM POSTS DATA
-- =====================================================

INSERT INTO forum_posts (id, title, content, author_id, course_id, likes_count, is_pinned, created_at) VALUES
('ffffffff-ffff-ffff-ffff-ffffffffff01', 'Question about Flutter State Management', 'I''m having trouble understanding when to use setState vs Provider. Can someone explain the difference?', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 5, false, NOW() - INTERVAL '2 hours'),
('ffffffff-ffff-ffff-ffff-ffffffffff02', 'Arabic Grammar Help', 'Can someone help me understand the difference between فعل and اسم?', '11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 2, false, NOW() - INTERVAL '1 day'),
('ffffffff-ffff-ffff-ffff-ffffffffff03', 'Course Welcome Message', 'Welcome to Flutter Development Fundamentals! Please introduce yourselves and share your programming background.', '22222222-2222-2222-2222-222222222221', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 12, true, NOW() - INTERVAL '19 days'),
('ffffffff-ffff-ffff-ffff-ffffffffff04', 'Calculus Study Group', 'Anyone interested in forming a study group for the upcoming calculus exam?', '11111111-1111-1111-1111-111111111112', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 8, false, NOW() - INTERVAL '3 days');

-- =====================================================
-- 11. FORUM REPLIES DATA
-- =====================================================

INSERT INTO forum_replies (id, post_id, content, author_id, likes_count, created_at) VALUES
('rrrrrrrr-rrrr-rrrr-rrrr-rrrrrrrrrr01', 'ffffffff-ffff-ffff-ffff-ffffffffff01', 'setState is for local widget state, while Provider is for app-wide state management. Use setState for simple UI updates and Provider for complex state sharing.', '22222222-2222-2222-2222-222222222221', 3, NOW() - INTERVAL '1 hour'),
('rrrrrrrr-rrrr-rrrr-rrrr-rrrrrrrrrr02', 'ffffffff-ffff-ffff-ffff-ffffffffff01', 'Great explanation! I would also recommend checking out the official Flutter documentation on state management.', '11111111-1111-1111-1111-111111111112', 1, NOW() - INTERVAL '30 minutes'),
('rrrrrrrr-rrrr-rrrr-rrrr-rrrrrrrrrr03', 'ffffffff-ffff-ffff-ffff-ffffffffff02', 'فعل means verb (action word) and اسم means noun (name of person, place, or thing). In Arabic grammar, these are the two main word categories.', '22222222-2222-2222-2222-222222222222', 4, NOW() - INTERVAL '20 hours'),
('rrrrrrrr-rrrr-rrrr-rrrr-rrrrrrrrrr04', 'ffffffff-ffff-ffff-ffff-ffffffffff04', 'I''m interested! Let''s create a WhatsApp group for coordination.', '11111111-1111-1111-1111-111111111113', 2, NOW() - INTERVAL '2 days');

-- =====================================================
-- 12. FORUM LIKES DATA
-- =====================================================

INSERT INTO forum_likes (id, user_id, post_id, reply_id, created_at) VALUES
-- Likes on posts
('llllllll-llll-llll-llll-llllllllll01', '11111111-1111-1111-1111-111111111112', 'ffffffff-ffff-ffff-ffff-ffffffffff01', NULL, NOW() - INTERVAL '1 hour 30 minutes'),
('llllllll-llll-llll-llll-llllllllll02', '11111111-1111-1111-1111-111111111113', 'ffffffff-ffff-ffff-ffff-ffffffffff01', NULL, NOW() - INTERVAL '1 hour 15 minutes'),
('llllllll-llll-llll-llll-llllllllll03', '22222222-2222-2222-2222-222222222221', 'ffffffff-ffff-ffff-ffff-ffffffffff04', NULL, NOW() - INTERVAL '2 days 5 hours'),

-- Likes on replies
('llllllll-llll-llll-llll-llllllllll04', '11111111-1111-1111-1111-111111111111', NULL, 'rrrrrrrr-rrrr-rrrr-rrrr-rrrrrrrrrr01', NOW() - INTERVAL '45 minutes'),
('llllllll-llll-llll-llll-llllllllll05', '11111111-1111-1111-1111-111111111113', NULL, 'rrrrrrrr-rrrr-rrrr-rrrr-rrrrrrrrrr01', NOW() - INTERVAL '35 minutes'),
('llllllll-llll-llll-llll-llllllllll06', '11111111-1111-1111-1111-111111111111', NULL, 'rrrrrrrr-rrrr-rrrr-rrrr-rrrrrrrrrr03', NOW() - INTERVAL '18 hours');

-- =====================================================
-- 13. ANALYTICS EVENTS DATA
-- =====================================================

INSERT INTO analytics_events (id, user_id, event_type, event_data, course_id, video_id, quiz_id, created_at) VALUES
-- Video watching events
('aaaaaaaa-eeee-eeee-eeee-eeeeeeeeee01', '11111111-1111-1111-1111-111111111111', 'video_watched', '{"watch_duration": 1200, "completion_rate": 100}', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvv01', NULL, NOW() - INTERVAL '24 days'),
('aaaaaaaa-eeee-eeee-eeee-eeeeeeeeee02', '11111111-1111-1111-1111-111111111111', 'video_watched', '{"watch_duration": 1800, "completion_rate": 100}', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'vvvvvvvv-vvvv-vvvv-vvvv-vvvvvvvvvv02', NULL, NOW() - INTERVAL '22 days'),

-- Quiz completion events
('aaaaaaaa-eeee-eeee-eeee-eeeeeeeeee03', '11111111-1111-1111-1111-111111111111', 'quiz_completed', '{"score": 2, "total_questions": 2, "passed": true, "time_spent": 8}', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, 'qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqq01', NOW() - INTERVAL '20 days'),
('aaaaaaaa-eeee-eeee-eeee-eeeeeeeeee04', '11111111-1111-1111-1111-111111111112', 'quiz_completed', '{"score": 1, "total_questions": 2, "passed": false, "time_spent": 12}', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, 'qqqqqqqq-qqqq-qqqq-qqqq-qqqqqqqqqq01', NOW() - INTERVAL '10 days'),

-- Course enrollment events
('aaaaaaaa-eeee-eeee-eeee-eeeeeeeeee05', '11111111-1111-1111-1111-111111111111', 'course_enrolled', '{"enrollment_method": "direct"}', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, NULL, NOW() - INTERVAL '25 days'),
('aaaaaaaa-eeee-eeee-eeee-eeeeeeeeee06', '11111111-1111-1111-1111-111111111112', 'course_enrolled', '{"enrollment_method": "direct"}', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, NULL, NOW() - INTERVAL '12 days'),

-- Forum interaction events
('aaaaaaaa-eeee-eeee-eeee-eeeeeeeeee07', '11111111-1111-1111-1111-111111111111', 'forum_post_created', '{"post_title": "Question about Flutter State Management"}', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, NULL, NOW() - INTERVAL '2 hours'),
('aaaaaaaa-eeee-eeee-eeee-eeeeeeeeee08', '22222222-2222-2222-2222-222222222221', 'forum_reply_created', '{"reply_to_post": "ffffffff-ffff-ffff-ffff-ffffffffff01"}', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, NULL, NOW() - INTERVAL '1 hour');
