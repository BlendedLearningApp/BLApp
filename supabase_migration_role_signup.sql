-- =====================================================
-- BLApp - Role-Based Signup Migration Script
-- =====================================================
-- This script migrates the existing database to support the new role-based
-- signup system with admin approval workflow.
-- 
-- Execute this script in your Supabase SQL editor to update the schema.

-- =====================================================
-- 1. UPDATE PROFILES TABLE
-- =====================================================

-- Add new columns to existing profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS approval_status TEXT NOT NULL DEFAULT 'pending_approval' 
    CHECK (approval_status IN ('pending_approval', 'approved', 'rejected'));

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS phone_number TEXT;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS date_of_birth DATE;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP WITH TIME ZONE;

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS approved_by UUID REFERENCES profiles(id);

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- Update existing users to be approved (for backward compatibility)
UPDATE profiles 
SET approval_status = 'approved', approved_at = NOW() 
WHERE approval_status = 'pending_approval' AND created_at < NOW() - INTERVAL '1 hour';

-- =====================================================
-- 2. CREATE STUDENT PROFILES TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS student_profiles (
    id UUID REFERENCES profiles(id) ON DELETE CASCADE PRIMARY KEY,
    student_id TEXT UNIQUE NOT NULL,
    academic_year TEXT,
    major TEXT,
    gpa DECIMAL(3,2),
    enrollment_date DATE DEFAULT CURRENT_DATE,
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    address TEXT,
    city TEXT,
    country TEXT DEFAULT 'Saudi Arabia',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. CREATE INSTRUCTOR PROFILES TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS instructor_profiles (
    id UUID REFERENCES profiles(id) ON DELETE CASCADE PRIMARY KEY,
    instructor_id TEXT UNIQUE NOT NULL,
    department TEXT NOT NULL,
    qualifications TEXT NOT NULL,
    years_of_experience INTEGER DEFAULT 0,
    specialization TEXT,
    education_level TEXT CHECK (education_level IN ('bachelor', 'master', 'phd', 'other')),
    linkedin_profile TEXT,
    research_interests TEXT,
    office_location TEXT,
    office_hours TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 4. UPDATE PROFILE CREATION TRIGGER
-- =====================================================

-- Drop existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create updated function to handle approval status
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    user_role TEXT;
    approval_status TEXT;
BEGIN
    user_role := COALESCE(NEW.raw_user_meta_data->>'role', 'student');
    
    -- Admin accounts are auto-approved, others need approval
    IF user_role = 'admin' THEN
        approval_status := 'approved';
    ELSE
        approval_status := 'pending_approval';
    END IF;
    
    INSERT INTO public.profiles (
        id, 
        email, 
        name, 
        role, 
        approval_status, 
        phone_number, 
        date_of_birth,
        approved_at
    )
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
        user_role,
        approval_status,
        NEW.raw_user_meta_data->>'phone_number',
        CASE 
            WHEN NEW.raw_user_meta_data->>'date_of_birth' IS NOT NULL 
            THEN (NEW.raw_user_meta_data->>'date_of_birth')::DATE 
            ELSE NULL 
        END,
        CASE 
            WHEN user_role = 'admin' THEN NOW()
            ELSE NULL
        END
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- 5. CREATE APPROVAL WORKFLOW FUNCTIONS
-- =====================================================

-- Function to approve a user
CREATE OR REPLACE FUNCTION public.approve_user(
    user_id UUID,
    admin_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE profiles 
    SET 
        approval_status = 'approved',
        approved_at = NOW(),
        approved_by = admin_id,
        rejection_reason = NULL
    WHERE id = user_id AND approval_status = 'pending_approval';
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to reject a user
CREATE OR REPLACE FUNCTION public.reject_user(
    user_id UUID,
    admin_id UUID,
    reason TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE profiles 
    SET 
        approval_status = 'rejected',
        approved_by = admin_id,
        rejection_reason = reason
    WHERE id = user_id AND approval_status = 'pending_approval';
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to create role-specific profile
CREATE OR REPLACE FUNCTION public.create_role_specific_profile(
    profile_id UUID,
    role_data JSONB
)
RETURNS BOOLEAN AS $$
DECLARE
    user_role TEXT;
BEGIN
    SELECT role INTO user_role FROM profiles WHERE id = profile_id;
    
    IF user_role = 'student' THEN
        INSERT INTO student_profiles (
            id, student_id, academic_year, major, 
            emergency_contact_name, emergency_contact_phone, 
            address, city, country
        ) VALUES (
            profile_id,
            role_data->>'student_id',
            role_data->>'academic_year',
            role_data->>'major',
            role_data->>'emergency_contact_name',
            role_data->>'emergency_contact_phone',
            role_data->>'address',
            role_data->>'city',
            COALESCE(role_data->>'country', 'Saudi Arabia')
        )
        ON CONFLICT (id) DO UPDATE SET
            student_id = EXCLUDED.student_id,
            academic_year = EXCLUDED.academic_year,
            major = EXCLUDED.major,
            emergency_contact_name = EXCLUDED.emergency_contact_name,
            emergency_contact_phone = EXCLUDED.emergency_contact_phone,
            address = EXCLUDED.address,
            city = EXCLUDED.city,
            country = EXCLUDED.country,
            updated_at = NOW();
            
    ELSIF user_role = 'instructor' THEN
        INSERT INTO instructor_profiles (
            id, instructor_id, department, qualifications,
            years_of_experience, specialization, education_level,
            linkedin_profile, research_interests, office_location, office_hours
        ) VALUES (
            profile_id,
            role_data->>'instructor_id',
            role_data->>'department',
            role_data->>'qualifications',
            COALESCE((role_data->>'years_of_experience')::INTEGER, 0),
            role_data->>'specialization',
            role_data->>'education_level',
            role_data->>'linkedin_profile',
            role_data->>'research_interests',
            role_data->>'office_location',
            role_data->>'office_hours'
        )
        ON CONFLICT (id) DO UPDATE SET
            instructor_id = EXCLUDED.instructor_id,
            department = EXCLUDED.department,
            qualifications = EXCLUDED.qualifications,
            years_of_experience = EXCLUDED.years_of_experience,
            specialization = EXCLUDED.specialization,
            education_level = EXCLUDED.education_level,
            linkedin_profile = EXCLUDED.linkedin_profile,
            research_interests = EXCLUDED.research_interests,
            office_location = EXCLUDED.office_location,
            office_hours = EXCLUDED.office_hours,
            updated_at = NOW();
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 6. UPDATE ROW LEVEL SECURITY POLICIES
-- =====================================================

-- Update existing policies to check approval status
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (
        auth.uid() = id AND 
        approval_status IN ('approved', 'pending_approval')
    );

-- Add RLS for student_profiles
ALTER TABLE student_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can manage own profile" ON student_profiles
    FOR ALL USING (id = auth.uid());

CREATE POLICY "Instructors can view student profiles" ON student_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM profiles p
            WHERE p.id = auth.uid() 
            AND p.role = 'instructor' 
            AND p.approval_status = 'approved'
        )
    );

CREATE POLICY "Admins can view all student profiles" ON student_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'admin' AND approval_status = 'approved'
        )
    );

-- Add RLS for instructor_profiles
ALTER TABLE instructor_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Instructors can manage own profile" ON instructor_profiles
    FOR ALL USING (id = auth.uid());

CREATE POLICY "Students can view instructor profiles" ON instructor_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM profiles p
            WHERE p.id = auth.uid() 
            AND p.role = 'student' 
            AND p.approval_status = 'approved'
        )
    );

CREATE POLICY "Admins can view all instructor profiles" ON instructor_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'admin' AND approval_status = 'approved'
        )
    );

-- =====================================================
-- 7. CREATE INDEXES FOR PERFORMANCE
-- =====================================================

-- Indexes for approval status queries
CREATE INDEX IF NOT EXISTS idx_profiles_approval_status ON profiles(approval_status);
CREATE INDEX IF NOT EXISTS idx_profiles_role_approval ON profiles(role, approval_status);
CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON profiles(created_at);

-- Indexes for role-specific tables
CREATE INDEX IF NOT EXISTS idx_student_profiles_student_id ON student_profiles(student_id);
CREATE INDEX IF NOT EXISTS idx_instructor_profiles_instructor_id ON instructor_profiles(instructor_id);
CREATE INDEX IF NOT EXISTS idx_instructor_profiles_department ON instructor_profiles(department);

-- =====================================================
-- 8. VERIFICATION QUERIES
-- =====================================================

-- Verify the migration was successful
DO $$
BEGIN
    -- Check if new columns exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'approval_status') THEN
        RAISE EXCEPTION 'Migration failed: approval_status column not found';
    END IF;
    
    -- Check if new tables exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables 
                   WHERE table_name = 'student_profiles') THEN
        RAISE EXCEPTION 'Migration failed: student_profiles table not found';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables 
                   WHERE table_name = 'instructor_profiles') THEN
        RAISE EXCEPTION 'Migration failed: instructor_profiles table not found';
    END IF;
    
    RAISE NOTICE 'Migration completed successfully!';
END $$;

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================

-- Summary of changes:
-- 1. ✅ Enhanced profiles table with approval workflow fields
-- 2. ✅ Created student_profiles table for student-specific data
-- 3. ✅ Created instructor_profiles table for instructor credentials
-- 4. ✅ Updated user creation trigger for approval status handling
-- 5. ✅ Added approval workflow functions (approve_user, reject_user)
-- 6. ✅ Created role-specific profile creation function
-- 7. ✅ Updated RLS policies for approval status checking
-- 8. ✅ Added performance indexes
-- 9. ✅ Verified migration success

-- Next steps:
-- 1. Create default admin account (see supabase_default_admin.sql)
-- 2. Test the new signup flow
-- 3. Implement admin approval interface
-- 4. Update existing users if needed
