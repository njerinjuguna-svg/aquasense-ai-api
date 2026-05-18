const Reading = require('../models/model reading');
const Sensor = require('../models/model sensor');
const Alert = require('../models/model alerts');

const uploadReading = async (req, res) => {
    try {
        const { api_key, ph, turbidity, temperature, tds, dissolved_oxygen } = req.body;

        const sensor = await Sensor.findOne({ where: { api_key } });

        if (!sensor) {
            return res.status(401).json({
                message: "Invalid API Key"
            });
        }

        let phMsg = "";

        if (ph < 6.5) {
            phMsg = "LOW, The water is acidic";
        } else if (ph <= 8.5) {
            phMsg = "OPTIMUM, Water is safe";
        } else {
            phMsg = "HIGH, Water is alkaline";
        }

        const newReading = await Reading.create({
            sensorId: sensor.id,
            ph,
            turbidity,
            temperature,
            tds,
            dissolved_oxygen
        });

        if (ph < 6.5 || ph > 8.5 || turbidity > 5) {
            await Alert.create({
                ReadingId: newReading.id,
                severity: "WARNING",
                message: `Issue detected with pH ${ph}`
            });
        }

        res.status(201).json({
            message: "Data analyzed and recorded",
            PH: {
                value: ph,
                result: phMsg
            }
        });

    } catch (error) {
        res.status(500).json({
            message: "Error",
            error: error.message
        });
    }
};

module.exports = {
    uploadReading
};