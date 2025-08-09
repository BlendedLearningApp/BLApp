-- =====================================================
-- FIX RLS POLICIES FOR ADMIN USER MANAGEMENT
-- =====================================================
-- This script fixes the Row Level Security policies that are blocking
-- admin users from updating approval statuses

-- First, let's check current RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'profiles';

-- Check if RLS is enabled on profiles table
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE tablename = 'profiles';

-- =====================================================
-- SOLUTION 1: Add Admin Update Policy
-- =====================================================

-- Create a policy that allows admins to update any profile
CREATE POLICY "Admins can update any profile" ON profiles
FOR UPDATE 
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM profiles admin_profile 
        WHERE admin_profile.id = auth.uid() 
        AND admin_profile.role = 'admin'
        AND admin_profile.approval_status = 'approved'
    )
);

-- =====================================================
-- SOLUTION 2: Alternative - Allow admins to update approval status
-- =====================================================

-- If the above doesn't work, try this more specific policy
CREATE POLICY "Admins can update approval status" ON profiles
FOR UPDATE 
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM profiles admin_profile 
        WHERE admin_profile.id = auth.uid() 
        AND admin_profile.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM profiles admin_profile 
        WHERE admin_profile.id = auth.uid() 
        AND admin_profile.role = 'admin'
    )
);

-- =====================================================
-- SOLUTION 3: Temporary - Disable RLS for testing
-- =====================================================
-- WARNING: Only use this for testing, not in production!

-- Temporarily disable RLS on profiles table
-- ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- To re-enable later:
-- ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check if policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies 
WHERE tablename = 'profiles' 
AND policyname LIKE '%Admin%';

-- Test the current user's admin status
SELECT 
    auth.uid() as current_user_id,
    p.role,
    p.approval_status,
    p.name,
    p.email
FROM profiles p 
WHERE p.id = auth.uid();

-- Test if admin can see all profiles
SELECT COUNT(*) as total_profiles_visible
FROM profiles;

-- =====================================================
-- MANUAL TEST UPDATE
-- =====================================================
-- Test updating a specific user (replace with actual UUID)

-- First, find a pending user
SELECT id, email, name, approval_status 
FROM profiles 
WHERE approval_status = 'pending_approval' 
LIMIT 1;

-- Try to update (replace UUID with actual ID from above)
-- UPDATE profiles 
-- SET approval_status = 'approved', approved_at = NOW()
-- WHERE id = 'REPLACE_WITH_ACTUAL_UUID';

-- Check if it worked
-- SELECT id, email, name, approval_status, approved_at 
-- FROM profiles 
-- WHERE id = 'REPLACE_WITH_ACTUAL_UUID';

-- =====================================================
-- DEBUGGING QUERIES
-- =====================================================

-- Check current user permissions
SELECT 
    'Current User Info' as info,
    auth.uid() as user_id,
    auth.role() as auth_role;

-- Check if current user is admin
SELECT 
    'Admin Check' as info,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() 
            AND role = 'admin' 
            AND approval_status = 'approved'
        ) THEN 'YES - User is approved admin'
        WHEN EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() 
            AND role = 'admin'
        ) THEN 'PARTIAL - User is admin but not approved'
        ELSE 'NO - User is not admin'
    END as is_admin;

-- Show all RLS policies for profiles table
SELECT 
    policyname,
    cmd,
    permissive,
    roles,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'profiles'
ORDER BY policyname;
