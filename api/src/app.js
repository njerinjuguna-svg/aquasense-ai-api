const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const sequelize = require('./config/database');
require('dotenv').config();

const app = express();

// MIDDLEWARE
app.use(cors());
app.use(helmet()); 
app.use(express.json());

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, 
  max: 1000,
  message: "Too many requests..."
});
app.use(limiter);

// 1. IMPORT MODELS
const User = require('./models/model users');
const Sensor = require('./models/model sensor');
const Reading = require('./models/model reading');
const Alert = require('./models/model alerts');

// 2. DEFINE RELATIONSHIPS
User.hasMany(Sensor, { foreignKey: 'UserId', onDelete: 'CASCADE' });
Sensor.belongsTo(User, { foreignKey: 'UserId' });
Sensor.hasMany(Reading, { foreignKey: 'SensorId', onDelete: 'CASCADE' });
Reading.belongsTo(Sensor, { foreignKey: 'SensorId' });
Reading.hasOne(Alert, { foreignKey: 'ReadingId', onDelete: 'CASCADE' });
Alert.belongsTo(Reading, { foreignKey: 'ReadingId' });

// 3. REGISTER ROUTES
// Using try/catch or simple requires—ensure these files EXIST in your routes folder
app.use('/api/users', require('./routes/routes users'));
app.use('/api/sensors', require('./routes/routes sensors'));
app.use('/api/readings', require('./routes/routes readings'));
app.use('/api/alerts', require('./routes/routes alert'));

// Change './routes/ai' to './routes/routes ai'
app.use('/api/ai', require('./routes/routes ai'));

// 4. START SERVER
async function startServer() {
  try {
    await sequelize.authenticate();
    console.log('✅ Database connected successfully');
    
 // Set it back so it doesn't wipe your data on the next restart!
sequelize.sync()
    console.log('✅ All database tables synchronized.');

    const PORT = process.env.PORT || 5000; 
    app.listen(PORT, () => {
      console.log(`🚀 AquaSense API is running on port ${PORT}`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
  }
}

startServer();