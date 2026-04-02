const pool = require('../config/database');

class Enrollment {
    // ===== ENROLL STUDENT =====
    static async enrollStudent(studentId, courseId) {
        const query = `
            INSERT INTO enrollments (student_id, course_id, enrolled_at)
            VALUES ($1, $2, NOW())
            RETURNING id, student_id, course_id, enrolled_at
        `;
        return await pool.query(query, [studentId, courseId]);
    }

    // ===== GET STUDENT ENROLLMENTS (All courses for a student) =====
    static async getStudentEnrollments(studentId) {
        const query = `
            SELECT 
                e.id,
                e.student_id,
                c.id as course_id,
                c.course_name,
                c.description,
                c.instructor_id,
                e.enrolled_at
            FROM enrollments e
            JOIN courses c ON e.course_id = c.id
            WHERE e.student_id = $1
            ORDER BY e.enrolled_at DESC
        `;
        return await pool.query(query, [studentId]);
    }

    // ===== GET COURSE ENROLLMENTS (All students in a course) =====
    static async getCourseEnrollments(courseId) {
        const query = `
            SELECT 
                e.id,
                e.student_id,
                u.username,
                u.email,
                c.id as course_id,
                c.course_name,
                e.enrolled_at
            FROM enrollments e
            JOIN users u ON e.student_id = u.id
            JOIN courses c ON e.course_id = c.id
            WHERE e.course_id = $1
            ORDER BY e.enrolled_at DESC
        `;
        return await pool.query(query, [courseId]);
    }

    // ===== UNENROLL STUDENT =====
    static async unenrollStudent(studentId, courseId) {
        const query = `
            DELETE FROM enrollments
            WHERE student_id = $1 AND course_id = $2
            RETURNING id, student_id, course_id
        `;
        return await pool.query(query, [studentId, courseId]);
    }

    // ===== CHECK IF STUDENT IS ENROLLED =====
    static async isEnrolled(studentId, courseId) {
        const query = `
            SELECT id FROM enrollments
            WHERE student_id = $1 AND course_id = $2
            LIMIT 1
        `;
        const result = await pool.query(query, [studentId, courseId]);
        return result.rows.length > 0;
    }

    // ===== GET ENROLLMENT STATISTICS =====
    static async getEnrollmentStats(courseId) {
        const query = `
            SELECT 
                c.id as course_id,
                c.course_name,
                COUNT(e.id) as total_students,
                MAX(e.enrolled_at) as latest_enrollment
            FROM courses c
            LEFT JOIN enrollments e ON c.id = e.course_id
            WHERE c.id = $1
            GROUP BY c.id, c.course_name
        `;
        return await pool.query(query, [courseId]);
    }
}

module.exports = Enrollment;