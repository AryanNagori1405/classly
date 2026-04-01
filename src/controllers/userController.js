const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Register User Function
exports.register = async (req, res) => {
    const { username, password } = req.body;
    try {
        // Check if user already exists
        // const existingUser = await User.findOne({ username });
        // if (existingUser) {
        //     return res.status(400).send('User already exists');
        // }

        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create user
        // const newUser = await User.create({ username, password: hashedPassword });

        return res.status(201).send('User registered successfully');
    } catch (error) {
        return res.status(500).send('Internal Server Error');
    }
};

// Login User Function
exports.login = async (req, res) => {
    const { username, password } = req.body;
    try {
        // Find user
        // const user = await User.findOne({ username });
        // if (!user) {
        //     return res.status(404).send('User not found');
        // }

        // Compare password
        const isMatch = await bcrypt.compare(password, user.password);
        // if (!isMatch) {
        //     return res.status(400).send('Invalid credentials');
        // }

        // Generate token
        const token = jwt.sign({ id: user._id }, 'your_jwt_secret', { expiresIn: '1h' });

        return res.status(200).json({ token });
    } catch (error) {
        return res.status(500).send('Internal Server Error');
    }
};
