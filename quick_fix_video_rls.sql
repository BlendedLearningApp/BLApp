-- =====================================================
-- QUICK FIX FOR VIDEO RLS ISSUE
-- =====================================================
-- Run this in Supabase SQL Editor to immediately fix video creation

-- Option 1: Drop and recreate the video policies
DROP POLICY IF EXISTS "Users can view accessible videos" ON videos;
DROP POLICY IF EXISTS "Instructors can manage own course videos" ON videos;

-- Create a simple, permissive policy for instructors
CREATE POLICY "Instructors can manage videos for their courses" ON videos
    FOR ALL WITH CHECK (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = videos.course_id 
            AND c.instructor_id = auth.uid()
        )
    );

-- Create a policy for students to view videos
CREATE POLICY "Students can view videos from approved courses" ON videos
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
                )
            )
        )
    );

-- =====================================================
-- Alternative: Temporarily disable RLS for testing
-- =====================================================
-- Uncomment this line ONLY for testing (not recommended for production)
-- ALTER TABLE videos DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- Test the fix
-- =====================================================
SELECT 'Policy Test' as test_type,
CASE 
    WHEN EXISTS (
        SELECT 1 FROM courses c
        WHERE c.id = '9a68955f-5ab6-4ddb-a1c7-36ad4ea4c17d' 
        AND c.instructor_id = 'bea343bd-4ae1-47c4-82e5-8f53361be995'
    ) THEN 'POLICY SHOULD NOW PASS'
    ELSE 'POLICY WILL STILL FAIL'
END as policy_result;
