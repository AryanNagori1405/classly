const express = require("express");
const router = express.Router();
const jwt = require("jsonwebtoken");
const db = require("../config/database");

// Middleware for JWT authentication and teacher role verification
const authenticateJWT = (req, res, next) => {
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) return res.sendStatus(403);

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

// Create a new course
router.post("/", authenticateJWT, async (req, res) => {
  try {
    const { title, description } = req.body;
    if (req.user.role !== "teacher")
      return res.status(403).json({ message: "Unauthorized" });

    if (!title || !description) {
      return res
        .status(400)
        .json({ message: "Title and description are required" });
    }

    const query =
      "INSERT INTO courses (title, description, created_by, created_at, updated_at) VALUES ($1, $2, $3, NOW(), NOW()) RETURNING *";
    const result = await db.query(query, [title, description, req.user.id]);

    res.status(201).json({
      message: "Course created successfully",
      course: result.rows[0],
    });
  } catch (error) {
    console.error("Error creating course:", error);
    res
      .status(500)
      .json({ message: "Internal Server Error", error: error.message });
  }
});

// Retrieve all courses
router.get("/", async (req, res) => {
  try {
    const query = "SELECT * FROM courses ORDER BY created_at DESC";
    const result = await db.query(query);

    res.status(200).json({
      message: "Courses retrieved successfully",
      courses: result.rows,
    });
  } catch (error) {
    console.error("Error fetching courses:", error);
    res
      .status(500)
      .json({ message: "Internal Server Error", error: error.message });
  }
});

// Get a single course by ID
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const query = "SELECT * FROM courses WHERE id = $1";
    const result = await db.query(query, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Course not found" });
    }

    res.status(200).json({
      message: "Course retrieved successfully",
      course: result.rows[0],
    });
  } catch (error) {
    console.error("Error fetching course:", error);
    res
      .status(500)
      .json({ message: "Internal Server Error", error: error.message });
  }
});

// Update a course
router.put("/:id", authenticateJWT, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description } = req.body;

    if (req.user.role !== "teacher")
      return res.status(403).json({ message: "Unauthorized" });

    if (!title || !description) {
      return res
        .status(400)
        .json({ message: "Title and description are required" });
    }

    const query =
      "UPDATE courses SET title = $1, description = $2, updated_at = NOW() WHERE id = $3 RETURNING *";
    const result = await db.query(query, [title, description, id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Course not found" });
    }

    res.status(200).json({
      message: "Course updated successfully",
      course: result.rows[0],
    });
  } catch (error) {
    console.error("Error updating course:", error);
    res
      .status(500)
      .json({ message: "Internal Server Error", error: error.message });
  }
});

// Delete a course
router.delete("/:id", authenticateJWT, async (req, res) => {
  try {
    const { id } = req.params;

    if (req.user.role !== "teacher")
      return res.status(403).json({ message: "Unauthorized" });

    const query = "DELETE FROM courses WHERE id = $1 RETURNING id";
    const result = await db.query(query, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Course not found" });
    }

    res.status(200).json({
      message: "Course deleted successfully",
    });
  } catch (error) {
    console.error("Error deleting course:", error);
    res
      .status(500)
      .json({ message: "Internal Server Error", error: error.message });
  }
});

module.exports = router;
