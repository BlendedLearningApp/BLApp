-- =====================================================
-- BLApp - Database Performance Indexes
-- =====================================================
-- This file contains all performance indexes for the BLApp database

-- =====================================================
-- PROFILES TABLE INDEXES
-- =====================================================
CREATE INDEX idx_profiles_email ON profiles(email);
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_is_active ON profiles(is_active);
CREATE INDEX idx_profiles_created_at ON profiles(created_at);

-- =====================================================
-- COURSES TABLE INDEXES
-- =====================================================
CREATE INDEX idx_courses_instructor_id ON courses(instructor_id);
CREATE INDEX idx_courses_category ON courses(category);
CREATE INDEX idx_courses_is_approved ON courses(is_approved);
CREATE INDEX idx_courses_created_at ON courses(created_at);
CREATE INDEX idx_courses_rating ON courses(rating);
CREATE INDEX idx_courses_enrolled_students ON courses(enrolled_students);

-- Composite indexes for common queries
CREATE INDEX idx_courses_approved_category ON courses(is_approved, category) WHERE is_approved = true;
CREATE INDEX idx_courses_instructor_approved ON courses(instructor_id, is_approved);

-- =====================================================
-- VIDEOS TABLE INDEXES
-- =====================================================
CREATE INDEX idx_videos_course_id ON videos(course_id);
CREATE INDEX idx_videos_order_index ON videos(order_index);
CREATE INDEX idx_videos_created_at ON videos(created_at);
CREATE INDEX idx_videos_youtube_video_id ON videos(youtube_video_id);

-- Composite index for course videos ordering
CREATE INDEX idx_videos_course_order ON videos(course_id, order_index);

-- =====================================================
-- QUIZZES TABLE INDEXES
-- =====================================================
CREATE INDEX idx_quizzes_course_id ON quizzes(course_id);
CREATE INDEX idx_quizzes_is_active ON quizzes(is_active);
CREATE INDEX idx_quizzes_created_at ON quizzes(created_at);

-- Composite index for active course quizzes
CREATE INDEX idx_quizzes_course_active ON quizzes(course_id, is_active) WHERE is_active = true;

-- =====================================================
-- QUESTIONS TABLE INDEXES
-- =====================================================
CREATE INDEX idx_questions_quiz_id ON questions(quiz_id);
CREATE INDEX idx_questions_order_index ON questions(order_index);

-- Composite index for quiz questions ordering
CREATE INDEX idx_questions_quiz_order ON questions(quiz_id, order_index);

-- =====================================================
-- WORKSHEETS TABLE INDEXES
-- =====================================================
CREATE INDEX idx_worksheets_course_id ON worksheets(course_id);
CREATE INDEX idx_worksheets_instructor_id ON worksheets(instructor_id);
CREATE INDEX idx_worksheets_is_active ON worksheets(is_active);
CREATE INDEX idx_worksheets_uploaded_at ON worksheets(uploaded_at);
CREATE INDEX idx_worksheets_file_type ON worksheets(file_type);

-- Composite indexes
CREATE INDEX idx_worksheets_course_active ON worksheets(course_id, is_active) WHERE is_active = true;
CREATE INDEX idx_worksheets_instructor_active ON worksheets(instructor_id, is_active) WHERE is_active = true;

-- =====================================================
-- ENROLLMENTS TABLE INDEXES
-- =====================================================
CREATE INDEX idx_enrollments_student_id ON enrollments(student_id);
CREATE INDEX idx_enrollments_course_id ON enrollments(course_id);
CREATE INDEX idx_enrollments_enrolled_at ON enrollments(enrolled_at);
CREATE INDEX idx_enrollments_completed_at ON enrollments(completed_at);
CREATE INDEX idx_enrollments_progress ON enrollments(progress);

-- Composite indexes for common queries
CREATE INDEX idx_enrollments_student_progress ON enrollments(student_id, progress);
CREATE INDEX idx_enrollments_course_enrolled ON enrollments(course_id, enrolled_at);

-- =====================================================
-- VIDEO PROGRESS TABLE INDEXES
-- =====================================================
CREATE INDEX idx_video_progress_student_id ON video_progress(student_id);
CREATE INDEX idx_video_progress_video_id ON video_progress(video_id);
CREATE INDEX idx_video_progress_is_watched ON video_progress(is_watched);
CREATE INDEX idx_video_progress_completed_at ON video_progress(completed_at);

-- Composite indexes
CREATE INDEX idx_video_progress_student_watched ON video_progress(student_id, is_watched);
CREATE INDEX idx_video_progress_video_watched ON video_progress(video_id, is_watched);

-- =====================================================
-- QUIZ SUBMISSIONS TABLE INDEXES
-- =====================================================
CREATE INDEX idx_quiz_submissions_quiz_id ON quiz_submissions(quiz_id);
CREATE INDEX idx_quiz_submissions_student_id ON quiz_submissions(student_id);
CREATE INDEX idx_quiz_submissions_passed ON quiz_submissions(passed);
CREATE INDEX idx_quiz_submissions_submitted_at ON quiz_submissions(submitted_at);
CREATE INDEX idx_quiz_submissions_score ON quiz_submissions(score);

-- Composite indexes for analytics
CREATE INDEX idx_quiz_submissions_student_passed ON quiz_submissions(student_id, passed);
CREATE INDEX idx_quiz_submissions_quiz_passed ON quiz_submissions(quiz_id, passed);
CREATE INDEX idx_quiz_submissions_student_score ON quiz_submissions(student_id, score);

-- =====================================================
-- FORUM POSTS TABLE INDEXES
-- =====================================================
CREATE INDEX idx_forum_posts_author_id ON forum_posts(author_id);
CREATE INDEX idx_forum_posts_course_id ON forum_posts(course_id);
CREATE INDEX idx_forum_posts_created_at ON forum_posts(created_at);
CREATE INDEX idx_forum_posts_likes_count ON forum_posts(likes_count);
CREATE INDEX idx_forum_posts_is_pinned ON forum_posts(is_pinned);

-- Composite indexes for forum queries
CREATE INDEX idx_forum_posts_course_created ON forum_posts(course_id, created_at DESC);
CREATE INDEX idx_forum_posts_course_pinned ON forum_posts(course_id, is_pinned, created_at DESC);

-- =====================================================
-- FORUM REPLIES TABLE INDEXES
-- =====================================================
CREATE INDEX idx_forum_replies_post_id ON forum_replies(post_id);
CREATE INDEX idx_forum_replies_author_id ON forum_replies(author_id);
CREATE INDEX idx_forum_replies_created_at ON forum_replies(created_at);
CREATE INDEX idx_forum_replies_likes_count ON forum_replies(likes_count);

-- Composite index for post replies
CREATE INDEX idx_forum_replies_post_created ON forum_replies(post_id, created_at);

-- =====================================================
-- FORUM LIKES TABLE INDEXES
-- =====================================================
CREATE INDEX idx_forum_likes_user_id ON forum_likes(user_id);
CREATE INDEX idx_forum_likes_post_id ON forum_likes(post_id);
CREATE INDEX idx_forum_likes_reply_id ON forum_likes(reply_id);
CREATE INDEX idx_forum_likes_created_at ON forum_likes(created_at);

-- =====================================================
-- ANALYTICS EVENTS TABLE INDEXES
-- =====================================================
CREATE INDEX idx_analytics_events_user_id ON analytics_events(user_id);
CREATE INDEX idx_analytics_events_event_type ON analytics_events(event_type);
CREATE INDEX idx_analytics_events_course_id ON analytics_events(course_id);
CREATE INDEX idx_analytics_events_video_id ON analytics_events(video_id);
CREATE INDEX idx_analytics_events_quiz_id ON analytics_events(quiz_id);
CREATE INDEX idx_analytics_events_created_at ON analytics_events(created_at);

-- Composite indexes for analytics queries
CREATE INDEX idx_analytics_events_user_type ON analytics_events(user_id, event_type);
CREATE INDEX idx_analytics_events_course_type ON analytics_events(course_id, event_type);
CREATE INDEX idx_analytics_events_type_created ON analytics_events(event_type, created_at);

-- GIN index for JSONB event_data
CREATE INDEX idx_analytics_events_data ON analytics_events USING GIN (event_data);

-- =====================================================
-- ADDITIONAL PERFORMANCE INDEXES
-- =====================================================

-- Text search indexes for search functionality
CREATE INDEX idx_courses_title_search ON courses USING GIN (to_tsvector('english', title));
CREATE INDEX idx_courses_description_search ON courses USING GIN (to_tsvector('english', description));
CREATE INDEX idx_forum_posts_title_search ON forum_posts USING GIN (to_tsvector('english', title));
CREATE INDEX idx_forum_posts_content_search ON forum_posts USING GIN (to_tsvector('english', content));

-- Partial indexes for active/approved records
CREATE INDEX idx_courses_active_approved ON courses(id) WHERE is_approved = true;
CREATE INDEX idx_quizzes_active ON quizzes(id) WHERE is_active = true;
CREATE INDEX idx_worksheets_active ON worksheets(id) WHERE is_active = true;
CREATE INDEX idx_profiles_active ON profiles(id) WHERE is_active = true;

-- Time-based partial indexes for recent data
CREATE INDEX idx_courses_recent ON courses(created_at) WHERE created_at > NOW() - INTERVAL '30 days';
CREATE INDEX idx_enrollments_recent ON enrollments(enrolled_at) WHERE enrolled_at > NOW() - INTERVAL '30 days';
CREATE INDEX idx_quiz_submissions_recent ON quiz_submissions(submitted_at) WHERE submitted_at > NOW() - INTERVAL '30 days';
CREATE INDEX idx_analytics_events_recent ON analytics_events(created_at) WHERE created_at > NOW() - INTERVAL '7 days';
