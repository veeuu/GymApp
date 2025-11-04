# Arjun Gym App 🏋️‍♂️

A comprehensive Flutter app for gym trainers to manage clients, workout plans, diet plans, and track progress. Professional fitness management system designed for modern gym trainers.

## Features

### ✅ Completed (Phase 1-3)
- **Authentication System**
  - Trainer login/signup with email/password
  - Password reset functionality
  - Secure Firebase Authentication

- **Client Management**
  - Add/Edit/Delete clients
  - Search and filter clients by goal or name
  - Client details with overview, plans, and progress tabs
  - Store client information (name, phone, email, gender, goal, DOB)

- **Dashboard**
  - Quick stats overview
  - Navigation between different sections
  - Quick action buttons

### 🚧 Coming Soon
- Workout Plans Creation & Management
- Diet Plans Creation & Management
- Plan Assignment to Clients
- Progress Tracking with Photos
- Advanced Analytics

## Tech Stack
- **Frontend**: Flutter
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Provider
- **UI**: Material Design

## Setup Instructions

1. **Install Flutter SDK**
   - Follow the official Flutter installation guide
   - Ensure Flutter is added to your PATH

2. **Clone and Setup Project**
   ```bash
   git clone <repository-url>
   cd gym_trainer_app
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at https://console.firebase.google.com
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Enable Storage
   - Run `flutterfire configure` to connect your Flutter app

4. **Run the App**
   ```bash
   flutter run
   ```

## Project Structure
```
lib/
├── models/           # Data models (Client, Trainer, etc.)
├── services/         # Firebase services and business logic
├── screens/          # UI screens organized by feature
│   ├── auth/         # Login/Signup screens
│   ├── clients/      # Client management screens
│   ├── dashboard/    # Dashboard and home screens
│   └── plans/        # Workout and diet plan screens
├── utils/            # Utilities and themes
└── main.dart         # App entry point
```

## Firebase Collections

### Users Collection
```json
{
  "uid": "trainer_uid",
  "name": "Trainer Name",
  "email": "trainer@email.com",
  "role": "trainer",
  "createdAt": "timestamp"
}
```

### Clients Collection
```json
{
  "name": "Client Name",
  "phone": "1234567890",
  "email": "client@email.com",
  "gender": "Male/Female",
  "goal": "Weight Loss",
  "dob": "timestamp",
  "trainerId": "trainer_uid",
  "createdAt": "timestamp",
  "lastUpdated": "timestamp"
}
```

## Contributing
This is a work in progress. The basic client management system is complete and functional. Upcoming features will be added in phases as outlined in the original plan.