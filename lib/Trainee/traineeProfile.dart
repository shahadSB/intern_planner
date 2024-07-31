import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intern_planner/Database/TraineeDetails.dart';
import 'package:intern_planner/Login/login.dart';
import 'package:intern_planner/Widgets/traineeNav.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
 int _selectedIndex = 3;
  final _formKey = GlobalKey<FormState>();
  bool isEditing = false;
  bool isUpdated = false;
  double updatedOpacity = 0.0;
  bool isLoading = true;
  User? currentUser;
  Trainee? trainee; // Trainee object

  TextEditingController _birthDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    currentUser = await getCurrentUser();
    if (currentUser != null) {
      await _fetchTraineeDetails();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchTraineeDetails() async {
    if (currentUser != null) {
      await fetchTraineeDetails(
        currentUser!.uid,
        (Trainee traineeData) async {
          setState(() {
            trainee = traineeData;
            _birthDateController.text = traineeData.dob;
            isLoading = false;
          });

          // Fetch supervisor name
          if (traineeData.supervisorId.isNotEmpty) {
            await _fetchSupervisorName(traineeData.supervisorId);
          }
        },
        (error) {
          print(error);
          setState(() {
            isLoading = false;
          });
        }
      );
    } else {
      print('No current user found');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchSupervisorName(String supervisorId) async {
    await fetchSupervisorName(
      supervisorId,
      (supervisorName) {
        setState(() {
          trainee?.supervisorId = supervisorName; // Assuming supervisorId holds the name here
        });
      },
      (error) {
        print(error);
      }
    );
  }

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
        updatedOpacity = 1.0;
      });
      Timer(Duration(seconds: 1), () {
        setState(() {
          updatedOpacity = 0.0;
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
                  'resources/tamimi.gif', // Path to your GIF
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
                                enabled: false,
                              ),
                              SizedBox(height: 12),
                              _buildTextField(
                                label: 'Name',
                                initialValue: trainee?.name ?? '',
                                enabled: isEditing,
                                onChanged: (value) {
                                  setState(() {
                                    if (trainee != null) {
                                      trainee!.name = value;
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
                                      trainee!.email = value;
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
                                        isEditing = false;
                                      });
                                      _updateProfileData();
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
                                      isEditing = false;
                                    });
                                  },
                                )
                              : IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      isEditing = true;
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
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  
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
                  controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
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
