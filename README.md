# CHPS Mamacare

A Flutter application developed as a Level 300 mini-project (August 2025) to support Community-based Health Planning and Services (CHPS).

## 🚀 Features

- **User authentication** with Firebase
- **Health record management** (births, immunisations, visits)
- **Photo uploads** and multimedia support
- **Offline-first design** with local storage
- **Responsive UI** for Android, iOS, web and desktop
- Modular structure: models, screens, services, widgets

## 🗂 Project Structure

```
lib/
  firebase_options.dart
  main.dart
  models/
  screens/
  services/
  utils/
  widgets/
test/
web/
android/… ios/… windows/…
```

## 🛠 Setup

1. Clone the repo.
2. Run `flutter pub get`.
3. Configure Firebase (use `google-services.json` and `GoogleService-Info.plist`).
4. Launch with `flutter run` on your target platform.

## 📝 Notes

Built as part of a course requirement; demonstrates Flutter, Firebase, and cross-platform development fundamentals.


## Environment Keys

Below are the Supabase keys required for this project.  


```env
SUPABASE_URL=https://waxqtylfloptvclkmdvh.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndheHF0eWxmbG9wdHZjbGttZHZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyMDUyMDcsImV4cCI6MjA3MDc4MTIwN30.w4lla44Y5Qhre-htNI3ClCE9R884bkGzegoz_sUHuTc
