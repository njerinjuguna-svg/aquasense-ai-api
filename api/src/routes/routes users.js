const express = require('express');
const router = express.Router();
const User = require('../models/model users');
const jwt = require('jsonwebtoken'); // Kept right here at the top
const bcrypt = require('bcryptjs');

// STEP 1: REGISTER (Relies on model hooks to prevent double-hashing)
router.post('/register', async (req, res) => {
    try {
        const { username, email, password, full_name, organization_type } = req.body;
        
        // Check if user already exists
        const existingUser = await User.findOne({ where: { email } });
        if (existingUser) {
            return res.status(400).json({ message: "A user with this email already exists" });
        }

        // Pass the raw password directly. If your model hashes automatically, this prevents a double-hash crash.
        const newUser = await User.create({
            username, 
            email, 
            password: password, // Sending raw password to let model hooks run cleanly
            full_name, 
            organization_type
        });
        
        res.status(201).json({ message: 'User created', userId: newUser.id });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

// STEP 2: LOGIN (Robust fallbacks for both direct hashes and instance methods)
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
            // Fallback Check 2: Direct bcrypt comparison against the database string
            isMatch = await bcrypt.compare(password, user.password);
        }

        if (isMatch) {
            const otp = Math.floor(100000 + Math.random() * 900000).toString();
            const expires = new Date(Date.now() + 10 * 60 * 1000);

            user.otp = otp;
            user.otpExpires = expires;
            await user.save();

            console.log(`\n🔑 OTP FOR: ${email} -> ${otp}\n`);

            return res.status(200).json({ message: "OTP generated. Check terminal." });
        }
        
        res.status(401).json({ message: "Invalid email or password" });
    } catch (error) {
        res.status(500).json({ message: "Server error", error: error.message });
    }
});

// STEP 3: VERIFY OTP
router.post('/verify-otp', async (req, res) => {
    try {
        const { email, otp } = req.body;
        const user = await User.findOne({ where: { email, otp } });

        if (user && user.otpExpires > new Date()) {
            user.otp = null;
            user.otpExpires = null;
            await user.save();

            const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1d' });

            res.status(200).json({ message: "Login verified!", token });
        } else {
            res.status(400).json({ message: "Invalid or expired OTP" });
        }
    } catch (error) {
        res.status(500).json({ message: "Verification error", error: error.message });
    }
});

module.exports = router;