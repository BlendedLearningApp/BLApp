-- =====================================================
-- BLApp Supabase Complete Deployment Script
-- =====================================================
-- Execute this script in your Supabase SQL Editor to set up the complete backend
-- This script combines all the individual SQL files in the correct order

-- =====================================================
-- STEP 1: ENABLE EXTENSIONS AND CREATE SCHEMA
-- =====================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- STEP 2: CREATE ALL TABLES
-- =====================================================

-- 1. PROFILES TABLE (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('student', 'instructor', 'admin')),
    profile_image TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. COURSES TABLE
CREATE TABLE IF NOT EXISTS courses (
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

-- 3. VIDEOS TABLE (Lessons)
CREATE TABLE IF NOT EXISTS videos (
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

-- 4. QUIZZES TABLE
CREATE TABLE IF NOT EXISTS quizzes (
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

-- 5. QUESTIONS TABLE
CREATE TABLE IF NOT EXISTS questions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE NOT NULL,
    question TEXT NOT NULL,
    options JSONB NOT NULL, -- Array of options
    correct_answer_index INTEGER NOT NULL,
    explanation TEXT DEFAULT '',
    points INTEGER DEFAULT 1,
    order_index INTEGER DEFAULT 0
);

-- 6. WORKSHEETS TABLE (Documents/PDFs)
CREATE TABLE IF NOT EXISTS worksheets (
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

-- 7. ENROLLMENTS TABLE
CREATE TABLE IF NOT EXISTS enrollments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    student_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    progress DECIMAL(5,2) DEFAULT 0.0 CHECK (progress >= 0 AND progress <= 100),
    UNIQUE(student_id, course_id)
);

-- 8. VIDEO PROGRESS TABLE
CREATE TABLE IF NOT EXISTS video_progress (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    student_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    video_id UUID REFERENCES videos(id) ON DELETE CASCADE NOT NULL,
    is_watched BOOLEAN DEFAULT false,
    watch_time_seconds INTEGER DEFAULT 0,
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(student_id, video_id)
);

-- 9. QUIZ SUBMISSIONS TABLE
CREATE TABLE IF NOT EXISTS quiz_submissions (
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

-- 10. FORUM POSTS TABLE
CREATE TABLE IF NOT EXISTS forum_posts (
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

-- 11. FORUM REPLIES TABLE
CREATE TABLE IF NOT EXISTS forum_replies (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    post_id UUID REFERENCES forum_posts(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    author_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 12. FORUM LIKES TABLE
CREATE TABLE IF NOT EXISTS forum_likes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    post_id UUID REFERENCES forum_posts(id) ON DELETE CASCADE,
    reply_id UUID REFERENCES forum_replies(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, post_id),
    UNIQUE(user_id, reply_id),
    CHECK ((post_id IS NOT NULL AND reply_id IS NULL) OR (post_id IS NULL AND reply_id IS NOT NULL))
);

-- 13. ANALYTICS EVENTS TABLE
CREATE TABLE IF NOT EXISTS analytics_events (
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
-- STEP 3: CREATE FUNCTIONS AND TRIGGERS
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
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
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

-- Apply updated_at triggers
DROP TRIGGER IF EXISTS profiles_updated_at ON profiles;
CREATE TRIGGER profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

DROP TRIGGER IF EXISTS courses_updated_at ON courses;
CREATE TRIGGER courses_updated_at
    BEFORE UPDATE ON courses
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

DROP TRIGGER IF EXISTS quizzes_updated_at ON quizzes;
CREATE TRIGGER quizzes_updated_at
    BEFORE UPDATE ON quizzes
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

DROP TRIGGER IF EXISTS worksheets_updated_at ON worksheets;
CREATE TRIGGER worksheets_updated_at
    BEFORE UPDATE ON worksheets
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

DROP TRIGGER IF EXISTS forum_posts_updated_at ON forum_posts;
CREATE TRIGGER forum_posts_updated_at
    BEFORE UPDATE ON forum_posts
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

DROP TRIGGER IF EXISTS forum_replies_updated_at ON forum_replies;
CREATE TRIGGER forum_replies_updated_at
    BEFORE UPDATE ON forum_replies
    FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

-- =====================================================
-- STEP 4: ENABLE ROW LEVEL SECURITY
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE worksheets ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_replies ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- STEP 5: CREATE ESSENTIAL RLS POLICIES
-- =====================================================

-- Profiles policies
DROP POLICY IF EXISTS "Users can view profiles" ON profiles;
CREATE POLICY "Users can view profiles" ON profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Courses policies
DROP POLICY IF EXISTS "Anyone can view approved courses" ON courses;
CREATE POLICY "Anyone can view approved courses" ON courses FOR SELECT USING (is_approved = true);

DROP POLICY IF EXISTS "Instructors can view own courses" ON courses;
CREATE POLICY "Instructors can view own courses" ON courses FOR SELECT USING (instructor_id = auth.uid());

-- Enrollments policies
DROP POLICY IF EXISTS "Students can view own enrollments" ON enrollments;
CREATE POLICY "Students can view own enrollments" ON enrollments FOR SELECT USING (student_id = auth.uid());

-- =====================================================
-- STEP 6: CREATE PERFORMANCE INDEXES
-- =====================================================

-- Essential indexes
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_courses_instructor_id ON courses(instructor_id);
CREATE INDEX IF NOT EXISTS idx_courses_is_approved ON courses(is_approved);
CREATE INDEX IF NOT EXISTS idx_videos_course_id ON videos(course_id);
CREATE INDEX IF NOT EXISTS idx_quizzes_course_id ON quizzes(course_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_student_id ON enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course_id ON enrollments(course_id);

-- =====================================================
-- DEPLOYMENT COMPLETE
-- =====================================================

-- Display success message
DO $$
BEGIN
    RAISE NOTICE 'BLApp Supabase backend deployment completed successfully!';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '1. Run the dummy data script if you want test data';
    RAISE NOTICE '2. Configure your storage bucket policies';
    RAISE NOTICE '3. Set up your Flutter app with the Supabase client';
    RAISE NOTICE '4. Test the authentication and basic functionality';
END $$;
