import 'package:flutter/material.dart';
import 'package:intern_planner/Login/login.dart';

// This WelcomePage widget is the starting point of the app
class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // A boolean variable to track the loading state
  bool _isLoading = false;

  // Function to navigate to the LoginPage
  void _navigateToLogin() {
    setState(() {
      _isLoading = true;
    });

    // Simulate a delay to show the loading GIF
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });

      // Navigate to the LoginPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        // Set the background image for the page
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('resources/bg.jpg'), // Path to background image.
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: _isLoading
          // Show the loading indicator if _isLoading is true
          ? Image.asset(
              'resources/tamimi.gif', 
              width: 50.0,
              height: 50.0,
            )
          // Show the main content if _isLoading is false
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display the Tamimi logo
                Image.asset(
                  'resources/tamimiRed.png',
                  width: 250.0,
                  height: 250.0,
                ),
                SizedBox(height: 25.0),
                
                // Display the "Get started" button
                ElevatedButton(
                  onPressed: _navigateToLogin,
                  child: Text(
                    'Get started',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(220.0, 40.0),
                    backgroundColor: Color.fromARGB(255, 217, 86, 74),
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}