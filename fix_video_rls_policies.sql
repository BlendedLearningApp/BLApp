-- =====================================================
-- FIX VIDEO RLS POLICIES
-- =====================================================
-- Run this in Supabase SQL Editor to fix video creation issues

-- 1. Check current RLS status for videos table
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'videos';

-- 2. Check existing policies on videos table
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'videos';

-- 3. Check if the instructor exists and has the right permissions
SELECT 
    id,
    name,
    email,
    role,
    approval_status,
    is_active
FROM profiles 
WHERE id = 'bea343bd-4ae1-47c4-82e5-8f53361be995';

-- 4. Check if the course exists and belongs to the instructor
SELECT 
    id,
    title,
    instructor_id,
    is_approved,
    created_at
FROM courses 
WHERE id = '9a68955f-5ab6-4ddb-a1c7-36ad4ea4c17d';

-- 5. Test the policy condition manually
SELECT 
    'Policy Test' as test_type,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = '9a68955f-5ab6-4ddb-a1c7-36ad4ea4c17d' 
            AND c.instructor_id = 'bea343bd-4ae1-47c4-82e5-8f53361be995'
        ) THEN 'POLICY SHOULD PASS'
        ELSE 'POLICY WILL FAIL'
    END as policy_result;

-- 6. Drop existing problematic policies
DROP POLICY IF EXISTS "Users can view accessible videos" ON videos;
DROP POLICY IF EXISTS "Instructors can manage own course videos" ON videos;

-- 7. Create new, more explicit policies

-- Policy for instructors to insert videos
CREATE POLICY "Instructors can insert videos for their courses" ON videos
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = videos.course_id 
            AND c.instructor_id = auth.uid()
            AND EXISTS (
                SELECT 1 FROM profiles p
                WHERE p.id = auth.uid() 
                AND p.role = 'instructor'
                AND p.approval_status = 'approved'
                AND p.is_active = true
            )
        )
    );

-- Policy for instructors to select videos from their courses
CREATE POLICY "Instructors can select videos from their courses" ON videos
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = videos.course_id 
            AND c.instructor_id = auth.uid()
            AND EXISTS (
                SELECT 1 FROM profiles p
                WHERE p.id = auth.uid() 
                AND p.role = 'instructor'
            )
        )
    );

-- Policy for instructors to update videos in their courses
CREATE POLICY "Instructors can update videos in their courses" ON videos
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = videos.course_id 
            AND c.instructor_id = auth.uid()
            AND EXISTS (
                SELECT 1 FROM profiles p
                WHERE p.id = auth.uid() 
                AND p.role = 'instructor'
            )
        )
    );

-- Policy for instructors to delete videos from their courses
CREATE POLICY "Instructors can delete videos from their courses" ON videos
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = videos.course_id 
            AND c.instructor_id = auth.uid()
            AND EXISTS (
                SELECT 1 FROM profiles p
                WHERE p.id = auth.uid() 
                AND p.role = 'instructor'
            )
        )
    );

-- Policy for students to view videos from enrolled courses
CREATE POLICY "Students can view videos from enrolled courses" ON videos
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses c
            JOIN enrollments e ON e.course_id = c.id
            WHERE c.id = videos.course_id 
            AND e.student_id = auth.uid()
            AND c.is_approved = true
            AND EXISTS (
                SELECT 1 FROM profiles p
                WHERE p.id = auth.uid() 
                AND p.role = 'student'
            )
        )
    );

-- Policy for admins to have full access
CREATE POLICY "Admins have full access to videos" ON videos
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles p
            WHERE p.id = auth.uid() 
            AND p.role = 'admin'
        )
    );

-- 8. Test the new policy with a simulated insert
SELECT 
    'New Policy Test' as test_type,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = '9a68955f-5ab6-4ddb-a1c7-36ad4ea4c17d' 
            AND c.instructor_id = 'bea343bd-4ae1-47c4-82e5-8f53361be995'
            AND EXISTS (
                SELECT 1 FROM profiles p
                WHERE p.id = 'bea343bd-4ae1-47c4-82e5-8f53361be995'
                AND p.role = 'instructor'
                AND p.approval_status = 'approved'
                AND p.is_active = true
            )
        ) THEN 'NEW POLICY SHOULD PASS'
        ELSE 'NEW POLICY WILL FAIL'
    END as policy_result;

-- =====================================================
-- NOTES:
-- =====================================================
-- 1. Run this step by step to identify the exact issue
-- 2. The new policies are more explicit about permissions
-- 3. Each operation (INSERT, SELECT, UPDATE, DELETE) has its own policy
-- 4. The policies check both course ownership and user role/approval
-- =====================================================
