const express = require('express');
const router = express.Router();
const User = require('../models/model users');
const jwt = require('jsonwebtoken');

// STEP 1: LOGIN (Credentials Check & OTP Generation)
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ where: { email } });

        if (user && (await user.matchPassword(password))) {
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

// STEP 2: VERIFY OTP
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

// ADDING A DUMMY REGISTER ROUTE TO PREVENT CRASHES IF APP.JS CALLS IT
router.post('/register', async (req, res) => {
    res.status(200).json({ message: "Register route is active" });
});

module.exports = router;