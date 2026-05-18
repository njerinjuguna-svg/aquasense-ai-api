const express = require('express');
const router = express.Router();
const sensorController = require('../controllers/sensorController');
const protect  = require('../middleware/authMiddleware');

console.log("Is protect a function?", typeof protect);
console.log("Is registerSensor a function?", typeof sensorController.registerSensor);
// Protected: Register a new hardware sensor
router.post('/register', protect, sensorController.registerSensor);

// Protected: Get all sensors belonging to a specific user
router.get('/user/:userId', protect, sensorController.getMySensors);

// Protected: Get 24-hour analytics for a specific sensor
router.get('/analytics/:sensorId', protect, sensorController.getSensorAnalytics);

module.exports = router;