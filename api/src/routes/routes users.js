const express = require('express');
const router = express.Router();
const User = require('../models/model users');
const jwt = require('jsonwebtoken'); // <-- Kept exactly at the top of the route file
const bcrypt = require('bcryptjs');
const protect = require('../middleware/authMiddleware'); // Middleware to secure the profile route

// ==========================================
// STEP 1: REGISTER NEW USER
// URL: POST https://aquasense-ai-api.onrender.com/api/users/register
// ==========================================
router.post('/register', async (req, res) => {
    try {
        const { username, email, password, full_name, organization_type } = req.body;
        
        // Intercept duplicates early to avoid database validation crashes
        const existingUser = await User.findOne({ where: { email } });
        if (existingUser) {
            return res.status(400).json({ message: "A user with this email already exists" });
        }

        // Pass raw password to let model hooks handle hashing safely
        const newUser = await User.create({
            username, 
            email, 
            password: password, 
            full_name, 
            organization_type
        });
        
        res.status(201).json({ message: 'User created', userId: newUser.id });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

// ==========================================
// STEP 2: LOGIN (Credentials Check & Static OTP Setting)
// URL: POST https://aquasense-ai-api.onrender.com/api/users/login
// ==========================================
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ where: { email } });

        if (!user) {
            return res.status(401).json({ message: "Invalid email or password" });
        }

        let isMatch = false;

        // Fallback Check 1: Try using the model's instance method if it exists
        if (typeof user.matchPassword === 'function') {
            isMatch = await user.matchPassword(password);
        } else {
            // Fallback Check 2: Direct bcrypt comparison
            isMatch = await bcrypt.compare(password, user.password);
        }

        if (isMatch) {
            // Set static code to '000000' for seamless frontend testing
            const otp = "000000";
            const expires = new Date(Date.now() + 10 * 60 * 1000);

            user.otp = otp;
            user.otpExpires = expires;
            await user.save();

            console.log(`\n🔑 STATIC OTP FOR: ${email} -> ${otp}\n`);

            return res.status(200).json({ message: "OTP generated. Check terminal." });
        }
        
        res.status(401).json({ message: "Invalid email or password" });
    } catch (error) {
        res.status(500).json({ message: "Server error", error: error.message });
    }
});

// ==========================================
// STEP 3: VERIFY OTP (Validates static 000000 and returns production JWT token)
// URL: POST https://aquasense-ai-api.onrender.com/api/users/verify-otp
// ==========================================
router.post('/verify-otp', async (req, res) => {
    try {
        const { email, otp } = req.body;
        const user = await User.findOne({ where: { email, otp } });

        if (user && user.otpExpires > new Date()) {
            user.otp = null;
            user.otpExpires = null;
            await user.save();

            // Sign and hand back the production access token
            const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1d' });

            res.status(200).json({ message: "Login verified!", token });
        } else {
            res.status(400).json({ message: "Invalid or expired OTP" });
        }
    } catch (error) {
        res.status(500).json({ message: "Verification error", error: error.message });
    }
});

// ==========================================
// STEP 4: GET USER PROFILE (Direct verification fallback)
// URL: GET https://aquasense-ai-api.onrender.com/api/users/profile
// ==========================================
router.get('/profile', protect, async (req, res) => {
    try {
        // 1. Check if the middleware already attached it somewhere
        let currentUser = req.user || req.User;

        // 2. If middleware failed to attach the user, read the token directly from the headers ourselves
        if (!currentUser && req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
            try {
                // Split the word 'Bearer' away to get just the token string
                const token = req.headers.authorization.split(' ')[1].replace(/['"]+/g, ''); // Removes any accidental quotes
                
                // Decode the token using your environment secret
                const decoded = jwt.verify(token, process.env.JWT_SECRET);
                
                // Fetch the full user from the database using the ID hidden inside the token
                currentUser = await User.findByPk(decoded.id, {
                    attributes: { exclude: ['password', 'otp', 'otpExpires'] }
                });
            } catch (jwtError) {
                return res.status(401).json({ message: "Token verification failed inside route", error: jwtError.message });
            }
        }

        // 3. Final safety check
        if (!currentUser) {
            return res.status(404).json({ 
                message: "User profile data not found. Ensure the token belongs to an active database record." 
            });
        }

        // 4. Return the user profile data
        res.status(200).json(currentUser);

    } catch (error) {
        res.status(500).json({ message: "Server error fetching profile", error: error.message });
    }
});

module.exports = router;