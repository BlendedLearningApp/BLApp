-- =====================================================
-- TEST APPROVE/REJECT FUNCTIONALITY
-- =====================================================
-- This script helps test the approve/reject functionality manually

-- 1. First, let's see all test users and their current status
SELECT 
    id,
    email, 
    name, 
    role, 
    approval_status, 
    approved_at,
    created_at 
FROM profiles 
WHERE email LIKE 'test.%@example.com'
ORDER BY created_at DESC;

-- 2. Get a specific user ID for testing (copy one of the IDs from above)
-- Replace 'USER_ID_HERE' with an actual UUID from the query above

-- Example: Test approving a user
-- UPDATE profiles 
-- SET 
--     approval_status = 'approved',
--     approved_at = NOW()
-- WHERE id = 'USER_ID_HERE' AND approval_status = 'pending_approval';

-- Example: Test rejecting a user  
-- UPDATE profiles 
-- SET 
--     approval_status = 'rejected',
--     approved_at = NULL
-- WHERE id = 'USER_ID_HERE' AND approval_status = 'pending_approval';

-- 3. Verify the update worked
-- SELECT 
--     id,
--     email, 
--     name, 
--     approval_status, 
--     approved_at 
-- FROM profiles 
-- WHERE id = 'USER_ID_HERE';

-- =====================================================
-- AUTOMATED TEST SCRIPT
-- =====================================================
-- This will automatically test approve/reject on the first pending user

DO $$
DECLARE
    test_user_id UUID;
    test_user_email TEXT;
    test_user_name TEXT;
BEGIN
    -- Get the first pending test user
    SELECT id, email, name INTO test_user_id, test_user_email, test_user_name
    FROM profiles 
    WHERE email LIKE 'test.%@example.com' 
    AND approval_status = 'pending_approval'
    LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        RAISE NOTICE 'Testing with user: % (%) - ID: %', test_user_name, test_user_email, test_user_id;
        
        -- Test approval
        RAISE NOTICE 'Testing APPROVAL...';
        UPDATE profiles 
        SET 
            approval_status = 'approved',
            approved_at = NOW()
        WHERE id = test_user_id;
        
        RAISE NOTICE 'User approved. Checking status...';
        
        -- Verify approval
        IF EXISTS (SELECT 1 FROM profiles WHERE id = test_user_id AND approval_status = 'approved') THEN
            RAISE NOTICE '✅ APPROVAL TEST PASSED';
        ELSE
            RAISE NOTICE '❌ APPROVAL TEST FAILED';
        END IF;
        
        -- Reset to pending for rejection test
        UPDATE profiles 
        SET 
            approval_status = 'pending_approval',
            approved_at = NULL
        WHERE id = test_user_id;
        
        -- Test rejection
        RAISE NOTICE 'Testing REJECTION...';
        UPDATE profiles 
        SET 
            approval_status = 'rejected',
            approved_at = NULL
        WHERE id = test_user_id;
        
        -- Verify rejection
        IF EXISTS (SELECT 1 FROM profiles WHERE id = test_user_id AND approval_status = 'rejected') THEN
            RAISE NOTICE '✅ REJECTION TEST PASSED';
        ELSE
            RAISE NOTICE '❌ REJECTION TEST FAILED';
        END IF;
        
        -- Reset back to pending for app testing
        UPDATE profiles 
        SET 
            approval_status = 'pending_approval',
            approved_at = NULL
        WHERE id = test_user_id;
        
        RAISE NOTICE '🔄 User reset to pending_approval for app testing';
        
    ELSE
        RAISE NOTICE '❌ No pending test users found. Run create_test_pending_users.sql first.';
    END IF;
END $$;

-- =====================================================
-- FINAL VERIFICATION
-- =====================================================

-- Check all test users status
SELECT 
    'Test Users Status' as info,
    approval_status,
    COUNT(*) as count
FROM profiles 
WHERE email LIKE 'test.%@example.com'
GROUP BY approval_status;

-- Show all test users with details
SELECT 
    email,
    name,
    role,
    approval_status,
    approved_at,
    created_at
FROM profiles 
WHERE email LIKE 'test.%@example.com'
ORDER BY created_at DESC;

-- =====================================================
-- TROUBLESHOOTING QUERIES
-- =====================================================

-- Check if profiles table exists and has correct columns
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND column_name IN ('id', 'approval_status', 'approved_at')
ORDER BY column_name;

-- Check table permissions
SELECT grantee, privilege_type 
FROM information_schema.table_privileges 
WHERE table_name = 'profiles';
