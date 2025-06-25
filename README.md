# ScheduleMe - Flutter Schedule Management App

A powerful and intuitive Flutter application for managing daily schedules and routines with AI-powered features.

## Features

### 📅 Dual Interface Design
- **Schedules**: Complete routine management with weekly calendar view
- **ScduleMe**: Identical interface for experimental features
- **AI Assistant (A)**: Advanced AI-powered scheduling features

### 🎯 Core Functionality
- **Weekly Calendar View**: Interactive calendar with routine indicators
- **Routine Management**: Create, edit, and delete daily routines
- **Time Tracking**: Start/end times with duration calculations
- **Weekly Scheduling**: Assign routines to specific days of the week
- **Dark/Light Theme**: Automatic theme switching support

### 🤖 AI Features (Coming Soon)
- **Smart Schedule Analysis**: AI-powered routine analysis
- **Intelligent Suggestions**: Personalized scheduling recommendations
- **Time Optimization**: Automatic gap detection and optimization
- **Habit Formation**: AI-guided habit building
- **Predictive Planning**: Pattern-based future scheduling

### 🎨 Design Highlights
- **Modern UI**: Clean, iOS-inspired design language
- **Smooth Animations**: Fluid transitions and interactions
- **Responsive Layout**: Optimized for different screen sizes
- **Consistent Theming**: Professional color schemes and typography

## Tech Stack
- **Framework**: Flutter
- **Database**: SQLite (via sqflite)
- **Calendar**: table_calendar package
- **State Management**: Built-in setState
- **Architecture**: Clean, modular code structure

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Device/Emulator for testing

### Installation
1. Clone the repository:
```bash
git clone https://github.com/yourusername/ScheduleMe-Flutter-App.git
cd ScheduleMe-Flutter-App
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure
```
lib/
├── main.dart                 # Main app entry point with dual bottom sheets
├── schedule_section.dart     # Daily schedule timeline widget
├── theme_provider.dart       # Theme management
└── database_helper.dart      # SQLite database operations
```

## Screenshots
<!-- Add screenshots of your app here -->

## Roadmap
- [ ] Backend integration for AI features
- [ ] User authentication
- [ ] Cloud synchronization
- [ ] Advanced analytics
- [ ] Widget customization
- [ ] Export/Import functionality

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Support
For support, email your-email@example.com or create an issue in this repository.
