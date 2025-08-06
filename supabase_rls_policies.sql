-- =====================================================
-- BLApp - Row Level Security (RLS) Policies
-- =====================================================
-- This file contains all RLS policies for secure data access

-- =====================================================
-- ENABLE RLS ON ALL TABLES
-- =====================================================
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
-- PROFILES TABLE POLICIES
-- =====================================================

-- Users can view their own profile and other profiles (for instructor/author info)
CREATE POLICY "Users can view profiles" ON profiles
    FOR SELECT USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Users can insert their own profile (handled by trigger)
CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Admins can manage all profiles
CREATE POLICY "Admins can manage all profiles" ON profiles
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =====================================================
-- COURSES TABLE POLICIES
-- =====================================================

-- Everyone can view approved courses
CREATE POLICY "Anyone can view approved courses" ON courses
    FOR SELECT USING (is_approved = true);

-- Instructors can view their own courses (approved or not)
CREATE POLICY "Instructors can view own courses" ON courses
    FOR SELECT USING (instructor_id = auth.uid());

-- Admins can view all courses
CREATE POLICY "Admins can view all courses" ON courses
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Instructors can create courses
CREATE POLICY "Instructors can create courses" ON courses
    FOR INSERT WITH CHECK (
        instructor_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'instructor'
        )
    );

-- Instructors can update their own courses
CREATE POLICY "Instructors can update own courses" ON courses
    FOR UPDATE USING (instructor_id = auth.uid());

-- Admins can update all courses (for approval)
CREATE POLICY "Admins can update all courses" ON courses
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =====================================================
-- VIDEOS TABLE POLICIES
-- =====================================================

-- Users can view videos of approved courses or courses they're enrolled in
CREATE POLICY "Users can view accessible videos" ON videos
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = videos.course_id 
            AND (
                c.is_approved = true OR
                c.instructor_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM enrollments e
                    WHERE e.course_id = c.id AND e.student_id = auth.uid()
                ) OR
                EXISTS (
                    SELECT 1 FROM profiles p
                    WHERE p.id = auth.uid() AND p.role = 'admin'
                )
            )
        )
    );

-- Instructors can manage videos for their courses
CREATE POLICY "Instructors can manage own course videos" ON videos
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = videos.course_id AND c.instructor_id = auth.uid()
        )
    );

-- =====================================================
-- QUIZZES TABLE POLICIES
-- =====================================================

-- Users can view quizzes of accessible courses
CREATE POLICY "Users can view accessible quizzes" ON quizzes
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = quizzes.course_id 
            AND (
                c.is_approved = true OR
                c.instructor_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM enrollments e
                    WHERE e.course_id = c.id AND e.student_id = auth.uid()
                ) OR
                EXISTS (
                    SELECT 1 FROM profiles p
                    WHERE p.id = auth.uid() AND p.role = 'admin'
                )
            )
        )
    );

-- Instructors can manage quizzes for their courses
CREATE POLICY "Instructors can manage own course quizzes" ON quizzes
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = quizzes.course_id AND c.instructor_id = auth.uid()
        )
    );

-- =====================================================
-- QUESTIONS TABLE POLICIES
-- =====================================================

-- Users can view questions of accessible quizzes
CREATE POLICY "Users can view accessible questions" ON questions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM quizzes q
            JOIN courses c ON c.id = q.course_id
            WHERE q.id = questions.quiz_id 
            AND (
                c.is_approved = true OR
                c.instructor_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM enrollments e
                    WHERE e.course_id = c.id AND e.student_id = auth.uid()
                ) OR
                EXISTS (
                    SELECT 1 FROM profiles p
                    WHERE p.id = auth.uid() AND p.role = 'admin'
                )
            )
        )
    );

-- Instructors can manage questions for their course quizzes
CREATE POLICY "Instructors can manage own course questions" ON questions
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM quizzes q
            JOIN courses c ON c.id = q.course_id
            WHERE q.id = questions.quiz_id AND c.instructor_id = auth.uid()
        )
    );

-- =====================================================
-- WORKSHEETS TABLE POLICIES
-- =====================================================

-- Users can view worksheets of accessible courses
CREATE POLICY "Users can view accessible worksheets" ON worksheets
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = worksheets.course_id 
            AND (
                c.is_approved = true OR
                c.instructor_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM enrollments e
                    WHERE e.course_id = c.id AND e.student_id = auth.uid()
                ) OR
                EXISTS (
                    SELECT 1 FROM profiles p
                    WHERE p.id = auth.uid() AND p.role = 'admin'
                )
            )
        )
    );

-- Instructors can manage worksheets for their courses
CREATE POLICY "Instructors can manage own course worksheets" ON worksheets
    FOR ALL USING (instructor_id = auth.uid());

-- =====================================================
-- ENROLLMENTS TABLE POLICIES
-- =====================================================

-- Students can view their own enrollments
CREATE POLICY "Students can view own enrollments" ON enrollments
    FOR SELECT USING (student_id = auth.uid());

-- Instructors can view enrollments for their courses
CREATE POLICY "Instructors can view course enrollments" ON enrollments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = enrollments.course_id AND c.instructor_id = auth.uid()
        )
    );

-- Admins can view all enrollments
CREATE POLICY "Admins can view all enrollments" ON enrollments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Students can enroll in approved courses
CREATE POLICY "Students can enroll in courses" ON enrollments
    FOR INSERT WITH CHECK (
        student_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = enrollments.course_id AND c.is_approved = true
        ) AND
        EXISTS (
            SELECT 1 FROM profiles p
            WHERE p.id = auth.uid() AND p.role = 'student'
        )
    );

-- Students can update their own enrollment progress
CREATE POLICY "Students can update own enrollment" ON enrollments
    FOR UPDATE USING (student_id = auth.uid());

-- =====================================================
-- VIDEO PROGRESS TABLE POLICIES
-- =====================================================

-- Students can view and manage their own video progress
CREATE POLICY "Students can manage own video progress" ON video_progress
    FOR ALL USING (student_id = auth.uid());

-- Instructors can view video progress for their course videos
CREATE POLICY "Instructors can view course video progress" ON video_progress
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM videos v
            JOIN courses c ON c.id = v.course_id
            WHERE v.id = video_progress.video_id AND c.instructor_id = auth.uid()
        )
    );

-- =====================================================
-- QUIZ SUBMISSIONS TABLE POLICIES
-- =====================================================

-- Students can view their own quiz submissions
CREATE POLICY "Students can view own quiz submissions" ON quiz_submissions
    FOR SELECT USING (student_id = auth.uid());

-- Students can create quiz submissions for enrolled courses
CREATE POLICY "Students can submit quizzes" ON quiz_submissions
    FOR INSERT WITH CHECK (
        student_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM quizzes q
            JOIN courses c ON c.id = q.course_id
            JOIN enrollments e ON e.course_id = c.id
            WHERE q.id = quiz_submissions.quiz_id 
            AND e.student_id = auth.uid()
        )
    );

-- Instructors can view submissions for their course quizzes
CREATE POLICY "Instructors can view course quiz submissions" ON quiz_submissions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM quizzes q
            JOIN courses c ON c.id = q.course_id
            WHERE q.id = quiz_submissions.quiz_id AND c.instructor_id = auth.uid()
        )
    );

-- =====================================================
-- FORUM POSTS TABLE POLICIES
-- =====================================================

-- Users can view forum posts for courses they have access to
CREATE POLICY "Users can view accessible forum posts" ON forum_posts
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = forum_posts.course_id
            AND (
                c.is_approved = true OR
                c.instructor_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM enrollments e
                    WHERE e.course_id = c.id AND e.student_id = auth.uid()
                ) OR
                EXISTS (
                    SELECT 1 FROM profiles p
                    WHERE p.id = auth.uid() AND p.role = 'admin'
                )
            )
        )
    );

-- Enrolled students and instructors can create forum posts
CREATE POLICY "Enrolled users can create forum posts" ON forum_posts
    FOR INSERT WITH CHECK (
        author_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = forum_posts.course_id
            AND (
                c.instructor_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM enrollments e
                    WHERE e.course_id = c.id AND e.student_id = auth.uid()
                )
            )
        )
    );

-- Users can update their own forum posts
CREATE POLICY "Users can update own forum posts" ON forum_posts
    FOR UPDATE USING (author_id = auth.uid());

-- Users can delete their own forum posts
CREATE POLICY "Users can delete own forum posts" ON forum_posts
    FOR DELETE USING (author_id = auth.uid());

-- Admins can manage all forum posts
CREATE POLICY "Admins can manage all forum posts" ON forum_posts
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =====================================================
-- FORUM REPLIES TABLE POLICIES
-- =====================================================

-- Users can view forum replies for accessible posts
CREATE POLICY "Users can view accessible forum replies" ON forum_replies
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM forum_posts fp
            JOIN courses c ON c.id = fp.course_id
            WHERE fp.id = forum_replies.post_id
            AND (
                c.is_approved = true OR
                c.instructor_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM enrollments e
                    WHERE e.course_id = c.id AND e.student_id = auth.uid()
                ) OR
                EXISTS (
                    SELECT 1 FROM profiles p
                    WHERE p.id = auth.uid() AND p.role = 'admin'
                )
            )
        )
    );

-- Enrolled users can create forum replies
CREATE POLICY "Enrolled users can create forum replies" ON forum_replies
    FOR INSERT WITH CHECK (
        author_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM forum_posts fp
            JOIN courses c ON c.id = fp.course_id
            WHERE fp.id = forum_replies.post_id
            AND (
                c.instructor_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM enrollments e
                    WHERE e.course_id = c.id AND e.student_id = auth.uid()
                )
            )
        )
    );

-- Users can update their own forum replies
CREATE POLICY "Users can update own forum replies" ON forum_replies
    FOR UPDATE USING (author_id = auth.uid());

-- Users can delete their own forum replies
CREATE POLICY "Users can delete own forum replies" ON forum_replies
    FOR DELETE USING (author_id = auth.uid());

-- =====================================================
-- FORUM LIKES TABLE POLICIES
-- =====================================================

-- Users can view likes for accessible posts/replies
CREATE POLICY "Users can view accessible forum likes" ON forum_likes
    FOR SELECT USING (
        (post_id IS NOT NULL AND EXISTS (
            SELECT 1 FROM forum_posts fp
            JOIN courses c ON c.id = fp.course_id
            WHERE fp.id = forum_likes.post_id
            AND (
                c.is_approved = true OR
                c.instructor_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM enrollments e
                    WHERE e.course_id = c.id AND e.student_id = auth.uid()
                )
            )
        )) OR
        (reply_id IS NOT NULL AND EXISTS (
            SELECT 1 FROM forum_replies fr
            JOIN forum_posts fp ON fp.id = fr.post_id
            JOIN courses c ON c.id = fp.course_id
            WHERE fr.id = forum_likes.reply_id
            AND (
                c.is_approved = true OR
                c.instructor_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM enrollments e
                    WHERE e.course_id = c.id AND e.student_id = auth.uid()
                )
            )
        ))
    );

-- Users can manage their own likes
CREATE POLICY "Users can manage own forum likes" ON forum_likes
    FOR ALL USING (user_id = auth.uid());

-- =====================================================
-- ANALYTICS EVENTS TABLE POLICIES
-- =====================================================

-- Users can view their own analytics events
CREATE POLICY "Users can view own analytics" ON analytics_events
    FOR SELECT USING (user_id = auth.uid());

-- Users can create their own analytics events
CREATE POLICY "Users can create own analytics" ON analytics_events
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Instructors can view analytics for their courses
CREATE POLICY "Instructors can view course analytics" ON analytics_events
    FOR SELECT USING (
        course_id IS NOT NULL AND
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = analytics_events.course_id AND c.instructor_id = auth.uid()
        )
    );

-- Admins can view all analytics
CREATE POLICY "Admins can view all analytics" ON analytics_events
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );
