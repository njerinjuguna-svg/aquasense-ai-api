console.log('🔥 routes alert.js LOADED');
const express = require('express');
const router = express.Router();
const alertController = require('../controllers/alertController');
const protect = require('../middleware/authMiddleware'); // ✅ FIXED: Removed curly braces {}

console.log("ALERTS FILE CHECK:");
console.log("Is protect a function?", typeof protect);
console.log("Is alertController defined?", typeof alertController);
console.log("Is getUserAlerts a function?", typeof alertController?.getUserAlerts);
console.log("Is resolveAlert a function?", typeof alertController?.resolveAlert);

// Get alerts for a user
router.get('/user/:userId', protect, alertController.getUserAlerts);

// Resolve an alert
router.patch('/resolve/:id', protect, alertController.resolveAlert);

module.exports = router;