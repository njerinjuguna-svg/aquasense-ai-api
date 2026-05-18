const { Sequelize } = require("sequelize");
const path = require('path');

// Dynamically locate the .env file
require("dotenv").config({ path: path.join(__dirname, '../../.env') });

// Use DATABASE_URL (from your .env) or fallback to DB_URL
const dbUri = process.env.DATABASE_URL || process.env.DB_URL;

if (!dbUri) {
  console.error("❌ CRITICAL: No database connection string found in .env");
}

const sequelize = new Sequelize(dbUri, {
  dialect: 'postgres',
  protocol: 'postgres',
  logging: false, 
  dialectOptions: {
    ssl: {
      require: true,
      rejectUnauthorized: false // Bypasses self-signed certificate constraints on Render
    }
  }
});

async function connectDB() {
  try {
    await sequelize.authenticate();
    console.log("✅ PostgreSQL Database connected successfully");
    
    // This part is crucial for your OTP rush! 
    // It adds the new columns to your Postgres tables automatically.
    await sequelize.sync({ alter: true }); 
    console.log("✅ Database models synced (OTP columns added)");
    
  } catch (error) {
    console.error("❌ Unable to connect to PostgreSQL database:", error);
  }
}

connectDB();

module.exports = sequelize;