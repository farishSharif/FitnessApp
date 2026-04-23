# 🛡️ New Spartans - Fitness Tracking App

A modern, dark-themed fitness tracking app built with Flutter. Track your workouts, monitor muscle group progress, & stay motivated on your fitness journey.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## ✨ Features

### 🏋️‍♂️ **Workout Management**
- **Workout Dashboard**: View all your scheduled workouts
- **Workout Details**: See exercises, sets, reps, and weights
- **Live Workout Tracking**: Timer, exercise completion, and progress tracking
- **Muscle Group Monitoring**: Track growth and progress for different muscle groups

### 📊 **Progress Tracking**
- **Body Weight Tracking**: Monitor weight changes over time
- **Volume Lifted**: Track total weight lifted in sessions
- **Activity Calendar**: Visual representation of workout frequency
- **Progress Indicators**: Visual progress dots for muscle groups

### 🎨 **Modern UI/UX**
- **Dark Theme**: Sleek black background with white accents
- **Intuitive Navigation**: Bottom navigation with 4 main sections
- **Responsive Design**: Optimized for mobile devices
- **Smooth Animations**: Fluid transitions between screens

### 🏗️ **Technical Features**
- **State Management**: Provider pattern for efficient state handling
- **Clean Architecture**: Well-organized code structure
- **Comprehensive Testing**: Unit and widget tests included
- **Cross-Platform**: Works on Android, iOS, Web, Windows, and macOS

## 📱 Screenshots
<p align="center">
  <img src="IMG_6236.JPG" width="28%">
  <img src="IMG_6237.JPG" width="28%">
  <img src="IMG_6235.JPG" width="28%">
</p>

### Main Dashboard
- Workout cards with scheduled days
- Body weight and volume tracking
- Activity calendar visualization

### Workout Detail
- Exercise list with sets and reps
- Muscle group progress indicators
- Start workout functionality

### Workout in Progress
- Live timer
- Exercise completion tracking
- Next exercise preview

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/farish-sharif/new_spartans.git
   cd new_spartans
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate app icons**
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme/
│   └── app_theme.dart          # Dark theme configuration
├── models/
│   └── workout.dart            # Data models
├── providers/
│   └── workout_provider.dart   # State management
├── screens/
│   ├── main_navigation_screen.dart
│   ├── workouts_screen.dart
│   ├── workout_detail_screen.dart
│   ├── workout_in_progress_screen.dart
│   ├── calendar_screen.dart
│   ├── stats_screen.dart
│   └── chat_screen.dart
└── widgets/
    ├── workout_card.dart
    ├── stats_card.dart
    ├── calendar_card.dart
    ├── muscle_group_card.dart
    ├── exercise_list_item.dart
    ├── exercise_progress_item.dart
    └── add_workout_card.dart
```

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
flutter test

# Run specific test files
flutter test test/widget_test.dart
flutter test test/models/workout_test.dart
flutter test test/providers/workout_provider_test.dart
```

## 📦 Dependencies

- **provider**: State management
- **flutter_animate**: Animations
- **intl**: Date and time utilities
- **flutter_launcher_icons**: App icon generation

## 🎯 Roadmap

- [ ] User authentication
- [ ] Data persistence (SQLite/Firebase)
- [ ] Workout templates
- [ ] Progress charts and analytics
- [ ] Social features
- [ ] Nutrition tracking
- [ ] Wearable device integration

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for UI inspiration
- Fitness community for motivation

## 📞 Contact

 - [@farish_sharif](https://twitter.com/farish_sharif) - farish@example.com

Project Link: [https://github.com/farish-sharif/new_spartans](https://github.com/farish-sharif/new_spartans)

---

⭐ **Star this repository if you found it helpful!**

🛡️ **Happy Training!**
