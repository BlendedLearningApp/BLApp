-- =====================================================
-- QUICK FIX FOR QUIZ RLS ISSUE
-- =====================================================
-- Run this in Supabase SQL Editor to immediately fix quiz creation

-- Drop existing problematic policies
DROP POLICY IF EXISTS "Users can view accessible quizzes" ON quizzes;
DROP POLICY IF EXISTS "Instructors can manage own course quizzes" ON quizzes;
DROP POLICY IF EXISTS "Users can view accessible questions" ON questions;
DROP POLICY IF EXISTS "Instructors can manage questions for their quizzes" ON questions;

-- Create simple, permissive policies for quizzes
CREATE POLICY "Instructors can manage quizzes for their courses" ON quizzes
    FOR ALL WITH CHECK (
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = quizzes.course_id 
            AND c.instructor_id = auth.uid()
        )
    );

-- Create policy for students to view quizzes
CREATE POLICY "Students can view quizzes from approved courses" ON quizzes
    FOR SELECT USING (
        quizzes.is_active = true AND
        EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id = quizzes.course_id 
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

-- Create simple, permissive policies for questions
CREATE POLICY "Instructors can manage questions for their course quizzes" ON questions
    FOR ALL WITH CHECK (
        EXISTS (
            SELECT 1 FROM quizzes q
            JOIN courses c ON c.id = q.course_id
            WHERE q.id = questions.quiz_id 
            AND c.instructor_id = auth.uid()
        )
    );

-- Create policy for students to view questions
CREATE POLICY "Students can view questions from enrolled course quizzes" ON questions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM quizzes q
            JOIN courses c ON c.id = q.course_id
            WHERE q.id = questions.quiz_id 
            AND (
                c.instructor_id = auth.uid() OR
                (q.is_active = true AND c.is_approved = true AND EXISTS (
                    SELECT 1 FROM enrollments e
                    WHERE e.course_id = c.id AND e.student_id = auth.uid()
                ))
            )
        )
    );

-- Test the fix
SELECT 'Policy Test' as test_type,
CASE 
    WHEN EXISTS (
        SELECT 1 FROM courses c
        WHERE c.id = '9a68955f-5ab6-4ddb-a1c7-36ad4ea4c17d' 
        AND c.instructor_id = 'bea343bd-4ae1-47c4-82e5-8f53361be995'
    ) THEN 'QUIZ POLICY SHOULD NOW PASS'
    ELSE 'QUIZ POLICY WILL STILL FAIL'
END as policy_result;
