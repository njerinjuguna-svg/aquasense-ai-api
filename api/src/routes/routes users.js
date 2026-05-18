const express = require('express');
const router = express.Router();
const User = require('../models/model users');
const jwt = require('jsonwebtoken'); // <-- Kept exactly at the top of the route
const bcrypt = require('bcryptjs');

// STEP 1: REGISTER (Securely hashes password and maps fields)
router.post('/register', async (req, res) => {
    try {
        const { username, email, password, full_name, organization_type } = req.body;
        
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);
        
        // Maps the incoming snake_case parameters cleanly to your database model attributes
        const newUser = await User.create({
            username, 
            email, 
            password: hashedPassword, 
            full_name: full_name,             // Maps to database field names
            organization_type: organization_type
        });
        
        res.status(201).json({ message: 'User created', userId: newUser.id });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

// STEP 2: LOGIN (Credentials Verification & OTP Generation)
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ where: { email } });

        if (!user) {
            return res.status(401).json({ message: "Invalid email or password" });
        }

        // Direct bcrypt verification completely avoids reliance on external model prototype methods
        const isMatch = await bcrypt.compare(password, user.password);

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

// STEP 3: VERIFY OTP (Validates temporary code and mints production JWT access token)
router.post('/verify-otp', async (req, res) => {
    try {
        const { email, otp } = req.body;
        const user = await User.findOne({ where: { email, otp } });

        if (user && user.otpExpires > new Date()) {
            user.otp = null;
            user.otpExpires = null;
            await user.save();

            // Uses the top-level jwt import variable
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