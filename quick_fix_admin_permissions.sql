-- =====================================================
-- QUICK FIX FOR ADMIN APPROVAL PERMISSIONS
-- =====================================================
-- This script fixes the immediate issue with admin approval permissions

-- Step 1: Check current user and admin status
SELECT 
    'Current User Info' as info,
    auth.uid() as current_user_id,
    p.role,
    p.approval_status,
    p.name,
    p.email
FROM profiles p 
WHERE p.id = auth.uid();

-- Step 2: Check existing RLS policies
SELECT policyname, cmd, permissive
FROM pg_policies 
WHERE tablename = 'profiles';

-- Step 3: Add admin update policy (this is the main fix)
CREATE POLICY "admin_can_update_profiles" ON profiles
FOR UPDATE 
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = auth.uid() 
        AND role = 'admin'
    )
);

-- Step 4: Verify the policy was created
SELECT policyname, cmd, permissive
FROM pg_policies 
WHERE tablename = 'profiles' 
AND policyname = 'admin_can_update_profiles';

-- Step 5: Test with a manual update (replace UUID with actual pending user ID)
-- First, find a pending user:
SELECT id, email, name, approval_status 
FROM profiles 
WHERE approval_status = 'pending_approval' 
LIMIT 1;

-- Copy one of the IDs from above and use it in the test below:
-- UPDATE profiles 
-- SET approval_status = 'approved', approved_at = NOW()
-- WHERE id = 'PASTE_USER_ID_HERE';

-- Check if the test update worked:
-- SELECT id, email, name, approval_status, approved_at 
-- FROM profiles 
-- WHERE id = 'PASTE_USER_ID_HERE';

-- =====================================================
-- ALTERNATIVE: TEMPORARY DISABLE RLS (FOR TESTING ONLY)
-- =====================================================
-- If the above policy doesn't work, temporarily disable RLS:

-- ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Test your app now, then re-enable RLS:
-- ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- VERIFICATION
-- =====================================================

-- Check how many profiles the current user can see
SELECT COUNT(*) as visible_profiles FROM profiles;

-- Check if current user can update profiles
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() 
            AND role = 'admin'
        ) THEN 'Admin user - should be able to update'
        ELSE 'Not admin - cannot update'
    END as update_permission;
