import User from "../models/user.model.js";

class userController {
  static getProfile = async (req, res) => {
    try {
      const user = await User.findById(req.user._id).select("-password");
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }
      res.status(200).json(user);
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error.message });
      console.error("Error in  get profile:", error);
    }
  };

  static updateProfile = async (req, res) => {
    try {
      const { fullName, email, profileImage } = req.body;

      const profileFields = {};
      if (fullName) profileFields.fullName = fullName;
      if (email) profileFields.email = email;
      if (profileImage) profileFields.profileImage = profileImage;

      // Update and return the user profile
      const updatedUser = await User.findByIdAndUpdate(
        req.user._id,
        { $set: profileFields },
        { new: true, runValidators: true }
      ).select("-password");

      if (!updatedUser) {
        return res.status(404).json({ message: "User not found" });
      }
      res
        .status(200)
        .json({ message: "Profile updated successfully", updatedUser });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error.message });
      console.error("Error in update profile:", error);
    }
  };
}
export default userController;
