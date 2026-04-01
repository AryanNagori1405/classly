const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// @route   POST /api/auth/register
// @desc    Register a new user
// @access  Public
router.post('/register', userController.register);

// @route   POST /api/auth/login
// @desc    Authenticate user & get token
// @access  Public
router.post('/login', userController.login);

module.exports = router;