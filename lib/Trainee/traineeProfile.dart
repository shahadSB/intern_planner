import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intern_planner/Database/TraineeDetails.dart';
import 'package:intern_planner/Login/login.dart';
import 'package:intern_planner/Widgets/traineeNav.dart';
import 'package:intl/intl.dart';

// ProfilePage is a StatefulWidget that displays and allows the user to edit their profile details.
// It also handles fetching and updating trainee information from Firestore.
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3; // Index for bottom navigation bar
  final _formKey = GlobalKey<FormState>(); // Key to manage form state
  bool isEditing = false; // Flag to toggle editing mode
  bool isUpdated = false; // Flag to indicate profile update status
  double updatedOpacity = 0.0; // Opacity for update confirmation
  bool isLoading = true; // Flag to show loading state
  User? currentUser; // Current authenticated user
  Trainee? trainee; // Trainee object

  TextEditingController _birthDateController = TextEditingController(); // Controller for birth date input

  @override
  void initState() {
    super.initState();
    _initialize(); // Initialize the state by loading user data
  }

  // Initializes the profile page by fetching the current user and their details.
  Future<void> _initialize() async {
    currentUser = await getCurrentUser(); // Retrieve the currently authenticated user
    if (currentUser != null) {
      await _fetchTraineeDetails(); // Fetch trainee details if user is authenticated
    } else {
      setState(() {
        isLoading = false; // Set loading to false if no current user
      });
    }
  }

  // Fetches the details of the trainee from Firestore using the current user's ID.
  Future<void> _fetchTraineeDetails() async {
    if (currentUser != null) {
      await fetchTraineeDetails(
        currentUser!.uid,
        (Trainee traineeData) async {
          setState(() {
            trainee = traineeData;
            _birthDateController.text = traineeData.dob; // Populate birth date controller
            isLoading = false; // Stop loading
          });

          // Fetch supervisor name if available
          if (traineeData.supervisorId.isNotEmpty) {
            await _fetchSupervisorName(traineeData.supervisorId);
          }
        },
        (error) {
          print(error);
          setState(() {
            isLoading = false; // Stop loading on error
          });
        }
      );
    } else {
      print('No current user found');
      setState(() {
        isLoading = false; // Stop loading if no current user
      });
    }
  }

  // Fetches the name of the supervisor from Firestore based on the supervisor's ID.
  Future<void> _fetchSupervisorName(String supervisorId) async {
    await fetchSupervisorName(
      supervisorId,
      (supervisorName) {
        setState(() {
          trainee?.supervisorId = supervisorName; // Update supervisor name
        });
      },
      (error) {
        print(error);
      }
    );
  }

  // Updates the profile data of the current user in Firestore.
  Future<void> _updateProfileData() async {
    if (currentUser == null || trainee == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'name': trainee!.name,
        'email': trainee!.email,
        'dateOfBirth': _birthDateController.text,
        'supervisorId': trainee!.supervisorId,
      });
      setState(() {
        isUpdated = true;
        updatedOpacity = 1.0; // Show update confirmation
      });
      Timer(Duration(seconds: 1), () {
        setState(() {
          updatedOpacity = 0.0; // Hide update confirmation after delay
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
                  MaterialPageRoute(builder: (context) => LoginPage()),
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
                  'resources/tamimi.gif', // Path to loading GIF
                  width: 50.0,
                  height: 50.0,
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(25.0),
                  child: Container(
                    padding: EdgeInsets.all(30.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
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
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                              SizedBox(height: 12),
                              _buildTextField(
                                label: 'ID',
                                initialValue: trainee?.id ?? '',
                                enabled: false, // Make this field read-only
                              ),
                              SizedBox(height: 12),
                              _buildTextField(
                                label: 'Name',
                                initialValue: trainee?.name ?? '',
                                enabled: isEditing,
                                onChanged: (value) {
                                  setState(() {
                                    if (trainee != null) {
                                      trainee!.name = value; // Update trainee name
                                    }
                                  });
                                },
                              ),
                              SizedBox(height: 12.0),
                              _buildTextField(
                                label: 'Email',
                                initialValue: trainee?.email ?? '',
                                inputType: TextInputType.emailAddress,
                                enabled: isEditing,
                                onChanged: (value) {
                                  setState(() {
                                    if (trainee != null) {
                                      trainee!.email = value; // Update trainee email
                                    }
                                  });
                                },
                              ),
                              SizedBox(height: 12.0),
                              _buildDateField(
                                label: 'Date of Birth',
                                controller: _birthDateController,
                                enabled: isEditing,
                              ),
                              SizedBox(height: 12.0),
                              _buildTextField(
                                label: 'Supervisor Name',
                                initialValue: trainee?.supervisorId ?? 'Not Available',
                                enabled: false, // Make this field read-only
                              ),
                              SizedBox(height: 12.0),
                              if (isEditing)
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      _formKey.currentState?.save();
                                      setState(() {
                                        isEditing = false; // Exit editing mode
                                      });
                                      _updateProfileData(); // Update profile data
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
                          child: isEditing
                              ? IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      isEditing = false; // Exit editing mode
                                    });
                                  },
                                )
                              : IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      isEditing = true; // Enter editing mode
                                    });
                                  },
                                ),
                        ),
                        Positioned(
                          top: 10,
                          right: 50,
                          child: AnimatedOpacity(
                            opacity: updatedOpacity,
                            duration: Duration(seconds: 1),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 217, 86, 74),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                'Updated',
                                style: TextStyle(color: Colors.white),
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
      bottomNavigationBar: TraineeNavigationBar(
        currentIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index; // Update selected index for navigation bar
          });
        },
      ),
    );
  }

  // Builds a customizable text field widget.
  Widget _buildTextField({
    required String label,
    required String initialValue,
    TextInputType inputType = TextInputType.text,
    ValueChanged<String>? onChanged,
    bool enabled = true,
  }) {
    return TextFormField(
      enabled: enabled,
      initialValue: initialValue,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 18.0),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: const Color.fromARGB(255, 255, 255, 255)), // Custom border color when enabled
          borderRadius: BorderRadius.circular(25.0),
        ),
        enabled: enabled,
        constraints: BoxConstraints(
          minWidth: 270.0,
          minHeight: 45.0,
        ),
        filled: !enabled,
        fillColor: Color.fromARGB(255, 255, 255, 255),
      ),
      onChanged: enabled ? onChanged : null,
    );
  }

  // Builds a date field widget that allows users to pick a date.
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
                  controller.text = DateFormat('yyyy-MM-dd').format(pickedDate); // Format and set date
                });
              }
            }
          : null,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontSize: 18.0),
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
