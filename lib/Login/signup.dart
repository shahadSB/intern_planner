import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intern_planner/Login/login.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Form key for validating the form
  final _formKey = GlobalKey<FormState>();

  // Controllers for handling text input fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Variable to store the selected date of birth
  DateTime? _dateOfBirth;

  // Firebase authentication and Firestore instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _nameController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    _dateOfBirthController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Method to handle date selection
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    // Calculate the date 18 years ago from now
    final DateTime eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);

    // Show date picker dialog
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: eighteenYearsAgo, // Initial date set to 18 years ago
      firstDate: DateTime(1900), // Earliest date allowed
      lastDate: now, // Latest date allowed
      selectableDayPredicate: (DateTime date) {
        // Allow only dates before or exactly 18 years ago
        return date.isBefore(eighteenYearsAgo) || date.isAtSameMomentAs(eighteenYearsAgo);
      },
    );

    // Update state with the selected date
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
        _dateOfBirthController.text = "${picked.toLocal()}".split(' ')[0]; // Format the date as a string
      });
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Update the display name
        await userCredential.user?.updateDisplayName(_nameController.text.trim());

        // Store additional user information in Firestore
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'employeeId': _employeeIdController.text.trim(),
          'dateOfBirth': _dateOfBirth?.toIso8601String(),
        });

        // Navigate to the login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } 
      // Error handling
      on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('The password provided is too weak.'),
            ),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('The account already exists for that email.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred. Please try again.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'),
          ),
        );
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
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          color: Color.fromARGB(255, 0, 0, 0),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        SizedBox(width: 48.0),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    _buildTextField(
                      controller: _nameController,
                      labelText: 'Name *',
                      hintText: 'Enter your Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name'; // Validation for name field
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    _buildTextField(
                      controller: _emailController,
                      labelText: 'Email *',
                      hintText: 'Enter your Email',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email'; // Validation for email field
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    _buildTextField(
                      controller: _employeeIdController,
                      labelText: 'Employee ID *',
                      hintText: 'Enter your Employee ID',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your employee ID'; // Validation for employee ID field
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    _buildDateField(
                      controller: _dateOfBirthController,
                      labelText: 'Date of Birth *',
                      hintText: 'Select your Date of Birth',
                      validator: (value) {
                        if (_dateOfBirth == null) {
                          return 'Please enter your date of birth'; // Validation for date of birth field
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    _buildPasswordField(
                      controller: _passwordController,
                      labelText: 'Password *',
                      hintText: 'Enter your Password',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password'; // Validation for password field
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password *',
                      hintText: 'Enter your Confirm Password',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password'; // Validation for confirm password field
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: _signUp,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        child: Text(
                          'Create',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(270.0, 40.0),
                        backgroundColor: Color.fromARGB(255, 217, 86, 74),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Color.fromARGB(255, 77, 77, 77)),
        hintText: hintText,
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
      ),
      validator: validator,
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required FormFieldValidator<String> validator,
  }) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(color: Color.fromARGB(255, 77, 77, 77)),
            hintText: hintText,
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
          ),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Color.fromARGB(255, 77, 77, 77)),
        hintText: hintText,
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
      ),
      validator: validator,
    );
  }
}
