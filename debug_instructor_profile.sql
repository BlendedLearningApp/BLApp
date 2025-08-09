-- =====================================================
-- DEBUG INSTRUCTOR PROFILE ISSUE
-- =====================================================
-- Run this in Supabase SQL Editor to debug the RLS issue

-- 1. Check the instructor's profile data
SELECT 
    id,
    name,
    email,
    role,
    approval_status,
    created_at
FROM profiles 
WHERE id = 'bea343bd-4ae1-47c4-82e5-8f53361be995';

-- 2. Check what roles exist in the database
SELECT DISTINCT role FROM profiles;

-- 3. Check what approval statuses exist
SELECT DISTINCT approval_status FROM profiles;

-- 4. Test the RLS policy condition manually
SELECT 
    id,
    name,
    role,
    approval_status,
    CASE 
        WHEN role = 'instructor' AND approval_status = 'approved' THEN 'POLICY SHOULD PASS'
        ELSE 'POLICY WILL FAIL'
    END as policy_check
FROM profiles 
WHERE id = 'bea343bd-4ae1-47c4-82e5-8f53361be995';

-- 5. Check if there are any existing courses for this instructor
SELECT 
    id,
    title,
    instructor_id,
    is_approved,
    created_at
FROM courses 
WHERE instructor_id = 'bea343bd-4ae1-47c4-82e5-8f53361be995';

-- =====================================================
-- POTENTIAL FIXES TO TRY:
-- =====================================================

-- Option 1: Drop and recreate the problematic policy
DROP POLICY IF EXISTS "Instructors can create courses" ON courses;

CREATE POLICY "Instructors can create courses" ON courses
    FOR INSERT WITH CHECK (
        instructor_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() 
            AND role IN ('instructor', 'UserRole.instructor')  -- Handle both formats
            AND approval_status IN ('approved', 'UserApprovalStatus.approved')  -- Handle both formats
        )
    );

-- Option 2: Temporarily disable RLS to test (ONLY FOR DEBUGGING)
-- ALTER TABLE courses DISABLE ROW LEVEL SECURITY;

-- Option 3: Create a more permissive policy for testing
-- CREATE POLICY "Temporary instructor course creation" ON courses
--     FOR INSERT WITH CHECK (
--         instructor_id = auth.uid()
--     );

-- =====================================================
-- NOTES:
-- =====================================================
-- 1. Run the SELECT queries first to see the actual data
-- 2. If the role/approval_status values are different than expected,
--    we'll need to update the RLS policy accordingly
-- 3. The issue might be enum vs string storage format
-- =====================================================
