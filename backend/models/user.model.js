import mongoose from "mongoose";

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

export default mongoose.model("User", UserSchema);
