// JWT middleware
const jwt = require('jsonwebtoken');

// Middleware for JWT verification
function verifyToken(req, res, next) {
    const token = req.headers['authorization'];
    if (!token) return res.status(403).send('A token is required for authentication');
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
    } catch (err) {
        return res.status(401).send('Invalid Token');
    }
    return next();
}

// Protected route for user profile
app.get('/api/user/profile', verifyToken, (req, res) => {
    // Logic to retrieve user profile
    res.send(req.user);
});

// Protected route for updating user profile
app.put('/api/user/profile', verifyToken, (req, res) => {
    // Logic to update user profile
    res.send('User profile updated');
});

// Protected route for deleting account
app.delete('/api/user/account', verifyToken, (req, res) => {
    // Logic to delete user account
    res.send('User account deleted');
});