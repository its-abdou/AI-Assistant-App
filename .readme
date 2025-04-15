# ✨ AI Assistant App

A Flutter-based AI Assistant similar to Microsoft Copilot. This app allows users to interact with AI via chat, with text understanding powered by OpenAI. It includes authentication, chat history management, and an Express backend.

## 📱 Features

- 🔐 User Authentication (Login & Signup)
- 💬 AI Chat with OpenAI API
- 🕓 Persistent Chat History (view past conversations)
- ⚙️ Flutter Frontend + Express Backend
- 📦 State Management with Riverpod

## 🚀 Tech Stack

### Frontend (Flutter)

- Dart
- Flutter SDK
- HTTP & Riverpod

### Backend (Node.js & Express)

- Node.js
- Express.js
- JWT Authentication
- MongoDB
- OpenAI API Integration

## 🛠️ Setup Instructions

### Prerequisites

- Flutter SDK installed
- Node.js & npm installed
- OpenAI API key
- MongoDB Atlas

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name
```

### 2. Backend Setup

```bash
cd backend
npm install
# Create .env file
touch .env
# Add your environment variables
```

#### `.env` Example

```
PORT=5000
MONGO_URI=your_mongo_uri
OPENAI_API_KEY=your_openai_key
JWT_SECRET=your_jwt_secret
```

```bash
npm start
```

### 3. Frontend Setup

```bash
cd ../flutter_frontend
flutter pub get
flutter run
```

## 📂 Project Structure

```
/backend
  └── controllers/
  └── routes/
  └── utils/
  └── server.js

/flutter_frontend
  └── lib/
      └── models/
      └── providers/
      └── screens/
      └── services/
      └── widgets/
```

## 🔐 Authentication Flow

- JWT tokens for secure login
- Token stored locally in Flutter app (e.g., using `shared_preferences`)
- Protected endpoints on backend

## 🧠 AI Integration

- Messages are sent to OpenAI's API (GPT-4 or GPT-3.5)
- Responses returned and saved with metadata (timestamp, user ID, etc.)

## 📌 Future Improvements

- ✅ Add voice input
- ✅ Add image upload (for future OpenAI vision support)
- 📲 Deploy to Play Store
- ☁️ Deploy backend on Render / Railway / Vercel

## 📃 License

MIT License — feel free to fork, contribute, and build upon!

---

> Made with ❤️ using Flutter, Express, and OpenAI
