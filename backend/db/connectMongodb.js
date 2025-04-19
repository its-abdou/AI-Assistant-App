import mongoose from "mongoose";

const MONGO_URI = process.env.MONGO_URI;

const connectMongodb = async () => {
  try {
    const conn = await mongoose.connect(MONGO_URI);
    console.log("Mongodb connected " + conn.connection.host);
  } catch (error) {
    console.error("Error connecting to database: " + error.message);
    process.exit(1);
  }
};

export default connectMongodb;
