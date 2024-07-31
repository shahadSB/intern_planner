import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/* 
  This code allows users to reset their password.
  Users must provide their email and name to request a password reset email.
*/

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // Form key to manage form state and validation.
  final _formKey = GlobalKey<FormState>();

  // Text controllers to capture user input.
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  // Firebase Authentication and Firestore instances.
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Variable to store error messages.
  String? _errorMessage;

  /// Sends a password reset email to the user if the provided email and name match.
  Future<void> _sendPasswordResetEmail() async {
    if (_emailController.text.isEmpty || _nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email and name';
      });
      return;
    }
    try {
      var usersQuery = await _firestore.collection('users')
          .where('email', isEqualTo: _emailController.text)
          .where('name', isEqualTo: _nameController.text)
          .get();

      if (usersQuery.docs.isNotEmpty) {
        await _auth.sendPasswordResetEmail(email: _emailController.text);
        setState(() {
          _errorMessage = 'Password reset email sent successfully';
        });
      } else {
        setState(() {
          _errorMessage = 'Email and name do not match';
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen.
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('resources/bg.jpg'), // Background image.
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0), // Padding around the scrollable area.
            child: Container(
              padding: EdgeInsets.all(30.0), // Padding inside the container.
              decoration: BoxDecoration(
                color: Color.fromARGB(200, 255, 255, 255), 
                borderRadius: BorderRadius.circular(37.0), 
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0, 
                    blurRadius: 4,
                    offset: Offset(0, 4), 
                  ),
                ],
              ),
              child: Form(
                key: _formKey, // Form key for validation.
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Main axis size to fit content.
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email *',
                        labelStyle: TextStyle(color: Color.fromARGB(255, 77, 77, 77)), // Label text style.
                        hintText: 'Enter your Email',
                        hintStyle: TextStyle(color: Color.fromARGB(255, 77, 77, 77)), // Hint text style.
                        fillColor: Colors.white, // Fill color of the input field.
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
                          return 'Please enter your Email'; // Validation for email field.
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0), // Space between input fields.
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name *',
                        labelStyle: TextStyle(color: Color.fromARGB(255, 77, 77, 77)), // Label text style.
                        hintText: 'Enter your Name',
                        hintStyle: TextStyle(color: Color.fromARGB(255, 77, 77, 77)), // Hint text style.
                        fillColor: Colors.white, // Fill color of the input field.
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
                          return 'Please enter your Name'; // Validation for name field.
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), // Error message text style.
                        ),
                      ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _sendPasswordResetEmail,
                      child: Text('Send Password Reset Email'),
                      // button style
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(270.0, 40.0), 
                        backgroundColor: Color.fromARGB(255, 217, 86, 74), 
                        foregroundColor: Color.fromARGB(255, 255, 255, 255),
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
