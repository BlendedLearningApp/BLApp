-- =====================================================
-- BLApp - Create Default Admin Account (SIMPLIFIED)
-- =====================================================
-- This script creates the default admin account for the BLApp system
-- Execute this AFTER running the main migration script

-- =====================================================
-- STEP 1: CHECK CURRENT STATUS
-- =====================================================

-- Simple status check without complex functions
SELECT
    'Current Status Check' as info,
    COUNT(*) as auth_users_count
FROM auth.users
WHERE email = 'admin@blapp.com';

SELECT
    'Profile Status Check' as info,
    COUNT(*) as profiles_count
FROM profiles
WHERE email = 'admin@blapp.com';

-- =====================================================
-- STEP 2: CREATE/UPDATE ADMIN PROFILE (if auth user exists)
-- =====================================================

-- This will create or update the admin profile if the auth user exists
DO $$
DECLARE
    admin_user_id UUID;
    admin_exists BOOLEAN := FALSE;
    profile_exists BOOLEAN := FALSE;
BEGIN
    -- Check if admin user exists in auth.users
    SELECT id INTO admin_user_id
    FROM auth.users
    WHERE email = 'admin@blapp.com';

    IF admin_user_id IS NOT NULL THEN
        admin_exists := TRUE;
        RAISE NOTICE '✅ Admin user found in auth.users with ID: %', admin_user_id;

        -- Check if profile already exists
        SELECT EXISTS(SELECT 1 FROM profiles WHERE id = admin_user_id) INTO profile_exists;

        -- Create or update the profile
        INSERT INTO profiles (
            id,
            email,
            name,
            role,
            approval_status,
            is_active,
            created_at,
            approved_at
        ) VALUES (
            admin_user_id,
            'admin@blapp.com',
            'System Administrator',
            'admin',
            'approved',
            true,
            NOW(),
            NOW()
        )
        ON CONFLICT (id) DO UPDATE SET
            approval_status = 'approved',
            approved_at = NOW(),
            role = 'admin',
            name = 'System Administrator',
            email = 'admin@blapp.com';

        IF profile_exists THEN
            RAISE NOTICE '✅ Admin profile updated successfully';
        ELSE
            RAISE NOTICE '✅ Admin profile created successfully';
        END IF;

    ELSE
        RAISE NOTICE '❌ Admin user not found in auth.users';
        RAISE NOTICE '📋 Please create the auth user first using Supabase Dashboard:';
        RAISE NOTICE '   1. Go to Authentication > Users';
        RAISE NOTICE '   2. Click "Add user"';
        RAISE NOTICE '   3. Email: admin@blapp.com';
        RAISE NOTICE '   4. Password: admin123';
        RAISE NOTICE '   5. Check "Email Confirm"';
        RAISE NOTICE '   6. User Metadata: {"name": "System Administrator", "role": "admin"}';
        RAISE NOTICE '   7. Then run this script again';
    END IF;
END $$;

-- =====================================================
-- STEP 3: FINAL VERIFICATION
-- =====================================================

-- Simple verification queries without complex functions
SELECT
    'Auth User Check' as check_type,
    CASE
        WHEN COUNT(*) > 0 THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status,
    COUNT(*) as count
FROM auth.users
WHERE email = 'admin@blapp.com'

UNION ALL

SELECT
    'Profile Check' as check_type,
    CASE
        WHEN COUNT(*) > 0 THEN '✅ EXISTS'
        ELSE '❌ MISSING'
    END as status,
    COUNT(*) as count
FROM profiles
WHERE email = 'admin@blapp.com'

UNION ALL

SELECT
    'Approval Status' as check_type,
    CASE
        WHEN approval_status = 'approved' THEN '✅ APPROVED'
        WHEN approval_status = 'pending' THEN '⏳ PENDING'
        WHEN approval_status = 'rejected' THEN '❌ REJECTED'
        ELSE '❓ UNKNOWN'
    END as status,
    1 as count
FROM profiles
WHERE email = 'admin@blapp.com'

UNION ALL

SELECT
    'Overall Status' as check_type,
    CASE
        WHEN (
            SELECT COUNT(*) FROM auth.users WHERE email = 'admin@blapp.com'
        ) > 0 AND (
            SELECT COUNT(*) FROM profiles WHERE email = 'admin@blapp.com' AND approval_status = 'approved'
        ) > 0
        THEN '🎉 READY - Admin can login'
        ELSE '⚠️ INCOMPLETE - Follow instructions above'
    END as status,
    0 as count;

-- =====================================================
-- STEP 4: INSTRUCTIONS FOR MANUAL ADMIN CREATION
-- =====================================================

/*
🔧 HOW TO CREATE ADMIN USER IN SUPABASE:

If the verification above shows "❌ MISSING" for Auth User, follow these steps:

OPTION A: Using Supabase Dashboard (RECOMMENDED)
1. Go to your Supabase project dashboard
2. Navigate to Authentication > Users
3. Click "Add user" button
4. Fill in the form:
   - Email: admin@blapp.com
   - Password: admin123
   - Email Confirm: ✅ (check this box)
   - User Metadata: {"name": "System Administrator", "role": "admin"}
5. Click "Add user"
6. Run this script again to create the profile

OPTION B: Using Supabase CLI
supabase auth users create admin@blapp.com --password admin123 --user-metadata '{"name": "System Administrator", "role": "admin"}'

OPTION C: Using Auth API
POST https://your-project-ref.supabase.co/auth/v1/admin/users
Headers:
  Authorization: Bearer YOUR_SERVICE_ROLE_KEY
  Content-Type: application/json
Body:
{
  "email": "admin@blapp.com",
  "password": "admin123",
  "email_confirm": true,
  "user_metadata": {
    "name": "System Administrator",
    "role": "admin"
  }
}

After creating the auth user, run this script again!
*/

-- =====================================================
-- STEP 5: HELPER FUNCTIONS
-- =====================================================

-- Function to manually create admin profile with specific UUID (if needed)
CREATE OR REPLACE FUNCTION create_admin_profile_manual(admin_uuid UUID)
RETURNS TEXT AS $$
BEGIN
    INSERT INTO profiles (
        id, email, name, role, approval_status, is_active, created_at, approved_at
    ) VALUES (
        admin_uuid, 'admin@blapp.com', 'System Administrator', 'admin', 'approved', true, NOW(), NOW()
    ) ON CONFLICT (id) DO UPDATE SET
        approval_status = 'approved', approved_at = NOW(), role = 'admin';

    RETURN '✅ Admin profile created/updated for UUID: ' || admin_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to clean up admin account (for testing)
CREATE OR REPLACE FUNCTION remove_admin_profile()
RETURNS TEXT AS $$
BEGIN
    DELETE FROM profiles WHERE email = 'admin@blapp.com';
    RETURN '🗑️ Admin profile removed (auth user must be removed manually from Supabase Dashboard)';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- STEP 6: FINAL MESSAGE
-- =====================================================

SELECT '🎯 NEXT STEPS:' as message
UNION ALL
SELECT '1. Check the verification results above' as message
UNION ALL
SELECT '2. If auth user is missing, create it via Supabase Dashboard' as message
UNION ALL
SELECT '3. Run this script again after creating the auth user' as message
UNION ALL
SELECT '4. When complete, login with admin@blapp.com / admin123' as message;
