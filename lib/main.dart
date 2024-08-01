/*
  This mobile app was developed by interns at Altamimi Markets using Flutter.
  It serves as a tool for us trainees to manage meetings and tasks assigned by the university (IAU) and Altamimi.

  The app has two user roles: Supervisor and Trainee. 
  Supervisors can add events (meetings, deadlines) to the calendars of their assigned trainees, 
  view the list of trainees under their supervision, and access the details of those trainees. 
  Trainees can easily add their own tasks, and any events added by their supervisors will be displayed.
*/

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intern_planner/welcome.dart';

// Main function to run the app
Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());

  // Initialize Firebase after the app is built
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Firebase.initializeApp(
      // Provide the necessary Firebase configuration options
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBWTXfw9CcTIT3ro0YVsAW3YpJtJ5A5Bnw',
        appId: '1:780596576293:android:5431ce0289ab29be6effcc',
        messagingSenderId: '780596576293',
        projectId: 'coopapp-b584f',
        storageBucket: 'coopapp-b584f.appspot.com',
      )
    );
    print("Firebase initialized");
  });
}

// The main app widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome',
      home: WelcomePage(),
    );
  }
}
