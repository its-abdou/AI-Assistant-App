class authController {
  static async signup(req, res) {
    try {
      res.status(200).json({ message: "Sign Up Successfully" });
    } catch (error) {
      res.status(500).json({ message: "Error creating user", error });
    }
  }

  static async login(req, res) {
    try {
    } catch (error) {
      res.status(500).json({ message: "Error logging in", error });
    }
  }
  static async googleAuth(req, res) {
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
  }
  static async logout(req, res) {
    try {
    } catch (error) {
      res.status(500).json({ message: "Error logging out", error });
    }
  }
}

export default authController;
