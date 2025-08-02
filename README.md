# Attendance Tracker App

A comprehensive Flutter application for tracking student and teacher attendance with role-based access control.

## Features

### 🔐 Authentication & Role Management
- **Role-based login**: Students and Teachers have separate authentication flows
- **Firebase Authentication**: Secure user authentication with email/password
- **Role verification**: Ensures users can only access features appropriate for their role

### 👨‍🎓 Student Features
- **Self-Tracking Tab**: Students can track their own attendance for personal subjects
- **Teacher-Marked Tab**: View attendance marked by teachers for enrolled subjects
- **Subject Management**: Add, track, and manage personal subjects
- **Attendance Statistics**: View present/absent counts and attendance percentages

### 👨‍🏫 Teacher Features
- **Personal Classes Tab**: Track attendance for their own classes
- **Subject Management Tab**: Create and manage teaching subjects
- **Student Enrollment**: Register students for specific subjects using email
- **Attendance Marking**: Mark attendance for enrolled students in specific subjects
- **Student Management**: View all registered students

### 🎨 Modern UI/UX
- **Tabbed Interface**: Clean, organized navigation with role-specific tabs
- **Material Design**: Modern, consistent design language throughout
- **Real-time Updates**: Live data synchronization with Firebase
- **Responsive Design**: Works across different screen sizes
- **Loading States**: Smooth loading indicators and error handling

## Technical Architecture

### 🔥 Firebase Integration
- **Firebase Authentication**: User sign-up and sign-in
- **Cloud Firestore**: Real-time database for attendance data
- **Security Rules**: Role-based access control for data protection

### 📱 Flutter Features
- **StreamBuilder**: Real-time data updates
- **State Management**: Efficient widget state management
- **Modal Bottom Sheets**: Modern input interfaces
- **Custom Widgets**: Reusable UI components

## Database Structure

### Collections
- **users**: User profiles with roles (student/teacher)
- **teacherSubjects**: Teacher-created subjects with enrollment
- **teacherAttendance**: Attendance records marked by teachers
- **enrolledStudents**: Student enrollments in teacher subjects

### Security Rules
- Teachers can manage their own subjects and enrollments
- Students can view their enrolled subjects and attendance
- Role-based access control for all operations

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Firebase project with Authentication and Firestore enabled
- Android Studio / VS Code

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase:
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update Firebase configuration in `lib/firebase_options.dart`
   - Deploy Firestore security rules from `firestore_rules.txt`

### Running the App
```bash
flutter run
```

## Usage Guide

### For Students
1. **Sign up** as a student with email and password
2. **Self-Tracking Tab**: Add subjects and mark your own attendance
3. **Teacher-Marked Tab**: View attendance marked by teachers for enrolled subjects

### For Teachers
1. **Sign up** as a teacher with email and password
2. **Personal Classes Tab**: Track attendance for your own classes
3. **Subjects Tab**: 
   - Create teaching subjects
   - Enroll students using their registered email
   - Mark attendance for enrolled students
4. **Students Tab**: View all registered students

## Key Features Explained

### Subject Enrollment System
- Teachers create subjects in the "Subjects" tab
- Students must be registered first before enrollment
- Teachers enroll students using their email address
- Only enrolled students appear in attendance marking

### Attendance Tracking
- **Self-tracking**: Students track their own attendance
- **Teacher-marked**: Teachers mark attendance for enrolled students
- **Real-time updates**: Changes appear immediately across devices
- **Historical data**: All attendance records are preserved

### Security & Privacy
- Role-based access control
- Students can only see their own data
- Teachers can only manage their own subjects
- Secure Firebase authentication and authorization

## Troubleshooting

### Common Issues
1. **Login errors**: Ensure users are registered with correct roles
2. **Firebase connection**: Check internet connection and Firebase configuration
3. **Permission errors**: Verify Firestore security rules are deployed

### Debug Features
- Use the bug icon in the role selection page to test Firebase connection
- Check console logs for detailed error messages
- Verify user roles in Firebase Authentication console

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
