-- =====================================================
-- DEPLOY ANALYTICS FUNCTION FOR ADMIN DASHBOARD
-- =====================================================
-- This script ensures the get_system_analytics function is properly created
-- Run this in your Supabase SQL editor to fix the admin dashboard error

-- Drop the function first to ensure clean recreation
DROP FUNCTION IF EXISTS public.get_system_analytics();

-- Create the system analytics function with proper error handling
CREATE OR REPLACE FUNCTION public.get_system_analytics()
RETURNS JSON AS $$
DECLARE
    result JSON;
    total_users_count INTEGER;
    total_students_count INTEGER;
    total_instructors_count INTEGER;
    total_admins_count INTEGER;
    total_courses_count INTEGER;
    approved_courses_count INTEGER;
    pending_courses_count INTEGER;
    total_enrollments_count INTEGER;
    total_videos_count INTEGER;
    total_quizzes_count INTEGER;
    total_quiz_submissions_count INTEGER;
    total_forum_posts_count INTEGER;
    total_forum_replies_count INTEGER;
    avg_course_rating NUMERIC;
    completion_rate_value NUMERIC;
    quiz_pass_rate_value NUMERIC;
BEGIN
    -- Get user counts with error handling
    BEGIN
        SELECT COUNT(*) INTO total_users_count FROM profiles;
        SELECT COUNT(*) INTO total_students_count FROM profiles WHERE role = 'student';
        SELECT COUNT(*) INTO total_instructors_count FROM profiles WHERE role = 'instructor';
        SELECT COUNT(*) INTO total_admins_count FROM profiles WHERE role = 'admin';
    EXCEPTION WHEN OTHERS THEN
        total_users_count := 0;
        total_students_count := 0;
        total_instructors_count := 0;
        total_admins_count := 0;
    END;

    -- Get course counts with error handling
    BEGIN
        SELECT COUNT(*) INTO total_courses_count FROM courses;
        SELECT COUNT(*) INTO approved_courses_count FROM courses WHERE is_approved = true;
        SELECT COUNT(*) INTO pending_courses_count FROM courses WHERE is_approved = false;
    EXCEPTION WHEN OTHERS THEN
        total_courses_count := 0;
        approved_courses_count := 0;
        pending_courses_count := 0;
    END;

    -- Get other counts with error handling
    BEGIN
        SELECT COUNT(*) INTO total_enrollments_count FROM enrollments;
    EXCEPTION WHEN OTHERS THEN
        total_enrollments_count := 0;
    END;

    BEGIN
        SELECT COUNT(*) INTO total_videos_count FROM videos;
    EXCEPTION WHEN OTHERS THEN
        total_videos_count := 0;
    END;

    BEGIN
        SELECT COUNT(*) INTO total_quizzes_count FROM quizzes;
    EXCEPTION WHEN OTHERS THEN
        total_quizzes_count := 0;
    END;

    BEGIN
        SELECT COUNT(*) INTO total_quiz_submissions_count FROM quiz_submissions;
    EXCEPTION WHEN OTHERS THEN
        total_quiz_submissions_count := 0;
    END;

    BEGIN
        SELECT COUNT(*) INTO total_forum_posts_count FROM forum_posts;
    EXCEPTION WHEN OTHERS THEN
        total_forum_posts_count := 0;
    END;

    BEGIN
        SELECT COUNT(*) INTO total_forum_replies_count FROM forum_replies;
    EXCEPTION WHEN OTHERS THEN
        total_forum_replies_count := 0;
    END;

    -- Get average course rating with error handling
    BEGIN
        SELECT COALESCE(AVG(rating), 0) INTO avg_course_rating FROM courses WHERE is_approved = true;
    EXCEPTION WHEN OTHERS THEN
        avg_course_rating := 0;
    END;

    -- Get completion rate with error handling
    BEGIN
        SELECT COALESCE(
            COUNT(CASE WHEN completed_at IS NOT NULL THEN 1 END)::float / 
            NULLIF(COUNT(*), 0) * 100, 0
        ) INTO completion_rate_value FROM enrollments;
    EXCEPTION WHEN OTHERS THEN
        completion_rate_value := 0;
    END;

    -- Get quiz pass rate with error handling
    BEGIN
        SELECT COALESCE(
            COUNT(CASE WHEN passed THEN 1 END)::float / 
            NULLIF(COUNT(*), 0) * 100, 0
        ) INTO quiz_pass_rate_value FROM quiz_submissions;
    EXCEPTION WHEN OTHERS THEN
        quiz_pass_rate_value := 0;
    END;

    -- Build the result JSON
    SELECT json_build_object(
        'total_users', total_users_count,
        'total_students', total_students_count,
        'total_instructors', total_instructors_count,
        'total_admins', total_admins_count,
        'total_courses', total_courses_count,
        'approved_courses', approved_courses_count,
        'pending_courses', pending_courses_count,
        'total_enrollments', total_enrollments_count,
        'total_videos', total_videos_count,
        'total_quizzes', total_quizzes_count,
        'total_quiz_submissions', total_quiz_submissions_count,
        'total_forum_posts', total_forum_posts_count,
        'total_forum_replies', total_forum_replies_count,
        'average_course_rating', avg_course_rating,
        'completion_rate', completion_rate_value,
        'quiz_pass_rate', quiz_pass_rate_value
    ) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Test the function to ensure it works
SELECT public.get_system_analytics();

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_system_analytics() TO authenticated;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- Run these to verify the function works correctly:

-- 1. Check if function exists
SELECT proname, proargnames, prosrc 
FROM pg_proc 
WHERE proname = 'get_system_analytics';

-- 2. Test function execution
SELECT public.get_system_analytics();

-- 3. Check permissions
SELECT grantee, privilege_type 
FROM information_schema.routine_privileges 
WHERE routine_name = 'get_system_analytics';
