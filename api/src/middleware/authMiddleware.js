const express = require('express');
const router = express.Router();
const User = require('../models/model users');
const jwt = require('jsonwebtoken');

// STEP 1: LOGIN (Credentials Check & OTP Generation)
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ where: { email } });

        // Verify user exists and password is correct
        if (user && (await user.matchPassword(password))) {
            
            // 1. Generate a random 6-digit OTP
            const otp = Math.floor(100000 + Math.random() * 900000).toString();
            
            // 2. Set expiry (10 minutes from now)
            const expires = new Date(Date.now() + 10 * 60 * 1000);

            // 3. Save to Postgres
            user.otp = otp;
            user.otpExpires = expires;
            await user.save();

            // 4. LOG TO TERMINAL (Since we aren't using an Email API yet)
            console.log(`\n--------------------------`);
            console.log(`🔑 LOGIN OTP FOR: ${email}`);
            console.log(`CODE: ${otp}`);
            console.log(`--------------------------\n`);

            return res.status(200).json({ 
                message: "Step 1 Successful: OTP generated. Check terminal." 
            });
        }

        res.status(401).json({ message: "Invalid email or password" });
    } catch (error) {
        res.status(500).json({ message: "Server error", error: error.message });
    }
});

// STEP 2: VERIFY OTP (Identity Confirmation & JWT Issuance)
router.post('/verify-otp', async (req, res) => {
    try {
        const { email, otp } = req.body;
        const user = await User.findOne({ where: { email, otp } });

        // Check if OTP matches and is not expired
        if (user && user.otpExpires > new Date()) {
            
            // 1. Clear OTP so it can't be reused
            user.otp = null;
            user.otpExpires = null;
            await user.save();

            // 2. Generate the final JWT for the session
            const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1d' });

            res.status(200).json({
                message: "Login verified!",
                token: token
            });
        } else {
            res.status(400).json({ message: "Invalid or expired OTP" });
        }
    } catch (error) {
        res.status(500).json({ message: "Verification error", error: error.message });
    }
});

module.exports = router;