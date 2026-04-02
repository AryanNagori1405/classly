const express = require('express');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const router = express.Router();

// Middleware to verify JWT token
function authenticateToken(req, res, next) {
    const token = req.headers['authorization'] && req.headers['authorization'].split(' ')[1];
    
    if (!token) {
        return res.status(401).json({ message: 'No token provided' });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ message: 'Invalid or expired token' });
        }
        req.user = user;
        next();
    });
}

// POST /api/feedback - Submit anonymous feedback to teacher
router.post('/', authenticateToken, async (req, res) => {
    try {
        const { teacher_id, course_id, feedback_type, message, rating } = req.body;
        const studentId = req.user.id;

        // Validate required fields
        if (!teacher_id || !message) {
            return res.status(400).json({ message: 'Teacher ID and message are required' });
        }

        // Validate feedback type
        const validTypes = ['suggestion', 'complaint', 'praise', 'question', 'other'];
        if (feedback_type && !validTypes.includes(feedback_type)) {
            return res.status(400).json({ message: 'Invalid feedback type' });
        }

        // Check if teacher exists
        const teacherResult = await pool.query(
            'SELECT * FROM users WHERE id = $1 AND role = $2',
            [teacher_id, 'teacher']
        );

        if (teacherResult.rows.length === 0) {
            return res.status(404).json({ message: 'Teacher not found' });
        }

        // Check if student is enrolled in course (if course_id provided)
        if (course_id) {
            const enrollmentResult = await pool.query(
                'SELECT * FROM enrollments WHERE course_id = $1 AND student_id = $2',
                [course_id, studentId]
            );

            if (enrollmentResult.rows.length === 0) {
                return res.status(403).json({ message: 'You are not enrolled in this course' });
            }
        }

        // Insert feedback (anonymous)
        const result = await pool.query(
            `INSERT INTO teacher_feedback (teacher_id, student_id, course_id, feedback_type, message, rating, is_anonymous, is_read, created_at)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, CURRENT_TIMESTAMP)
             RETURNING id, teacher_id, course_id, feedback_type, message, rating, is_read, created_at`,
            [teacher_id, studentId, course_id || null, feedback_type || 'other', message, rating || null, true, false]
        );

        res.status(201).json({
            message: 'Feedback submitted successfully (anonymous)',
            feedback: result.rows[0]
        });
    } catch (error) {
        console.error('Error submitting feedback:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/teachers/:teacherId/feedback - Teacher views their feedback
router.get('/teachers/:teacherId/feedback', authenticateToken, async (req, res) => {
    try {
        const { teacherId } = req.params;
        const userId = req.user.id;
        const { filter, sortBy } = req.query;

        // Check if user is the teacher
        if (parseInt(teacherId) !== userId) {
            return res.status(403).json({ message: 'You can only view your own feedback' });
        }

        let query = `
            SELECT tf.id, tf.teacher_id, tf.course_id, tf.feedback_type, tf.message, 
                   tf.rating, tf.is_read, tf.created_at, tf.updated_at,
                   CASE WHEN tf.is_anonymous THEN 'Anonymous Student' ELSE u.name END as student_name,
                   c.title as course_title
            FROM teacher_feedback tf
            JOIN users u ON tf.student_id = u.id
            LEFT JOIN courses c ON tf.course_id = c.id
            WHERE tf.teacher_id = $1
        `;

        let params = [teacherId];

        // Filter by type
        if (filter === 'unread') {
            query += ` AND tf.is_read = false`;
        } else if (filter && ['suggestion', 'complaint', 'praise', 'question', 'other'].includes(filter)) {
            query += ` AND tf.feedback_type = $${params.length + 1}`;
            params.push(filter);
        }

        // Sort by
        if (sortBy === 'oldest') {
            query += ` ORDER BY tf.created_at ASC`;
        } else if (sortBy === 'highest_rated') {
            query += ` ORDER BY tf.rating DESC`;
        } else if (sortBy === 'lowest_rated') {
            query += ` ORDER BY tf.rating ASC`;
        } else {
            query += ` ORDER BY tf.created_at DESC`;
        }

        const result = await pool.query(query, params);

        res.json({
            message: 'Feedback retrieved successfully',
            count: result.rows.length,
            feedback: result.rows
        });
    } catch (error) {
        console.error('Error fetching feedback:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// PATCH /api/feedback/:feedbackId/read - Mark feedback as read
router.patch('/:feedbackId/read', authenticateToken, async (req, res) => {
    try {
        const { feedbackId } = req.params;
        const userId = req.user.id;

        // Get feedback
        const feedbackResult = await pool.query(
            'SELECT * FROM teacher_feedback WHERE id = $1',
            [feedbackId]
        );

        if (feedbackResult.rows.length === 0) {
            return res.status(404).json({ message: 'Feedback not found' });
        }

        const feedback = feedbackResult.rows[0];

        // Check if user is the teacher
        if (feedback.teacher_id !== userId) {
            return res.status(403).json({ message: 'You can only mark your own feedback as read' });
        }

        // Update read status
        const result = await pool.query(
            `UPDATE teacher_feedback 
             SET is_read = true, updated_at = CURRENT_TIMESTAMP
             WHERE id = $1
             RETURNING *`,
            [feedbackId]
        );

        res.json({
            message: 'Feedback marked as read',
            feedback: result.rows[0]
        });
    } catch (error) {
        console.error('Error marking feedback as read:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// PATCH /api/feedback/:feedbackId/response - Teacher responds to feedback
router.patch('/:feedbackId/response', authenticateToken, async (req, res) => {
    try {
        const { feedbackId } = req.params;
        const { response_message } = req.body;
        const userId = req.user.id;

        // Validate required fields
        if (!response_message) {
            return res.status(400).json({ message: 'Response message is required' });
        }

        // Get feedback
        const feedbackResult = await pool.query(
            'SELECT * FROM teacher_feedback WHERE id = $1',
            [feedbackId]
        );

        if (feedbackResult.rows.length === 0) {
            return res.status(404).json({ message: 'Feedback not found' });
        }

        const feedback = feedbackResult.rows[0];

        // Check if user is the teacher
        if (feedback.teacher_id !== userId) {
            return res.status(403).json({ message: 'You can only respond to your own feedback' });
        }

        // Update feedback with response
        const result = await pool.query(
            `UPDATE teacher_feedback 
             SET teacher_response = $1, is_read = true, updated_at = CURRENT_TIMESTAMP
             WHERE id = $2
             RETURNING *`,
            [response_message, feedbackId]
        );

        res.json({
            message: 'Response added successfully',
            feedback: result.rows[0]
        });
    } catch (error) {
        console.error('Error adding response:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// DELETE /api/feedback/:feedbackId - Teacher deletes feedback
router.delete('/:feedbackId', authenticateToken, async (req, res) => {
    try {
        const { feedbackId } = req.params;
        const userId = req.user.id;

        // Get feedback
        const feedbackResult = await pool.query(
            'SELECT * FROM teacher_feedback WHERE id = $1',
            [feedbackId]
        );

        if (feedbackResult.rows.length === 0) {
            return res.status(404).json({ message: 'Feedback not found' });
        }

        const feedback = feedbackResult.rows[0];

        // Check if user is the teacher
        if (feedback.teacher_id !== userId) {
            return res.status(403).json({ message: 'You can only delete your own feedback' });
        }

        // Delete feedback
        await pool.query(
            'DELETE FROM teacher_feedback WHERE id = $1',
            [feedbackId]
        );

        res.json({ message: 'Feedback deleted successfully' });
    } catch (error) {
        console.error('Error deleting feedback:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/feedback/stats - Get feedback statistics for teacher
router.get('/teachers/:teacherId/stats', authenticateToken, async (req, res) => {
    try {
        const { teacherId } = req.params;
        const userId = req.user.id;

        // Check if user is the teacher
        if (parseInt(teacherId) !== userId) {
            return res.status(403).json({ message: 'You can only view your own stats' });
        }

        // Get statistics
        const statsResult = await pool.query(
            `SELECT 
                COUNT(*) as total_feedback,
                SUM(CASE WHEN is_read = false THEN 1 ELSE 0 END) as unread_count,
                AVG(rating) as average_rating,
                feedback_type,
                COUNT(*) as type_count
             FROM teacher_feedback
             WHERE teacher_id = $1
             GROUP BY feedback_type
             ORDER BY type_count DESC`,
            [teacherId]
        );

        const totalStats = await pool.query(
            `SELECT 
                COUNT(*) as total_feedback,
                SUM(CASE WHEN is_read = false THEN 1 ELSE 0 END) as unread_count,
                AVG(rating) as average_rating
             FROM teacher_feedback
             WHERE teacher_id = $1`,
            [teacherId]
        );

        res.json({
            message: 'Feedback statistics retrieved',
            overall_stats: totalStats.rows[0],
            by_type: statsResult.rows
        });
    } catch (error) {
        console.error('Error fetching stats:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;