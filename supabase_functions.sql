-- =====================================================
-- BLApp - Additional Database Functions and Triggers
-- =====================================================
-- This file contains useful database functions for analytics, 
-- enrollment management, and other business logic

-- =====================================================
-- ANALYTICS FUNCTIONS
-- =====================================================

-- Function to get course analytics
CREATE OR REPLACE FUNCTION public.get_course_analytics(course_uuid UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'course_id', c.id,
        'course_title', c.title,
        'instructor_name', p.name,
        'total_enrollments', COUNT(DISTINCT e.id),
        'active_enrollments', COUNT(DISTINCT CASE WHEN e.completed_at IS NULL THEN e.id END),
        'completed_enrollments', COUNT(DISTINCT CASE WHEN e.completed_at IS NOT NULL THEN e.id END),
        'average_progress', COALESCE(AVG(e.progress), 0),
        'total_videos', COUNT(DISTINCT v.id),
        'total_quizzes', COUNT(DISTINCT q.id),
        'total_quiz_submissions', COUNT(DISTINCT qs.id),
        'average_quiz_score', COALESCE(AVG(qs.score::float / qs.total_questions * 100), 0),
        'quiz_pass_rate', COALESCE(
            COUNT(DISTINCT CASE WHEN qs.passed THEN qs.id END)::float / 
            NULLIF(COUNT(DISTINCT qs.id), 0) * 100, 0
        ),
        'total_forum_posts', COUNT(DISTINCT fp.id),
        'total_forum_replies', COUNT(DISTINCT fr.id),
        'engagement_score', COALESCE(
            (COUNT(DISTINCT fp.id) + COUNT(DISTINCT fr.id) + COUNT(DISTINCT qs.id))::float / 
            NULLIF(COUNT(DISTINCT e.id), 0), 0
        )
    ) INTO result
    FROM courses c
    LEFT JOIN profiles p ON p.id = c.instructor_id
    LEFT JOIN enrollments e ON e.course_id = c.id
    LEFT JOIN videos v ON v.course_id = c.id
    LEFT JOIN quizzes q ON q.course_id = c.id
    LEFT JOIN quiz_submissions qs ON qs.quiz_id = q.id
    LEFT JOIN forum_posts fp ON fp.course_id = c.id
    LEFT JOIN forum_replies fr ON fr.post_id = fp.id
    WHERE c.id = course_uuid
    GROUP BY c.id, c.title, p.name;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get student analytics
CREATE OR REPLACE FUNCTION public.get_student_analytics(student_uuid UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'student_id', p.id,
        'student_name', p.name,
        'total_enrollments', COUNT(DISTINCT e.id),
        'completed_courses', COUNT(DISTINCT CASE WHEN e.completed_at IS NOT NULL THEN e.id END),
        'average_course_progress', COALESCE(AVG(e.progress), 0),
        'total_videos_watched', COUNT(DISTINCT CASE WHEN vp.is_watched THEN vp.id END),
        'total_quiz_attempts', COUNT(DISTINCT qs.id),
        'total_quiz_passes', COUNT(DISTINCT CASE WHEN qs.passed THEN qs.id END),
        'average_quiz_score', COALESCE(AVG(qs.score::float / qs.total_questions * 100), 0),
        'quiz_pass_rate', COALESCE(
            COUNT(DISTINCT CASE WHEN qs.passed THEN qs.id END)::float / 
            NULLIF(COUNT(DISTINCT qs.id), 0) * 100, 0
        ),
        'total_forum_posts', COUNT(DISTINCT fp.id),
        'total_forum_replies', COUNT(DISTINCT fr.id),
        'learning_streak_days', 0, -- Placeholder for streak calculation
        'last_activity', MAX(GREATEST(
            e.enrolled_at,
            vp.completed_at,
            qs.submitted_at,
            fp.created_at,
            fr.created_at
        ))
    ) INTO result
    FROM profiles p
    LEFT JOIN enrollments e ON e.student_id = p.id
    LEFT JOIN video_progress vp ON vp.student_id = p.id
    LEFT JOIN quiz_submissions qs ON qs.student_id = p.id
    LEFT JOIN forum_posts fp ON fp.author_id = p.id
    LEFT JOIN forum_replies fr ON fr.author_id = p.id
    WHERE p.id = student_uuid AND p.role = 'student'
    GROUP BY p.id, p.name;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get instructor analytics
CREATE OR REPLACE FUNCTION public.get_instructor_analytics(instructor_uuid UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'instructor_id', p.id,
        'instructor_name', p.name,
        'total_courses', COUNT(DISTINCT c.id),
        'approved_courses', COUNT(DISTINCT CASE WHEN c.is_approved THEN c.id END),
        'pending_courses', COUNT(DISTINCT CASE WHEN NOT c.is_approved THEN c.id END),
        'total_students', COUNT(DISTINCT e.student_id),
        'total_enrollments', COUNT(DISTINCT e.id),
        'average_course_rating', COALESCE(AVG(c.rating), 0),
        'total_videos', COUNT(DISTINCT v.id),
        'total_quizzes', COUNT(DISTINCT q.id),
        'total_worksheets', COUNT(DISTINCT w.id),
        'total_forum_interactions', COUNT(DISTINCT fp.id) + COUNT(DISTINCT fr.id),
        'student_engagement_rate', COALESCE(
            COUNT(DISTINCT CASE WHEN e.progress > 0 THEN e.id END)::float / 
            NULLIF(COUNT(DISTINCT e.id), 0) * 100, 0
        )
    ) INTO result
    FROM profiles p
    LEFT JOIN courses c ON c.instructor_id = p.id
    LEFT JOIN enrollments e ON e.course_id = c.id
    LEFT JOIN videos v ON v.course_id = c.id
    LEFT JOIN quizzes q ON q.course_id = c.id
    LEFT JOIN worksheets w ON w.course_id = c.id
    LEFT JOIN forum_posts fp ON fp.course_id = c.id
    LEFT JOIN forum_replies fr ON fr.post_id = fp.id
    WHERE p.id = instructor_uuid AND p.role = 'instructor'
    GROUP BY p.id, p.name;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get system-wide analytics
-- Drop the function first to ensure clean recreation
DROP FUNCTION IF EXISTS public.get_system_analytics();

CREATE OR REPLACE FUNCTION public.get_system_analytics()
RETURNS JSON AS $$
DECLARE
    result JSON;
    total_users_count INTEGER;
    total_students_count INTEGER;
    total_instructors_count INTEGER;
    total_admins_count INTEGER;
    total_courses_count INTEGER;
    approved_courses_count INTEGER;
    pending_courses_count INTEGER;
    total_enrollments_count INTEGER;
    total_videos_count INTEGER;
    total_quizzes_count INTEGER;
    total_quiz_submissions_count INTEGER;
    total_forum_posts_count INTEGER;
    total_forum_replies_count INTEGER;
    avg_course_rating NUMERIC;
    completion_rate_value NUMERIC;
    quiz_pass_rate_value NUMERIC;
BEGIN
    -- Get user counts with error handling
    BEGIN
        SELECT COUNT(*) INTO total_users_count FROM profiles;
        SELECT COUNT(*) INTO total_students_count FROM profiles WHERE role = 'student';
        SELECT COUNT(*) INTO total_instructors_count FROM profiles WHERE role = 'instructor';
        SELECT COUNT(*) INTO total_admins_count FROM profiles WHERE role = 'admin';
    EXCEPTION WHEN OTHERS THEN
        total_users_count := 0;
        total_students_count := 0;
        total_instructors_count := 0;
        total_admins_count := 0;
    END;

    -- Get course counts with error handling
    BEGIN
        SELECT COUNT(*) INTO total_courses_count FROM courses;
        SELECT COUNT(*) INTO approved_courses_count FROM courses WHERE is_approved = true;
        SELECT COUNT(*) INTO pending_courses_count FROM courses WHERE is_approved = false;
    EXCEPTION WHEN OTHERS THEN
        total_courses_count := 0;
        approved_courses_count := 0;
        pending_courses_count := 0;
    END;

    -- Get other counts with error handling
    BEGIN
        SELECT COUNT(*) INTO total_enrollments_count FROM enrollments;
    EXCEPTION WHEN OTHERS THEN
        total_enrollments_count := 0;
    END;

    BEGIN
        SELECT COUNT(*) INTO total_videos_count FROM videos;
    EXCEPTION WHEN OTHERS THEN
        total_videos_count := 0;
    END;

    BEGIN
        SELECT COUNT(*) INTO total_quizzes_count FROM quizzes;
    EXCEPTION WHEN OTHERS THEN
        total_quizzes_count := 0;
    END;

    BEGIN
        SELECT COUNT(*) INTO total_quiz_submissions_count FROM quiz_submissions;
    EXCEPTION WHEN OTHERS THEN
        total_quiz_submissions_count := 0;
    END;

    BEGIN
        SELECT COUNT(*) INTO total_forum_posts_count FROM forum_posts;
    EXCEPTION WHEN OTHERS THEN
        total_forum_posts_count := 0;
    END;

    BEGIN
        SELECT COUNT(*) INTO total_forum_replies_count FROM forum_replies;
    EXCEPTION WHEN OTHERS THEN
        total_forum_replies_count := 0;
    END;

    -- Get average course rating with error handling
    BEGIN
        SELECT COALESCE(AVG(rating), 0) INTO avg_course_rating FROM courses WHERE is_approved = true;
    EXCEPTION WHEN OTHERS THEN
        avg_course_rating := 0;
    END;

    -- Get completion rate with error handling
    BEGIN
        SELECT COALESCE(
            COUNT(CASE WHEN completed_at IS NOT NULL THEN 1 END)::float /
            NULLIF(COUNT(*), 0) * 100, 0
        ) INTO completion_rate_value FROM enrollments;
    EXCEPTION WHEN OTHERS THEN
        completion_rate_value := 0;
    END;

    -- Get quiz pass rate with error handling
    BEGIN
        SELECT COALESCE(
            COUNT(CASE WHEN passed THEN 1 END)::float /
            NULLIF(COUNT(*), 0) * 100, 0
        ) INTO quiz_pass_rate_value FROM quiz_submissions;
    EXCEPTION WHEN OTHERS THEN
        quiz_pass_rate_value := 0;
    END;

    -- Build the result JSON
    SELECT json_build_object(
        'total_users', total_users_count,
        'total_students', total_students_count,
        'total_instructors', total_instructors_count,
        'total_admins', total_admins_count,
        'total_courses', total_courses_count,
        'approved_courses', approved_courses_count,
        'pending_courses', pending_courses_count,
        'total_enrollments', total_enrollments_count,
        'total_videos', total_videos_count,
        'total_quizzes', total_quizzes_count,
        'total_quiz_submissions', total_quiz_submissions_count,
        'total_forum_posts', total_forum_posts_count,
        'total_forum_replies', total_forum_replies_count,
        'average_course_rating', avg_course_rating,
        'completion_rate', completion_rate_value,
        'quiz_pass_rate', quiz_pass_rate_value
    ) INTO result;

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- ENROLLMENT MANAGEMENT FUNCTIONS
-- =====================================================

-- Function to enroll student in course
CREATE OR REPLACE FUNCTION public.enroll_student(student_uuid UUID, course_uuid UUID)
RETURNS JSON AS $$
DECLARE
    enrollment_id UUID;
    result JSON;
BEGIN
    -- Check if course is approved
    IF NOT EXISTS (SELECT 1 FROM courses WHERE id = course_uuid AND is_approved = true) THEN
        RETURN json_build_object('success', false, 'error', 'Course not found or not approved');
    END IF;
    
    -- Check if student exists and has student role
    IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = student_uuid AND role = 'student') THEN
        RETURN json_build_object('success', false, 'error', 'Student not found');
    END IF;
    
    -- Check if already enrolled
    IF EXISTS (SELECT 1 FROM enrollments WHERE student_id = student_uuid AND course_id = course_uuid) THEN
        RETURN json_build_object('success', false, 'error', 'Student already enrolled in this course');
    END IF;
    
    -- Create enrollment
    INSERT INTO enrollments (student_id, course_id) 
    VALUES (student_uuid, course_uuid) 
    RETURNING id INTO enrollment_id;
    
    -- Log analytics event
    INSERT INTO analytics_events (user_id, event_type, course_id, event_data)
    VALUES (student_uuid, 'course_enrolled', course_uuid, json_build_object('enrollment_id', enrollment_id));
    
    RETURN json_build_object('success', true, 'enrollment_id', enrollment_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update course progress
CREATE OR REPLACE FUNCTION public.update_course_progress(student_uuid UUID, course_uuid UUID)
RETURNS DECIMAL AS $$
DECLARE
    total_videos INTEGER;
    watched_videos INTEGER;
    progress_percentage DECIMAL;
BEGIN
    -- Get total videos in course
    SELECT COUNT(*) INTO total_videos
    FROM videos 
    WHERE course_id = course_uuid;
    
    -- Get watched videos by student
    SELECT COUNT(*) INTO watched_videos
    FROM video_progress vp
    JOIN videos v ON v.id = vp.video_id
    WHERE vp.student_id = student_uuid 
    AND v.course_id = course_uuid 
    AND vp.is_watched = true;
    
    -- Calculate progress percentage
    IF total_videos > 0 THEN
        progress_percentage := (watched_videos::DECIMAL / total_videos) * 100;
    ELSE
        progress_percentage := 0;
    END IF;
    
    -- Update enrollment progress
    UPDATE enrollments 
    SET progress = progress_percentage,
        completed_at = CASE WHEN progress_percentage >= 100 THEN NOW() ELSE NULL END
    WHERE student_id = student_uuid AND course_id = course_uuid;
    
    RETURN progress_percentage;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- QUIZ MANAGEMENT FUNCTIONS
-- =====================================================

-- Function to submit quiz
CREATE OR REPLACE FUNCTION public.submit_quiz(
    quiz_uuid UUID, 
    student_uuid UUID, 
    answers_json JSONB,
    time_spent INTEGER
)
RETURNS JSON AS $$
DECLARE
    quiz_record RECORD;
    question_record RECORD;
    correct_answers INTEGER := 0;
    total_questions INTEGER := 0;
    score_percentage DECIMAL;
    is_passed BOOLEAN;
    submission_id UUID;
    result JSON;
BEGIN
    -- Get quiz details
    SELECT * INTO quiz_record FROM quizzes WHERE id = quiz_uuid AND is_active = true;
    
    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'error', 'Quiz not found or inactive');
    END IF;
    
    -- Check if student is enrolled in the course
    IF NOT EXISTS (
        SELECT 1 FROM enrollments e
        JOIN courses c ON c.id = e.course_id
        WHERE e.student_id = student_uuid AND c.id = quiz_record.course_id
    ) THEN
        RETURN json_build_object('success', false, 'error', 'Student not enrolled in course');
    END IF;
    
    -- Calculate score
    FOR question_record IN 
        SELECT * FROM questions WHERE quiz_id = quiz_uuid ORDER BY order_index
    LOOP
        total_questions := total_questions + 1;
        
        IF (answers_json->question_record.id::text)::INTEGER = question_record.correct_answer_index THEN
            correct_answers := correct_answers + 1;
        END IF;
    END LOOP;
    
    -- Calculate percentage and pass status
    IF total_questions > 0 THEN
        score_percentage := (correct_answers::DECIMAL / total_questions) * 100;
        is_passed := score_percentage >= quiz_record.passing_score;
    ELSE
        score_percentage := 0;
        is_passed := false;
    END IF;
    
    -- Insert submission
    INSERT INTO quiz_submissions (
        quiz_id, student_id, answers, score, total_questions, 
        time_spent_minutes, passed
    ) VALUES (
        quiz_uuid, student_uuid, answers_json, correct_answers, total_questions,
        time_spent, is_passed
    ) RETURNING id INTO submission_id;
    
    -- Log analytics event
    INSERT INTO analytics_events (user_id, event_type, course_id, quiz_id, event_data)
    VALUES (
        student_uuid, 'quiz_completed', quiz_record.course_id, quiz_uuid,
        json_build_object(
            'score', correct_answers,
            'total_questions', total_questions,
            'percentage', score_percentage,
            'passed', is_passed,
            'time_spent', time_spent
        )
    );
    
    RETURN json_build_object(
        'success', true,
        'submission_id', submission_id,
        'score', correct_answers,
        'total_questions', total_questions,
        'percentage', score_percentage,
        'passed', is_passed
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- VIDEO PROGRESS FUNCTIONS
-- =====================================================

-- Function to mark video as watched
CREATE OR REPLACE FUNCTION public.mark_video_watched(
    video_uuid UUID,
    student_uuid UUID,
    watch_time INTEGER
)
RETURNS JSON AS $$
DECLARE
    video_record RECORD;
    course_uuid UUID;
    result JSON;
BEGIN
    -- Get video details
    SELECT * INTO video_record FROM videos WHERE id = video_uuid;
    
    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'error', 'Video not found');
    END IF;
    
    course_uuid := video_record.course_id;
    
    -- Check if student is enrolled
    IF NOT EXISTS (
        SELECT 1 FROM enrollments 
        WHERE student_id = student_uuid AND course_id = course_uuid
    ) THEN
        RETURN json_build_object('success', false, 'error', 'Student not enrolled in course');
    END IF;
    
    -- Insert or update video progress
    INSERT INTO video_progress (student_id, video_id, is_watched, watch_time_seconds, completed_at)
    VALUES (student_uuid, video_uuid, true, watch_time, NOW())
    ON CONFLICT (student_id, video_id) 
    DO UPDATE SET 
        is_watched = true,
        watch_time_seconds = GREATEST(video_progress.watch_time_seconds, watch_time),
        completed_at = COALESCE(video_progress.completed_at, NOW());
    
    -- Update course progress
    PERFORM update_course_progress(student_uuid, course_uuid);
    
    -- Log analytics event
    INSERT INTO analytics_events (user_id, event_type, course_id, video_id, event_data)
    VALUES (
        student_uuid, 'video_watched', course_uuid, video_uuid,
        json_build_object('watch_time', watch_time, 'completion_rate', 
            CASE WHEN watch_time >= video_record.duration_seconds * 0.8 THEN 100 
                 ELSE (watch_time::DECIMAL / video_record.duration_seconds * 100) 
            END
        )
    );
    
    RETURN json_build_object('success', true, 'message', 'Video progress updated');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
