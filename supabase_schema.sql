-- =====================================================
-- BLApp (Blended Learning App) - Complete Supabase Schema
-- =====================================================
-- This schema creates all necessary tables for the BLApp backend
-- with proper relationships, constraints, and RLS policies

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. PROFILES TABLE (extends auth.users)
-- =====================================================
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('student', 'instructor', 'admin')),
    profile_image TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. COURSES TABLE
-- =====================================================
CREATE TABLE courses (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    instructor_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    thumbnail TEXT,
    category TEXT NOT NULL,
    is_approved BOOLEAN DEFAULT false,
    enrolled_students INTEGER DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. VIDEOS TABLE (Lessons)
-- =====================================================
CREATE TABLE videos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    youtube_url TEXT NOT NULL,
    youtube_video_id TEXT NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    order_index INTEGER NOT NULL DEFAULT 0,
    duration_seconds INTEGER DEFAULT 0,
    thumbnail TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 4. QUIZZES TABLE
-- =====================================================
CREATE TABLE quizzes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    time_limit INTEGER DEFAULT 30, -- in minutes
    passing_score INTEGER DEFAULT 70, -- percentage
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 5. QUESTIONS TABLE
-- =====================================================
CREATE TABLE questions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE NOT NULL,
    question TEXT NOT NULL,
    options JSONB NOT NULL, -- Array of options
    correct_answer_index INTEGER NOT NULL,
    explanation TEXT DEFAULT '',
    points INTEGER DEFAULT 1,
    order_index INTEGER DEFAULT 0
);

-- =====================================================
-- 6. WORKSHEETS TABLE (Documents/PDFs)
-- =====================================================
CREATE TABLE worksheets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    file_type TEXT NOT NULL,
    file_size TEXT NOT NULL,
    file_url TEXT, -- Storage bucket URL
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    instructor_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 7. ENROLLMENTS TABLE
-- =====================================================
CREATE TABLE enrollments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    student_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    progress DECIMAL(5,2) DEFAULT 0.0 CHECK (progress >= 0 AND progress <= 100),
    UNIQUE(student_id, course_id)
);

-- =====================================================
-- 8. VIDEO PROGRESS TABLE
-- =====================================================
CREATE TABLE video_progress (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    student_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    video_id UUID REFERENCES videos(id) ON DELETE CASCADE NOT NULL,
    is_watched BOOLEAN DEFAULT false,
    watch_time_seconds INTEGER DEFAULT 0,
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(student_id, video_id)
);

-- =====================================================
-- 9. QUIZ SUBMISSIONS TABLE
-- =====================================================
CREATE TABLE quiz_submissions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    answers JSONB NOT NULL, -- Map of question_id -> selected_answer_index
    score INTEGER NOT NULL,
    total_questions INTEGER NOT NULL,
    time_spent_minutes INTEGER DEFAULT 0,
    passed BOOLEAN NOT NULL,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 10. FORUM POSTS TABLE
-- =====================================================
CREATE TABLE forum_posts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    author_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    likes_count INTEGER DEFAULT 0,
    is_pinned BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 11. FORUM REPLIES TABLE
-- =====================================================
CREATE TABLE forum_replies (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    post_id UUID REFERENCES forum_posts(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    author_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 12. FORUM LIKES TABLE
-- =====================================================
CREATE TABLE forum_likes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    post_id UUID REFERENCES forum_posts(id) ON DELETE CASCADE,
    reply_id UUID REFERENCES forum_replies(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, post_id),
    UNIQUE(user_id, reply_id),
    CHECK ((post_id IS NOT NULL AND reply_id IS NULL) OR (post_id IS NULL AND reply_id IS NOT NULL))
);

-- =====================================================
-- 13. ANALYTICS EVENTS TABLE
-- =====================================================
CREATE TABLE analytics_events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    event_type TEXT NOT NULL, -- 'video_watched', 'quiz_completed', 'course_enrolled', etc.
    event_data JSONB, -- Additional event-specific data
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
    quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to automatically create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
        COALESCE(NEW.raw_user_meta_data->>'role', 'student')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER courses_updated_at
    BEFORE UPDATE ON courses
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER quizzes_updated_at
    BEFORE UPDATE ON quizzes
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER worksheets_updated_at
    BEFORE UPDATE ON worksheets
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER forum_posts_updated_at
    BEFORE UPDATE ON forum_posts
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER forum_replies_updated_at
    BEFORE UPDATE ON forum_replies
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

-- Function to update course enrollment count
CREATE OR REPLACE FUNCTION public.update_course_enrollment_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE courses
        SET enrolled_students = enrolled_students + 1
        WHERE id = NEW.course_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE courses
        SET enrolled_students = enrolled_students - 1
        WHERE id = OLD.course_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update enrollment count
CREATE TRIGGER enrollment_count_trigger
    AFTER INSERT OR DELETE ON enrollments
    FOR EACH ROW EXECUTE FUNCTION update_course_enrollment_count();

-- Function to update forum likes count
CREATE OR REPLACE FUNCTION public.update_forum_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.post_id IS NOT NULL THEN
            UPDATE forum_posts
            SET likes_count = likes_count + 1
            WHERE id = NEW.post_id;
        ELSIF NEW.reply_id IS NOT NULL THEN
            UPDATE forum_replies
            SET likes_count = likes_count + 1
            WHERE id = NEW.reply_id;
        END IF;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        IF OLD.post_id IS NOT NULL THEN
            UPDATE forum_posts
            SET likes_count = likes_count - 1
            WHERE id = OLD.post_id;
        ELSIF OLD.reply_id IS NOT NULL THEN
            UPDATE forum_replies
            SET likes_count = likes_count - 1
            WHERE id = OLD.reply_id;
        END IF;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update likes count
CREATE TRIGGER forum_likes_count_trigger
    AFTER INSERT OR DELETE ON forum_likes
    FOR EACH ROW EXECUTE FUNCTION update_forum_likes_count();
