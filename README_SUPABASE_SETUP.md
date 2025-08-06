# BLApp Supabase Backend Setup Guide

This guide provides complete instructions for setting up the Supabase backend for the BLApp (Blended Learning App) project.

## 📋 Prerequisites

- Supabase account and project created
- Project URL: `https://dzjidtzkxhurnuhvobel.supabase.co`
- Anon API Key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6amlkdHpreGh1cm51aHZvYmVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0NDAwMDAsImV4cCI6MjA3MDAxNjAwMH0.PX0Zou3YKz7FYwvofO1rlpLxSTY_CB7NP6aeT4QX4Ew`
- Storage bucket named `storage-bucket` created

## 🚀 Setup Instructions

### Step 1: Database Schema Setup

Execute the SQL files in the following order in your Supabase SQL Editor:

1. **Create Tables and Basic Structure**
   ```sql
   -- Execute: supabase_schema.sql
   ```
   This creates all tables, relationships, constraints, and basic triggers.

2. **Apply Row Level Security Policies**
   ```sql
   -- Execute: supabase_rls_policies.sql
   ```
   This sets up comprehensive RLS policies for all tables based on user roles.

3. **Create Performance Indexes**
   ```sql
   -- Execute: supabase_indexes.sql
   ```
   This adds performance indexes for frequently queried fields.

4. **Setup Storage Configuration**
   ```sql
   -- Execute: supabase_storage_config.sql
   ```
   This configures storage bucket policies and folder structure.

5. **Add Advanced Functions**
   ```sql
   -- Execute: supabase_functions.sql
   ```
   This adds analytics functions, enrollment management, and business logic.

6. **Insert Test Data**
   ```sql
   -- Execute: supabase_dummy_data.sql
   ```
   This populates the database with comprehensive test data.

### Step 2: Storage Bucket Setup

1. **Create Storage Bucket** (if not already created)
   - Go to Storage in Supabase Dashboard
   - Create bucket named `storage-bucket`
   - Set as public bucket

2. **Folder Structure**
   The storage bucket should follow this structure:
   ```
   storage-bucket/
   ├── profiles/{user_id}/
   │   └── profile_image.jpg
   ├── courses/{course_id}/
   │   └── thumbnail.jpg
   ├── worksheets/{course_id}/
   │   └── {worksheet_id}.pdf
   └── forum/{course_id}/
       └── {post_id}_{attachment}.jpg
   ```

### Step 3: Authentication Setup

1. **Enable Email/Password Authentication**
   - Go to Authentication > Settings
   - Enable Email provider
   - Disable other providers (as per requirements)

2. **Configure Email Templates** (Optional)
   - Customize signup confirmation email
   - Customize password reset email

### Step 4: Environment Variables

Add these environment variables to your Flutter project:

```dart
// In your main.dart or environment config
const supabaseUrl = 'https://dzjidtzkxhurnuhvobel.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6amlkdHpreGh1cm51aHZvYmVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0NDAwMDAsImV4cCI6MjA3MDAxNjAwMH0.PX0Zou3YKz7FYwvofO1rlpLxSTY_CB7NP6aeT4QX4Ew';
```

## 📊 Database Schema Overview

### Core Tables

1. **profiles** - User profiles extending auth.users
2. **courses** - Course information and metadata
3. **videos** - Video lessons with YouTube integration
4. **quizzes** - Quiz definitions and settings
5. **questions** - Quiz questions with multiple choice options
6. **worksheets** - PDF/document attachments
7. **enrollments** - Student course enrollments
8. **video_progress** - Student video watching progress
9. **quiz_submissions** - Quiz attempt results
10. **forum_posts** - Course discussion posts
11. **forum_replies** - Replies to forum posts
12. **forum_likes** - Like system for posts/replies
13. **analytics_events** - User activity tracking

### Key Features

- **Automatic Profile Creation**: Profiles are created automatically when users sign up
- **Role-Based Access Control**: Student, Instructor, Admin roles with appropriate permissions
- **Progress Tracking**: Automatic course progress calculation based on video completion
- **Analytics**: Comprehensive analytics for courses, students, and instructors
- **Forum System**: Course-specific discussion forums with likes
- **File Storage**: Secure file upload/download with proper permissions

## 🔐 Security Features

### Row Level Security (RLS)
- All tables have RLS enabled
- Policies based on user roles and data ownership
- Students can only access enrolled courses
- Instructors can manage their own courses
- Admins have full access

### Storage Security
- File access based on course enrollment
- Instructors can upload course materials
- Students can upload profile images
- Folder-based permission structure

## 📈 Analytics Functions

The backend includes several analytics functions:

```sql
-- Get course analytics
SELECT public.get_course_analytics('course-uuid');

-- Get student analytics  
SELECT public.get_student_analytics('student-uuid');

-- Get instructor analytics
SELECT public.get_instructor_analytics('instructor-uuid');

-- Get system-wide analytics
SELECT public.get_system_analytics();
```

## 🔧 Utility Functions

### Enrollment Management
```sql
-- Enroll student in course
SELECT public.enroll_student('student-uuid', 'course-uuid');

-- Update course progress
SELECT public.update_course_progress('student-uuid', 'course-uuid');
```

### Quiz Management
```sql
-- Submit quiz
SELECT public.submit_quiz(
    'quiz-uuid', 
    'student-uuid', 
    '{"question-id": 0}'::jsonb,
    15
);
```

### Video Progress
```sql
-- Mark video as watched
SELECT public.mark_video_watched('video-uuid', 'student-uuid', 1200);
```

## 🧪 Test Data

The dummy data includes:
- 3 Students, 3 Instructors, 1 Admin
- 4 Courses (3 approved, 1 pending)
- 7 Videos across courses
- 3 Quizzes with questions
- 3 Worksheets
- 5 Enrollments with progress
- Video progress tracking
- Quiz submissions
- Forum posts and replies
- Analytics events

## 🔄 Flutter Integration

### Initialize Supabase
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://dzjidtzkxhurnuhvobel.supabase.co',
    anonKey: 'your-anon-key-here',
  );
  
  runApp(MyApp());
}
```

### Basic Usage Examples
```dart
// Get Supabase client
final supabase = Supabase.instance.client;

// Sign up user
final response = await supabase.auth.signUp(
  email: 'user@example.com',
  password: 'password',
  data: {'name': 'User Name', 'role': 'student'}
);

// Get courses
final courses = await supabase
    .from('courses')
    .select('*, profiles!instructor_id(name)')
    .eq('is_approved', true);

// Enroll in course
final enrollment = await supabase.rpc('enroll_student', params: {
  'student_uuid': userId,
  'course_uuid': courseId,
});
```

## 🚨 Important Notes

1. **Profile Creation**: Profiles are automatically created via trigger when users sign up through Supabase Auth
2. **File Uploads**: Use the storage bucket with proper folder structure
3. **RLS Policies**: All data access is controlled by RLS policies
4. **Analytics**: Events are automatically logged for user actions
5. **Course Approval**: Courses must be approved by admins before students can enroll

## 📞 Support

For issues or questions about the backend setup, refer to:
- Supabase Documentation: https://supabase.com/docs
- This setup guide and SQL files
- The Flutter model files for data structure reference
