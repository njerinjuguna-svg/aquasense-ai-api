console.log('🔥 routes ai.js LOADED');
const express = require('express');
const router = express.Router();
const aiController = require('../controllers/aiController'); // Handled by your aiController
const protect = require('../middleware/authMiddleware');

console.log("AI ROUTES FILE CHECK:");
console.log("Is protect a function?", typeof protect);
console.log("Is aiController defined?", typeof aiController);
console.log("Is analyzeWaterQuality a function?", typeof aiController?.analyzeWaterQuality);

// Route for water quality analysis
router.post('/analyze', protect, aiController.analyzeWaterQuality);

module.exports = router;