-- =====================================================
-- FIX COURSE CREATION RLS ISSUE
-- =====================================================
-- Run this in Supabase SQL Editor to fix the course creation issue

-- 1. First, let's check the current user's auth context
SELECT 
    auth.uid() as current_auth_uid,
    auth.jwt() ->> 'email' as current_auth_email;

-- 2. Check if the instructor profile exists and matches
SELECT 
    p.id,
    p.name,
    p.email,
    p.role,
    p.approval_status,
    CASE 
        WHEN p.id = auth.uid() THEN 'AUTH UID MATCHES'
        ELSE 'AUTH UID MISMATCH'
    END as auth_check
FROM profiles p 
WHERE p.id = 'bea343bd-4ae1-47c4-82e5-8f53361be995';

-- 3. Drop the existing problematic policy
DROP POLICY IF EXISTS "Instructors can create courses" ON courses;

-- 4. Create a new, more explicit policy
CREATE POLICY "Instructors can create courses" ON courses
    FOR INSERT WITH CHECK (
        -- Check that the instructor_id matches the authenticated user
        instructor_id = auth.uid() AND
        -- Check that the user exists in profiles with correct role and approval
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() 
            AND role = 'instructor'
            AND approval_status = 'approved'
            AND is_active = true
        )
    );

-- 5. Alternative: Create a temporary permissive policy for debugging
-- Uncomment this if the above doesn't work
/*
DROP POLICY IF EXISTS "Instructors can create courses" ON courses;

CREATE POLICY "Temporary permissive course creation" ON courses
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = instructor_id 
            AND role = 'instructor'
        )
    );
*/

-- 6. Test the policy by simulating the insert
-- This will show if the policy would pass or fail
SELECT 
    'Policy Test' as test_type,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM profiles
            WHERE id = 'bea343bd-4ae1-47c4-82e5-8f53361be995'
            AND role = 'instructor'
            AND approval_status = 'approved'
            AND is_active = true
        ) THEN 'POLICY SHOULD PASS'
        ELSE 'POLICY WILL FAIL'
    END as policy_result;

-- 7. Check if there are any other policies that might conflict
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
WHERE tablename = 'courses';

-- =====================================================
-- NOTES:
-- =====================================================
-- 1. Run this step by step to identify the exact issue
-- 2. The auth.uid() function should return the current user's ID
-- 3. If auth.uid() is NULL, there's an authentication issue
-- 4. If the profile check fails, there's a data mismatch
-- 5. The temporary permissive policy can be used for testing
-- =====================================================
