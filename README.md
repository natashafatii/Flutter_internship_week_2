# Week 2 Flutter Internship Project

## Overview
This is a **Flutter-based mobile application** developed during **Week 2 of the internship program**.  
The app demonstrates **basic navigation, state management, and UI elements** in Flutter.  
It includes multiple screens such as **Home**, **Login**, **To-Do**, and **Counter** screens.

---

## Features
- **Login Screen**: User authentication interface (**UI only; no backend implemented yet**).  
- **Home Screen**: Landing page after login.  
- **To-Do Screen**: Simple task management UI to **add and view tasks**.  
- **Counter Screen**: Demonstrates **state management** by incrementing a counter.  
- **Theme Support**: **Custom theme** with primary and secondary colors.  
- **Responsive Design**: UI adapts to different screen sizes using `VisualDensity.adaptivePlatformDensity`.  

---

## Folder Structure
week_2_android/
├── android/ # Android platform-specific code
├── ios/ # iOS platform-specific code
├── lib/ # Main application code
│ ├── models/ # Data models
│ │ └── task.model.dart # Task model class
│ ├── screens/ # Application screens
│ │ ├── home_screen.dart
│ │ ├── to_do_screen.dart
│ │ ├── counter_screen.dart
│ │ └── login_screen.dart
│ └── main.dart # Application entry point
├── build.gradle.kts # Gradle build configuration
├── settings.gradle.kts # Project settings
├── pubspec.yaml # Flutter dependencies
└── README.md # Project documentation---## Installation
## Installation
  - **Clone the repository**
   git clone https://github.com/natashafatii/Flutter_internship_week_2.git
  - **Navigate to the project directory**
    cd Flutter_internship_week_2
  - **Install dependencies**
    flutter pub get
  - **Run the app**
    flutter run
