import User from "../models/user.model.js";

import { generateToken } from "../utils/generateToken.js";

class authController {
  static async signup(req, res) {
    try {
      const { fullName, email, password } = req.body;

      const newUser = await User.signup(email, password, fullName);

      const token = generateToken(newUser._id);

      res.status(201).json({
        _id: newUser._id,
        fullName: newUser.fullName,
        email: newUser.email,
        profileImage: newUser.profileImage,
        createdAt: newUser.createdAt,
        updatedAt: newUser.updatedAt,
        message: "User created successfully",
        token,
      });
    } catch (error) {
      if (error.name === "ValidationError" || error.name === "AuthError") {
        return res.status(400).json({ message: error.message });
      }

      // Handle Server errors
      res
        .status(500)
        .json({ message: "Error creating user", error: error.message });
    }
  }

  static async login(req, res) {
    try {
      const { email, password } = req.body;

      const user = await User.login(email, password);

      const token = generateToken(user._id);

      res.status(200).json({
        _id: user._id,
        fullName: user.fullName,
        email: user.email,
        profileImage: user.profileImage,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        message: "User logged in successfully",
        token,
      });
    } catch (error) {
      if (error.name === "ValidationError" || error.name === "AuthError") {
        return res.status(400).json({ message: error.message });
      }
      // Handle Server errors
      res.status(500).json({ message: "Error logging in", error });
    }
  }

  /*static async googleAuth(req, res) {
    try {

    } catch (error) {
      res
        .status(500)
        .json({ message: "Error during Google authentication", error });
    }
  }
  static async googleCallback(req, res) {
    try {
    } catch (error) {
      res.status(500).json({ message: "Error during Google callback", error });
    }
  }*/
}

export default authController;
