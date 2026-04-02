const express = require('express');
const router = express.Router();
const Enrollment = require('../models/enrollmentModel');
const db = require('../config/database');

// ===== ENROLL A STUDENT IN A COURSE =====
router.post('/enroll', async (req, res) => {
    try {
        const { studentId, courseId } = req.body;

        // Validation
        if (!studentId || !courseId) {
            return res.status(400).json({ message: 'studentId and courseId are required' });
        }

        // Check if student already enrolled
        const isAlreadyEnrolled = await Enrollment.isEnrolled(studentId, courseId);
        if (isAlreadyEnrolled) {
            return res.status(400).json({ message: 'Student already enrolled in this course' });
        }

        // Enroll student
        const result = await Enrollment.enrollStudent(studentId, courseId);
        
        res.status(201).json({
            message: 'Student enrolled successfully',
            enrollment: result.rows[0]
        });
    } catch (error) {
        console.error('Error enrolling student:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== GET ALL COURSES FOR A STUDENT =====
router.get('/my-courses/:studentId', async (req, res) => {
    try {
        const { studentId } = req.params;

        if (!studentId) {
            return res.status(400).json({ message: 'studentId is required' });
        }

        const result = await Enrollment.getStudentEnrollments(studentId);

        res.status(200).json({
            message: 'Student courses retrieved successfully',
            courses: result.rows
        });
    } catch (error) {
        console.error('Error fetching student enrollments:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== GET ALL STUDENTS IN A COURSE =====
router.get('/course/:courseId', async (req, res) => {
    try {
        const { courseId } = req.params;

        if (!courseId) {
            return res.status(400).json({ message: 'courseId is required' });
        }

        const result = await Enrollment.getCourseEnrollments(courseId);

        res.status(200).json({
            message: 'Course students retrieved successfully',
            students: result.rows
        });
    } catch (error) {
        console.error('Error fetching course enrollments:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== UNENROLL STUDENT FROM COURSE =====
router.delete('/unenroll', async (req, res) => {
    try {
        const { studentId, courseId } = req.body;

        if (!studentId || !courseId) {
            return res.status(400).json({ message: 'studentId and courseId are required' });
        }

        // Check if student is enrolled
        const isEnrolled = await Enrollment.isEnrolled(studentId, courseId);
        if (!isEnrolled) {
            return res.status(400).json({ message: 'Student is not enrolled in this course' });
        }

        // Unenroll student
        const result = await Enrollment.unenrollStudent(studentId, courseId);

        res.status(200).json({
            message: 'Student unenrolled successfully',
            enrollment: result.rows[0]
        });
    } catch (error) {
        console.error('Error unenrolling student:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== CHECK IF STUDENT IS ENROLLED =====
router.get('/check/:studentId/:courseId', async (req, res) => {
    try {
        const { studentId, courseId } = req.params;

        if (!studentId || !courseId) {
            return res.status(400).json({ message: 'studentId and courseId are required' });
        }

        const isEnrolled = await Enrollment.isEnrolled(studentId, courseId);

        res.status(200).json({
            message: 'Enrollment status retrieved',
            isEnrolled: isEnrolled
        });
    } catch (error) {
        console.error('Error checking enrollment:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== GET ENROLLMENT STATISTICS =====
router.get('/stats/:courseId', async (req, res) => {
    try {
        const { courseId } = req.params;

        if (!courseId) {
            return res.status(400).json({ message: 'courseId is required' });
        }

        const result = await Enrollment.getEnrollmentStats(courseId);

        res.status(200).json({
            message: 'Enrollment statistics retrieved',
            stats: result.rows[0]
        });
    } catch (error) {
        console.error('Error fetching enrollment stats:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

module.exports = router;