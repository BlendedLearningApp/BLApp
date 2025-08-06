-- =====================================================
-- BLApp - Storage Bucket Configuration
-- =====================================================
-- This file configures storage buckets and policies for file uploads

-- =====================================================
-- CREATE STORAGE BUCKETS
-- =====================================================

-- Main storage bucket (should already exist based on your config)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('storage-bucket', 'storage-bucket', true);

-- =====================================================
-- STORAGE POLICIES FOR 'storage-bucket'
-- =====================================================

-- Enable RLS on storage objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- PROFILE IMAGES POLICIES
-- =====================================================

-- Allow users to view all profile images (public read)
CREATE POLICY "Public profile images are viewable by everyone" ON storage.objects
    FOR SELECT USING (bucket_id = 'storage-bucket' AND (storage.foldername(name))[1] = 'profiles');

-- Allow users to upload their own profile images
CREATE POLICY "Users can upload their own profile images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'storage-bucket' 
        AND (storage.foldername(name))[1] = 'profiles'
        AND auth.uid()::text = (storage.foldername(name))[2]
    );

-- Allow users to update their own profile images
CREATE POLICY "Users can update their own profile images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'storage-bucket' 
        AND (storage.foldername(name))[1] = 'profiles'
        AND auth.uid()::text = (storage.foldername(name))[2]
    );

-- Allow users to delete their own profile images
CREATE POLICY "Users can delete their own profile images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'storage-bucket' 
        AND (storage.foldername(name))[1] = 'profiles'
        AND auth.uid()::text = (storage.foldername(name))[2]
    );

-- =====================================================
-- COURSE THUMBNAILS POLICIES
-- =====================================================

-- Allow everyone to view course thumbnails (public read)
CREATE POLICY "Course thumbnails are viewable by everyone" ON storage.objects
    FOR SELECT USING (bucket_id = 'storage-bucket' AND (storage.foldername(name))[1] = 'courses');

-- Allow instructors to upload course thumbnails
CREATE POLICY "Instructors can upload course thumbnails" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'storage-bucket' 
        AND (storage.foldername(name))[1] = 'courses'
        AND EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'instructor'
        )
    );

-- Allow instructors to update course thumbnails for their courses
CREATE POLICY "Instructors can update their course thumbnails" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'storage-bucket' 
        AND (storage.foldername(name))[1] = 'courses'
        AND EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'instructor'
        )
    );

-- Allow instructors to delete their course thumbnails
CREATE POLICY "Instructors can delete their course thumbnails" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'storage-bucket' 
        AND (storage.foldername(name))[1] = 'courses'
        AND EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'instructor'
        )
    );

-- =====================================================
-- WORKSHEETS/DOCUMENTS POLICIES
-- =====================================================

-- Allow enrolled students and course instructors to view worksheets
CREATE POLICY "Enrolled users can view worksheets" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'storage-bucket' 
        AND (storage.foldername(name))[1] = 'worksheets'
        AND (
            -- Course instructor can view
            EXISTS (
                SELECT 1 FROM courses c
                WHERE c.id::text = (storage.foldername(name))[2]
                AND c.instructor_id = auth.uid()
            )
            OR
            -- Enrolled students can view
            EXISTS (
                SELECT 1 FROM enrollments e
                JOIN courses c ON c.id = e.course_id
                WHERE c.id::text = (storage.foldername(name))[2]
                AND e.student_id = auth.uid()
            )
            OR
            -- Admins can view all
            EXISTS (
                SELECT 1 FROM profiles 
                WHERE id = auth.uid() AND role = 'admin'
            )
        )
    );

-- Allow instructors to upload worksheets for their courses
CREATE POLICY "Instructors can upload worksheets for their courses" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'storage-bucket' 
        AND (storage.foldername(name))[1] = 'worksheets'
        AND EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id::text = (storage.foldername(name))[2]
            AND c.instructor_id = auth.uid()
        )
    );

-- Allow instructors to update worksheets for their courses
CREATE POLICY "Instructors can update their course worksheets" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'storage-bucket' 
        AND (storage.foldername(name))[1] = 'worksheets'
        AND EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id::text = (storage.foldername(name))[2]
            AND c.instructor_id = auth.uid()
        )
    );

-- Allow instructors to delete worksheets for their courses
CREATE POLICY "Instructors can delete their course worksheets" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'storage-bucket' 
        AND (storage.foldername(name))[1] = 'worksheets'
        AND EXISTS (
            SELECT 1 FROM courses c
            WHERE c.id::text = (storage.foldername(name))[2]
            AND c.instructor_id = auth.uid()
        )
    );

-- =====================================================
-- FORUM ATTACHMENTS POLICIES (Optional)
-- =====================================================

-- Allow users to view forum attachments for courses they have access to
CREATE POLICY "Users can view accessible forum attachments" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'storage-bucket' 
        AND (storage.foldername(name))[1] = 'forum'
        AND (
            -- Course instructor can view
            EXISTS (
                SELECT 1 FROM courses c
                WHERE c.id::text = (storage.foldername(name))[2]
                AND c.instructor_id = auth.uid()
            )
            OR
            -- Enrolled students can view
            EXISTS (
                SELECT 1 FROM enrollments e
                JOIN courses c ON c.id = e.course_id
                WHERE c.id::text = (storage.foldername(name))[2]
                AND e.student_id = auth.uid()
            )
            OR
            -- Admins can view all
            EXISTS (
                SELECT 1 FROM profiles 
                WHERE id = auth.uid() AND role = 'admin'
            )
        )
    );

-- Allow enrolled users to upload forum attachments
CREATE POLICY "Enrolled users can upload forum attachments" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'storage-bucket' 
        AND (storage.foldername(name))[1] = 'forum'
        AND (
            -- Course instructor can upload
            EXISTS (
                SELECT 1 FROM courses c
                WHERE c.id::text = (storage.foldername(name))[2]
                AND c.instructor_id = auth.uid()
            )
            OR
            -- Enrolled students can upload
            EXISTS (
                SELECT 1 FROM enrollments e
                JOIN courses c ON c.id = e.course_id
                WHERE c.id::text = (storage.foldername(name))[2]
                AND e.student_id = auth.uid()
            )
        )
    );

-- =====================================================
-- ADMIN POLICIES
-- =====================================================

-- Allow admins to manage all storage objects
CREATE POLICY "Admins can manage all storage objects" ON storage.objects
    FOR ALL USING (
        bucket_id = 'storage-bucket' 
        AND EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =====================================================
-- STORAGE FOLDER STRUCTURE DOCUMENTATION
-- =====================================================

/*
Recommended folder structure for 'storage-bucket':

/profiles/{user_id}/
    - profile_image.jpg
    - profile_image.png

/courses/{course_id}/
    - thumbnail.jpg
    - thumbnail.png

/worksheets/{course_id}/
    - {worksheet_id}.pdf
    - {worksheet_id}.docx
    - {worksheet_id}.pptx

/forum/{course_id}/
    - {post_id}_{attachment_name}.{ext}
    - {reply_id}_{attachment_name}.{ext}

Example URLs:
- Profile: https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/profiles/user123/profile_image.jpg
- Course: https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/courses/course456/thumbnail.jpg
- Worksheet: https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/storage-bucket/worksheets/course456/worksheet789.pdf
*/

-- =====================================================
-- HELPER FUNCTIONS FOR STORAGE
-- =====================================================

-- Function to get storage URL for a file
CREATE OR REPLACE FUNCTION public.get_storage_url(bucket_name text, file_path text)
RETURNS text AS $$
BEGIN
    RETURN 'https://dzjidtzkxhurnuhvobel.supabase.co/storage/v1/object/public/' || bucket_name || '/' || file_path;
END;
$$ LANGUAGE plpgsql;

-- Function to validate file upload permissions
CREATE OR REPLACE FUNCTION public.can_upload_file(bucket_name text, file_path text, user_id uuid)
RETURNS boolean AS $$
DECLARE
    folder_parts text[];
    folder_type text;
    resource_id text;
BEGIN
    folder_parts := string_to_array(file_path, '/');
    folder_type := folder_parts[1];
    resource_id := folder_parts[2];
    
    CASE folder_type
        WHEN 'profiles' THEN
            RETURN resource_id = user_id::text;
        WHEN 'courses' THEN
            RETURN EXISTS (
                SELECT 1 FROM courses c
                WHERE c.id::text = resource_id AND c.instructor_id = user_id
            );
        WHEN 'worksheets' THEN
            RETURN EXISTS (
                SELECT 1 FROM courses c
                WHERE c.id::text = resource_id AND c.instructor_id = user_id
            );
        WHEN 'forum' THEN
            RETURN EXISTS (
                SELECT 1 FROM courses c
                WHERE c.id::text = resource_id 
                AND (
                    c.instructor_id = user_id OR
                    EXISTS (
                        SELECT 1 FROM enrollments e
                        WHERE e.course_id = c.id AND e.student_id = user_id
                    )
                )
            );
        ELSE
            RETURN false;
    END CASE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
