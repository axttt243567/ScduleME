# ScheduleMe - AI-Powered Schedule Management App

A powerful Flutter application that uses advanced AI to extract schedules from images and manage your daily routines efficiently.

## � **IMPORTANT: API Key Setup Required**

**Before running the app, you MUST set up your Google Gemini API key:**

### 1. Get Your API Key
- Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
- Create a new API key for Gemini API
- Copy the generated key

### 2. Create Environment File
Create a `.env` file in the root directory and add:
```
GEMINI_API_KEY=your_actual_api_key_here
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run the App
```bash
flutter run
```

⚠️ **SECURITY WARNING**: Never commit API keys to Git! The `.env` file is already in `.gitignore`.

## �🚀 Features

### 📱 **Core Functionality**
- **Weekly Calendar View** - Interactive calendar with routine indicators
- **Smart Schedule Management** - Add, edit, and delete routines with ease
- **Daily Timeline** - Visual timeline showing your day's activities
- **Dark/Light Theme** - Automatic theme switching support

### 🤖 **AI-Powered Schedule Extraction**
- **Gemini-2.5-pro Integration** - Advanced AI model for complex image analysis
- **Large File Support** - Handles high-resolution images up to 10MB+
- **Mass Schedule Creation** - Extract 50-300+ routines from a single image
- **Detailed Recognition** - Captures titles, descriptions, times, and locations
- **Multiple Format Support** - Works with screenshots, camera photos, handwritten notes

### 📊 **Smart Features**
- **Automatic Time Conversion** - Converts all time formats to 24-hour format
- **Intelligent Day Assignment** - Smart scheduling across weekdays/weekends
- **Room & Instructor Details** - Extracts complete schedule information
- **Progress Tracking** - Real-time feedback during AI processing

## 🛠 **Technology Stack**

- **Framework**: Flutter (Dart)
- **AI Model**: Google Gemini-2.5-pro
- **Database**: SQLite (sqflite)
- **Image Processing**: image_picker
- **HTTP Requests**: http package
- **Calendar**: table_calendar
- **State Management**: Provider pattern

## 📋 **Prerequisites**

- Flutter SDK (>=3.0.0)
- Dart SDK (>=2.17.0)
- Android Studio / VS Code
- Android SDK / Xcode (for mobile development)
- Google AI API Key (Gemini)

## 🚀 **Installation**

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/scdulemee.git
   cd scdulemee
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up API Keys**
   - Get your Gemini API key from [Google AI Studio](https://ai.google.dev/)
   - Replace `YOUR_API_KEY` in `lib/main.dart` with your actual API key
   
   ```dart
   const String apiKey = 'YOUR_GEMINI_API_KEY_HERE';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 **Supported Platforms**

- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🎯 **How to Use**

### **Basic Schedule Management**
1. Open the app and view your weekly calendar
2. Tap "Schedules" to manage existing routines
3. Use "ScduleMe" for AI-powered features

### **AI Schedule Extraction**
1. Tap "ScduleMe" → "AI" button
2. Choose "Take Photo" or "Choose Image"
3. Select your schedule image (timetable, screenshot, etc.)
4. Wait for AI processing (30-60 seconds)
5. Review and manage extracted routines

### **Supported Schedule Types**
- 📚 University/School timetables
- 💼 Work schedules and meeting calendars
- 🏥 Medical appointments
- 🏃‍♂️ Sports and fitness schedules
- 📅 Conference programs
- 📝 Personal planners

## 🤝 **Contributing**

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 **License**

This project is licensed under the MIT License.

## 🔮 **Future Features**

- [ ] Offline schedule management
- [ ] Calendar integration (Google Calendar, Outlook)
- [ ] Voice input for quick schedule creation
- [ ] Team collaboration features
- [ ] Smart notifications and reminders

---

**Made with ❤️ using Flutter and AI**
