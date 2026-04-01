require('dotenv').config();
const express = require('express');
const pool = require('./config/database');
const authRoutes = require('./routes/auth');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(express.json());

// Test database connection
pool.query('SELECT NOW()', (err, res) => {
    if (err) {
        console.error('Database connection failed:', err);
    } else {
        console.log('✅ Connected to PostgreSQL Database successfully!');
    }
});

// Routes
app.get('/', (req, res) => {
    res.json({ message: 'Welcome to Classly Backend API' });
});

// Auth Routes
app.use('/api/auth', authRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: 'Internal Server Error', error: err.message });
});

app.listen(PORT, () => {
    console.log(`✅ Server is running on port ${PORT}`);
});