import mongoose from "mongoose";
import validator from "validator";
import bcrypt from "bcrypt";
import { AuthError, ValidationError } from "../utils/error.js";

const UserSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
  },
  // For local authentication – store hashed password.
  password: {
    type: String,
    // Not required if the user uses OAuth only
  },

  // OAuth provider fields (Google in this case)
  googleId: {
    type: String,
    unique: true,
    sparse: true, // Ensures uniqueness only when provided
  },
  fullName: {
    type: String,
    trim: true,
  },
  profileImage: {
    type: String,
    default: "",
  },

  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

// Auto update updatedAt on save
UserSchema.pre("save", function (next) {
  this.updatedAt = Date.now();
  next();
});

UserSchema.statics.signup = async function (email, password, fullName) {
  // Validate inputs
  if (!fullName || !email || !password) {
    throw new ValidationError("Please fill all fields");
  }

  if (!validator.isEmail(email)) {
    throw new ValidationError("Please enter a valid email");
  }

  if (!validator.isStrongPassword(password)) {
    throw new ValidationError("Please enter a strong password");
  }

  // Check for existing user
  const existingUser = await this.findOne({ email });
  if (existingUser) {
    throw new AuthError("User already exists");
  }

  // Hash password
  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash(password, salt);

  const user = await this.create({
    fullName,
    email,
    password: hashedPassword,
  });

  return user;
};

const User = mongoose.model("User", UserSchema);

export default User;
