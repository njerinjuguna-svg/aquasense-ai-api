const express = require('express');
const router = express.Router();
// IMPORTANT: Make sure this name matches your filename (readingController.js)
const readingController = require('../controllers/readingController'); 
const  protect  = require('../middleware/authMiddleware'); // 1. Import the security guard

console.log("READINGS FILE CHECK:");
console.log("Is protect a function?", typeof protect);
console.log("Is readingController defined?", typeof readingController);
// Add a check for whatever your controller functions are named here, for example:
console.log("Is postReading a function?", typeof readingController?.postReading); 
console.log("Is getReadings a function?", typeof readingController?.getReadings);
// This matches the /submit part of your Postman URL
// Change '/submit' to '/upload'
router.post('/upload', protect, readingController.uploadReading);
module.exports = router; // <--- Without this, you get a 404