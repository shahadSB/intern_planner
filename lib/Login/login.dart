import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intern_planner/Login/resetPassword.dart';
import 'package:intern_planner/Login/signup.dart';
import 'package:intern_planner/Supervisor/superHomepage.dart';
import 'package:intern_planner/Trainee/traineeHomepage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // Key to identify the form and manage its state
  final _emailController = TextEditingController(); // Controller for managing email input
  final _passwordController = TextEditingController(); // Controller for managing password input
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Authentication instance
  String? _errorMessage; // Variable to store error messages

  // Function to handle user login
  Future<void> _login() async {
    // Validate form inputs
    if (_formKey.currentState!.validate()) { 
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Navigation logic based on user role
        if (_auth.currentUser!.email!.endsWith('@tamimimarkets.com')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CalendarPage()), // Navigate to Supervisor's calendar page
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TraineeHomepage()), // Navigate to Trainee's homepage
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle Firebase authentication errors
        print('Firebase Authentication Error: $e');
        setState(() {
          _errorMessage = 'Email or Password is incorrect'; // Display error message
        });
      } catch (e) {
        // Handle other errors
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('resources/bg.jpg'), // Path to background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(200, 255, 255, 255), 
                borderRadius: BorderRadius.circular(37.0), 
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: Offset(0, 4), // Shadow position
                  ),
                ],
              ),
              child: Form(
                key: _formKey, // Associate form key with this form
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email *',
                        labelStyle: TextStyle(color: Color.fromARGB(255, 77, 77, 77)),
                        hintText: 'Enter your Email',
                        hintStyle: TextStyle(color: Color.fromARGB(255, 77, 77, 77)),
                        fillColor: Colors.white,
                        filled: true,
                        // border style when enabled
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)), 
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        // border style when focused
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 113, 126, 112)), 
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        // border style when there's an error
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 195, 77, 69)), 
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        // border style when there's an error
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 195, 77, 69)),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 270.0, // Set the maximum width
                          minHeight: 45.0, // Set the minimum height
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Email'; // Error message for empty email field
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true, // Hide password text
                      decoration: InputDecoration(
                        labelText: 'Password *',
                        labelStyle: TextStyle(color: Color.fromARGB(255, 77, 77, 77)),
                        hintText: 'Enter your Password',
                        hintStyle: TextStyle(color: Color.fromARGB(255, 77, 77, 77)),
                        fillColor: Colors.white,
                        filled: true,
                        // border style when enabled
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)), 
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        // border style when focused
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 113, 126, 112)),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        // border style when there's an error
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 195, 77, 69)),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        // border style when there's an error
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 195, 77, 69)), 
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 270.0, // Set the maximum width
                          minHeight: 45.0, // Set the minimum height
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password'; // Error message for empty password field
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null) // Display the error message if it's not null
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _login,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Login button style
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(270.0, 40.0),
                        backgroundColor: Color.fromARGB(255, 217, 86, 74),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ResetPasswordPage()), // Navigate to reset password page
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color.fromARGB(255, 217, 86, 74),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()), // Navigate to sign up page
                        );
                      },
                      child: Text(
                        'Create new account',
                        style: TextStyle(
                          color: Color.fromARGB(255, 217, 86, 74),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
