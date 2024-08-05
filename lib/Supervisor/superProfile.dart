import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intern_planner/Login/login.dart';
import 'package:intern_planner/Widgets/supervisorNav.dart';
import 'dart:async';
import 'package:intl/intl.dart';

// This page allows the supervisor to view and update their profile information.

class Supervisorprofile extends StatefulWidget {
  @override
  _SupervisorProfileState createState() => _SupervisorProfileState();
}

class _SupervisorProfileState extends State<Supervisorprofile> {
  final _formKey = GlobalKey<FormState>(); // Key for the form to validate and save state.
  late bool isEditing = false; // Flag to track if the profile is in editing mode.
  late bool isUpdated = false; // Flag to indicate if the profile was successfully updated.
  late double updatedOpacity = 0.0; // Opacity for the "Updated" notification.
  late bool isLoading = true; // Flag to show loading indicator.
  User? currentUser; // The current logged-in user.
  int _selectedIndex = 2; // The selected index for the bottom navigation bar.

  String email = ''; // Supervisor's email.
  String id = ''; // Supervisor's employee ID.
  String name = ''; // Supervisor's name.
  String birthDate = ''; // Supervisor's birth date.

  final TextEditingController birthDateController = TextEditingController(); // Controller for the birth date field.

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // Fetch the current user when the widget initializes.
    _fetchSupervisorDetails(); // Fetch the supervisor details from Firestore.
  }

  // Fetches the current authenticated user from FirebaseAuth.
  Future<void> _getCurrentUser() async {
    try {
      currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print('Current user ID: ${currentUser!.uid}');
        _fetchSupervisorDetails(); // Fetch supervisor details if a user is logged in.
      } else {
        print('No current user found');
      }
    } catch (e) {
      print('Error fetching current user: $e');
    }
  }

  // Fetches the supervisor's details from Firestore and updates the state.
  Future<void> _fetchSupervisorDetails() async {
    try {
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('SupVisUsers')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          email = data['Email'] ?? '';
          id = data['EmployeeID'] ?? '';
          name = data['Name'] ?? '';
          Timestamp timestamp = data['DateOfbirth'] as Timestamp;
          birthDate = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
          birthDateController.text = birthDate; // Set the birth date in the controller.
          isLoading = false; // Stop loading once data is fetched.
        });
      } else {
        print('Supervisor not found');
        setState(() {
          isLoading = false; // Stop loading even if supervisor is not found.
        });
      }
    } catch (e) {
      print('Error fetching supervisor details: $e');
      setState(() {
        isLoading = false; // Stop loading on error.
      });
    }
  }

  // Updates the supervisor's profile data in Firestore.
  Future<void> _updateProfileData() async {
    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('SupVisUsers')
          .doc(currentUser!.uid)
          .update({
        'Email': email,
        'EmployeeID': id,
        'Name': name,
        'DateOfbirth': Timestamp.fromDate(DateFormat('yyyy-MM-dd').parse(birthDate)),
      });
      setState(() {
        isUpdated = true;
        updatedOpacity = 1.0; // Show the "Updated" notification.
      });
      Timer(Duration(seconds: 2), () {
        setState(() {
          updatedOpacity = 0.0; // Hide the "Updated" notification after 2 seconds.
        });
      });
      print('Profile updated');
    } catch (e) {
      print('Error updating profile data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'YourCustomFont',
            color: Color(0xFF31231A),
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to login page on logout.
                );
              });
            },
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 252, 252, 252),
              Color.fromARGB(255, 241, 241, 241),
              Color.fromARGB(255, 227, 225, 225),
            ],
          ),
        ),
        child: Center(
          child: isLoading
              ? Image.asset(
                  'resources/tamimi.gif', 
                  width: 50.0,
                  height: 50.0,
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(25.0),
                  child: Container(
                    padding: EdgeInsets.all(30.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(200, 255, 255, 255),
                      borderRadius: BorderRadius.circular(37.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: Color.fromARGB(255, 187, 217, 164),
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                              SizedBox(height: 12),
                              _buildTextField(
                                label: 'ID',
                                initialValue: id,
                                enabled: isEditing,
                                onChanged: (value) {
                                  setState(() {
                                    id = value;
                                  });
                                },
                              ),
                              SizedBox(height: 12),
                              _buildTextField(
                                label: 'Name',
                                initialValue: name,
                                enabled: isEditing,
                                onChanged: (value) {
                                  setState(() {
                                    name = value;
                                  });
                                },
                              ),
                              SizedBox(height: 12.0),
                              _buildTextField(
                                label: 'Email',
                                initialValue: email,
                                inputType: TextInputType.emailAddress,
                                enabled: isEditing,
                                onChanged: (value) {
                                  setState(() {
                                    email = value;
                                  });
                                },
                              ),
                              SizedBox(height: 12.0),
                              _buildDateField(
                                label: 'Date of Birth',
                                controller: birthDateController,
                                enabled: isEditing,
                              ),
                              SizedBox(height: 12.0),
                              if (isEditing)
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      _formKey.currentState?.save();
                                      setState(() {
                                        isEditing = false;
                                        birthDate = birthDateController.text;
                                      });
                                      _updateProfileData(); // Update profile data on button press.
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                    child: Text(
                                      'Update',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(270.0, 40.0),
                                    backgroundColor: Color.fromARGB(255, 195, 77, 69),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: !isEditing
                              ? IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      isEditing = true; // Enable editing mode.
                                    });
                                  },
                                )
                              : IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      isEditing = false; // Disable editing mode.
                                    });
                                  },
                                ),
                        ),
                        Center(
                          child: AnimatedOpacity(
                            opacity: updatedOpacity,
                            duration: Duration(seconds: 1),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                'Updated!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      bottomNavigationBar: SupervisorNavBar(
        currentIndex: _selectedIndex,
        onItemTapped: (context, index) {
          setState(() {
            _selectedIndex = index;
          });
          onItemTapped(context, index); // Handle bottom navigation item tap
        },
      ),
    );
  }

  // Builds a custom text field for profile input.
  Widget _buildTextField({
    required String label,
    required String initialValue,
    bool isPassword = false,
    bool enabled = true,
    TextInputType inputType = TextInputType.text,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: '$label *',
        labelStyle: TextStyle(color: Color(0xFF31231A)),
        hintText: 'Enter your $label',
        hintStyle: TextStyle(color: const Color.fromARGB(255, 134, 134, 134)),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: const Color.fromARGB(255, 255, 255, 255)), // Custom border color when enabled
          borderRadius: BorderRadius.circular(25.0),
        ),
        enabled: enabled,
        constraints: BoxConstraints(
          minWidth: 270.0,
          minHeight: 45.0,
        ),
      ),
      obscureText: isPassword,
      keyboardType: inputType,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  // Builds a custom date field for date of birth input.
  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled
          ? () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  controller.text = DateFormat('yyyy-MM-dd').format(pickedDate); // Format and set the selected date.
                });
              }
            }
          : null,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontSize: 18.0, color: Color(0xFF31231A)),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: const Color.fromARGB(255, 255, 255, 255)), // Custom border color when enabled
              borderRadius: BorderRadius.circular(25.0),
            ),
            constraints: BoxConstraints(
              minWidth: 270.0,
              minHeight: 45.0,
            ),
            filled: !enabled,
            fillColor: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    );
  }
}
