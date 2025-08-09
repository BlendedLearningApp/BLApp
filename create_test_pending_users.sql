-- =====================================================
-- CREATE TEST PENDING USERS FOR ADMIN DASHBOARD TESTING
-- =====================================================
-- This script creates test users with pending_approval status
-- Run this in your Supabase SQL editor to test the admin dashboard

-- First, let's check current users and their approval status
SELECT id, email, name, role, approval_status, created_at 
FROM profiles 
ORDER BY created_at DESC;

-- Create test pending users (if they don't exist)
-- Note: These are profile-only entries for testing purposes

-- First, let's clean up any existing test users
DELETE FROM profiles WHERE email LIKE 'test.%@example.com';

-- Test Student 1
INSERT INTO profiles (
    id,
    email,
    name,
    role,
    approval_status,
    phone_number,
    is_active,
    created_at
) VALUES (
    gen_random_uuid(),
    'test.student1@example.com',
    'Ahmed Al-Rashid',
    'student',
    'pending_approval',
    '+966501234567',
    true,
    NOW() - INTERVAL '2 hours'
);

-- Test Student 2
INSERT INTO profiles (
    id,
    email,
    name,
    role,
    approval_status,
    phone_number,
    is_active,
    created_at
) VALUES (
    gen_random_uuid(),
    'test.student2@example.com',
    'Fatima Al-Zahra',
    'student',
    'pending_approval',
    '+966501234568',
    true,
    NOW() - INTERVAL '1 hour'
);

-- Test Instructor 1
INSERT INTO profiles (
    id,
    email,
    name,
    role,
    approval_status,
    phone_number,
    is_active,
    created_at
) VALUES (
    gen_random_uuid(),
    'test.instructor1@example.com',
    'Dr. Mohammed Hassan',
    'instructor',
    'pending_approval',
    '+966501234569',
    true,
    NOW() - INTERVAL '30 minutes'
);

-- Test Instructor 2
INSERT INTO profiles (
    id,
    email,
    name,
    role,
    approval_status,
    phone_number,
    is_active,
    created_at
) VALUES (
    gen_random_uuid(),
    'test.instructor2@example.com',
    'Prof. Sarah Abdullah',
    'instructor',
    'pending_approval',
    '+966501234570',
    true,
    NOW() - INTERVAL '15 minutes'
);

-- Verify the test users were created
SELECT 
    id, 
    email, 
    name, 
    role, 
    approval_status, 
    phone_number,
    created_at 
FROM profiles 
WHERE email LIKE 'test.%@example.com'
ORDER BY created_at DESC;

-- Count pending users
SELECT 
    role,
    COUNT(*) as pending_count
FROM profiles 
WHERE approval_status = 'pending_approval'
GROUP BY role;

-- =====================================================
-- CLEANUP SCRIPT (Run this to remove test users)
-- =====================================================
-- Uncomment and run these lines to clean up test data:

-- DELETE FROM profiles WHERE email LIKE 'test.%@example.com';
-- SELECT 'Test users cleaned up' as message;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check all approval statuses
SELECT 
    approval_status,
    COUNT(*) as count
FROM profiles 
GROUP BY approval_status;

-- Check recent users
SELECT 
    email,
    name,
    role,
    approval_status,
    created_at
FROM profiles 
ORDER BY created_at DESC 
LIMIT 10;
