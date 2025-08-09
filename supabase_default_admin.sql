-- =====================================================
-- BLApp - Default Admin Account Setup
-- =====================================================
-- This script creates the default admin account for the BLApp system
-- Execute this after running the main schema setup

-- =====================================================
-- CREATE DEFAULT ADMIN ACCOUNT
-- =====================================================

-- Note: In a real production environment, you would create this through the Supabase Auth UI
-- or use the Supabase CLI. This is for development/testing purposes.

-- The admin account will be created with:
-- Email: admin@blapp.com
-- Password: admin123
-- Role: admin
-- Status: approved

-- Since we cannot directly insert into auth.users table via SQL,
-- you need to create this account through one of these methods:

-- METHOD 1: Using Supabase Dashboard
-- 1. Go to Authentication > Users in your Supabase dashboard
-- 2. Click "Add user"
-- 3. Enter:
--    - Email: admin@blapp.com
--    - Password: admin123
--    - User Metadata: {"name": "System Administrator", "role": "admin"}
-- 4. Click "Add user"

-- METHOD 2: Using Supabase CLI
-- supabase auth users create admin@blapp.com --password admin123 --user-metadata '{"name": "System Administrator", "role": "admin"}'

-- METHOD 3: Using the signup API endpoint (recommended for automation)
-- POST to your Supabase project's auth endpoint:
-- {
--   "email": "admin@blapp.com",
--   "password": "admin123",
--   "data": {
--     "name": "System Administrator",
--     "role": "admin"
--   }
-- }

-- =====================================================
-- MANUAL PROFILE CREATION (if needed)
-- =====================================================

-- If for some reason the trigger doesn't create the profile automatically,
-- you can manually create it using this function:

CREATE OR REPLACE FUNCTION public.create_default_admin()
RETURNS VOID AS $$
DECLARE
    admin_user_id UUID;
BEGIN
    -- Try to find existing admin user by email
    SELECT id INTO admin_user_id 
    FROM auth.users 
    WHERE email = 'admin@blapp.com';
    
    -- If admin user exists but no profile, create the profile
    IF admin_user_id IS NOT NULL THEN
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
            approved_at = NOW();
            
        RAISE NOTICE 'Default admin profile created/updated successfully';
    ELSE
        RAISE NOTICE 'Admin user not found. Please create the user first through Supabase Auth.';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- EXECUTE DEFAULT ADMIN CREATION
-- =====================================================

-- Uncomment the line below to create the default admin profile
-- (only works if the auth user already exists)
-- SELECT public.create_default_admin();

-- =====================================================
-- VERIFICATION QUERY
-- =====================================================

-- Use this query to verify the admin account was created successfully:
-- SELECT 
--     p.id,
--     p.email,
--     p.name,
--     p.role,
--     p.approval_status,
--     p.created_at,
--     p.approved_at
-- FROM profiles p
-- WHERE p.email = 'admin@blapp.com';

-- =====================================================
-- ADDITIONAL ADMIN ACCOUNTS (Optional)
-- =====================================================

-- You can create additional admin accounts by following the same process
-- with different email addresses. For example:

-- Email: admin2@blapp.com
-- Password: admin123
-- Role: admin

-- Remember to update the default passwords in production!

-- =====================================================
-- SECURITY NOTES
-- =====================================================

-- 1. Change the default password immediately in production
-- 2. Enable 2FA for admin accounts
-- 3. Use strong, unique passwords
-- 4. Regularly audit admin account access
-- 5. Consider using email domains restrictions for admin accounts
-- 6. Monitor admin account activities through Supabase logs
