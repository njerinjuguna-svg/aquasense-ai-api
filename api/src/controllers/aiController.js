exports.analyzeWaterQuality = async (req, res) => {
    try {
        const { ph, turbidity, temperature } = req.body;

        // Simple AI Logic: Scoring based on thresholds
        let score = 100;
        let recommendations = [];

        if (ph < 6.5 || ph > 8.5) {
            score -= 30;
            recommendations.push("pH levels are outside the drinkable range (6.5-8.5).");
        }
        if (turbidity > 5) {
            score -= 40;
            recommendations.push("High turbidity detected. Water may be cloudy or contaminated.");
        }
        if (temperature > 25) {
            score -= 10;
            recommendations.push("High temperature can encourage bacterial growth.");
        }

        const status = score > 70 ? "Safe" : score > 40 ? "Caution" : "Unsafe";

        res.status(200).json({
            status,
            safetyScore: `${score}%`,
            analysis: recommendations.length > 0 ? recommendations : ["Water quality looks excellent."],
            timestamp: new Date()
        });
    } catch (error) {
        res.status(500).json({ message: "AI Analysis failed", error: error.message });
    }
};