const express = require('express');
const router = express.Router();
const sensorController = require('../controllers/sensorController');
const protect = require('../middleware/authMiddleware');
const Sensor = require('../models/model sensor'); // Import model directly for the fallback check

// 1. REGISTER A SENSOR
// URL: POST https://aquasense-ai-api.onrender.com/api/sensors/register
router.post('/register', protect, sensorController.registerSensor);

// 2. GET ALL SENSORS BELONGING TO LOGGED-IN USER (The Missing Route!)
// URL: GET https://aquasense-ai-api.onrender.com/api/sensors/my-sensors
router.get('/my-sensors', protect, async (req, res) => {
    try {
        // Grab the logged-in user's ID attached by your protect middleware
        const userId = req.user?.id || req.User?.id || req.userId || req.UserId;

        if (!userId) {
            return res.status(401).json({ message: "Not authorized, user reference missing from token" });
        }

        // Query the database for all sensors linked to this specific user ID
        const sensors = await Sensor.findAll({ where: { UserId: userId } });
        
        res.status(200).json(sensors);
    } catch (error) {
        res.status(500).json({ message: "Server error fetching user sensors", error: error.message });
    }
});

// 3. GET SENSORS VIA PARAMETER (Kept for backwards compatibility)
// URL: GET https://aquasense-ai-api.onrender.com/api/sensors/user/:userId
router.get('/user/:userId', protect, sensorController.getMySensors);

// 4. GET SENSOR ANALYTICS
// URL: GET https://aquasense-ai-api.onrender.com/api/sensors/analytics/:sensorId
router.get('/analytics/:sensorId', protect, sensorController.getSensorAnalytics);

module.exports = router;