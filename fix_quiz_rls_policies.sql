-- =====================================================
-- FIX QUIZ RLS POLICIES
-- =====================================================
-- Run this in Supabase SQL Editor to fix quiz creation issues

-- 1. Check current RLS status for quizzes table
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'quizzes';

-- 2. Check existing policies on quizzes table
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
WHERE tablename = 'quizzes';

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

-- 6. Drop existing problematic policies for quizzes
DROP POLICY IF EXISTS "Users can view accessible quizzes" ON quizzes;
DROP POLICY IF EXISTS "Instructors can manage own course quizzes" ON quizzes;
DROP POLICY IF EXISTS "Instructors can create quizzes for their courses" ON quizzes;
DROP POLICY IF EXISTS "Instructors can view quizzes from their courses" ON quizzes;
DROP POLICY IF EXISTS "Instructors can update quizzes in their courses" ON quizzes;
DROP POLICY IF EXISTS "Instructors can delete quizzes from their courses" ON quizzes;

-- 7. Create new, explicit policies for quizzes

-- Policy for instructors to insert quizzes
CREATE POLICY "Instructors can insert quizzes for their courses" ON quizzes
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = quizzes.course_id 
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

-- Policy for instructors to select quizzes from their courses
CREATE POLICY "Instructors can select quizzes from their courses" ON quizzes
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = quizzes.course_id 
            AND c.instructor_id = auth.uid()
            AND EXISTS (
                SELECT 1 FROM profiles p
                WHERE p.id = auth.uid() 
                AND p.role = 'instructor'
            )
        )
    );

-- Policy for instructors to update quizzes in their courses
CREATE POLICY "Instructors can update quizzes in their courses" ON quizzes
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = quizzes.course_id 
            AND c.instructor_id = auth.uid()
            AND EXISTS (
                SELECT 1 FROM profiles p
                WHERE p.id = auth.uid() 
                AND p.role = 'instructor'
            )
        )
    );

-- Policy for instructors to delete quizzes from their courses
CREATE POLICY "Instructors can delete quizzes from their courses" ON quizzes
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = quizzes.course_id 
            AND c.instructor_id = auth.uid()
            AND EXISTS (
                SELECT 1 FROM profiles p
                WHERE p.id = auth.uid() 
                AND p.role = 'instructor'
            )
        )
    );

-- Policy for students to view quizzes from enrolled courses
CREATE POLICY "Students can view quizzes from enrolled courses" ON quizzes
    FOR SELECT USING (
        quizzes.is_active = true
        AND EXISTS (
            SELECT 1 FROM courses c
            JOIN enrollments e ON e.course_id = c.id
            WHERE c.id = quizzes.course_id 
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
CREATE POLICY "Admins have full access to quizzes" ON quizzes
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles p
            WHERE p.id = auth.uid() 
            AND p.role = 'admin'
        )
    );

-- 8. Also check and fix policies for questions table (since quizzes have questions)

-- Check existing policies on questions table
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
WHERE tablename = 'questions';

-- Drop existing problematic policies for questions
DROP POLICY IF EXISTS "Users can view accessible questions" ON questions;
DROP POLICY IF EXISTS "Instructors can manage questions for their quizzes" ON questions;

-- Create new policies for questions table
CREATE POLICY "Instructors can insert questions for their quizzes" ON questions
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM quizzes q
            JOIN courses c ON c.id = q.course_id
            WHERE q.id = questions.quiz_id 
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

CREATE POLICY "Instructors can select questions from their quizzes" ON questions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM quizzes q
            JOIN courses c ON c.id = q.course_id
            WHERE q.id = questions.quiz_id 
            AND c.instructor_id = auth.uid()
        )
    );

CREATE POLICY "Instructors can update questions in their quizzes" ON questions
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM quizzes q
            JOIN courses c ON c.id = q.course_id
            WHERE q.id = questions.quiz_id 
            AND c.instructor_id = auth.uid()
        )
    );

CREATE POLICY "Instructors can delete questions from their quizzes" ON questions
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM quizzes q
            JOIN courses c ON c.id = q.course_id
            WHERE q.id = questions.quiz_id 
            AND c.instructor_id = auth.uid()
        )
    );

CREATE POLICY "Students can view questions from enrolled course quizzes" ON questions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM quizzes q
            JOIN courses c ON c.id = q.course_id
            JOIN enrollments e ON e.course_id = c.id
            WHERE q.id = questions.quiz_id 
            AND e.student_id = auth.uid()
            AND q.is_active = true
            AND c.is_approved = true
        )
    );

CREATE POLICY "Admins have full access to questions" ON questions
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles p
            WHERE p.id = auth.uid() 
            AND p.role = 'admin'
        )
    );

-- 9. Test the new policies with a simulated insert
SELECT 
    'New Quiz Policy Test' as test_type,
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
        ) THEN 'NEW QUIZ POLICY SHOULD PASS'
        ELSE 'NEW QUIZ POLICY WILL FAIL'
    END as policy_result;

-- =====================================================
-- NOTES:
-- =====================================================
-- 1. Run this step by step to identify any issues
-- 2. The new policies are more explicit about permissions
-- 3. Both quizzes and questions tables need proper policies
-- 4. The policies check course ownership and user role/approval
-- 5. Students can only view active quizzes from enrolled courses
-- =====================================================
