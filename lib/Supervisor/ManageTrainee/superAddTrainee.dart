import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intern_planner/Database/TraineeDetails.dart';

/* 
  A page for adding a trainee to a supervisor's list.
  This page allows the supervisor to search for a trainee by email,
  view the trainee's details, and assign them to themselves if they are
  not already assigned to another supervisor.
*/
class AddTraineePage extends StatefulWidget {
  // Callback function invoked when a trainee is successfully added.
  final void Function(Trainee) onAdd;

  AddTraineePage({required this.onAdd});

  @override
  _AddTraineePageState createState() => _AddTraineePageState();
}

class _AddTraineePageState extends State<AddTraineePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _loading = false; // Indicates whether data is being loaded
  String? _errorMessage; // Error message to display
  String? _successMessage; // Success message to display
  String? _infoMessage; // Information message to display
  bool _isTraineeFetched = false; // Indicates whether trainee data has been fetched

  // Searches for a trainee by email and updates the form fields with the trainee's data.
  Future<void> _searchTrainee() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
      _infoMessage = null;
      _isTraineeFetched = false;
    });

    try {
      final email = _emailController.text;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final supervisorId = user.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = 'No trainee found with this email';
          _loading = false;
          _emailController.clear();
          _nameController.clear();
          _employeeIdController.clear();
          _dobController.clear();
          _isTraineeFetched = false;
        });
        return;
      }

      final traineeData = snapshot.docs.first.data();

      // Update form fields with fetched data
      _nameController.text = traineeData['name'] ?? '';
      _employeeIdController.text = traineeData['employeeId'] ?? '';
      _dobController.text = traineeData['dateOfBirth'] ?? '';

      // Check if trainee already has a supervisor
      if (traineeData.containsKey('supervisorId')) {
        if (traineeData['supervisorId'] != supervisorId) {
          setState(() {
            _errorMessage = 'This trainee has another supervisor';
            _emailController.clear();
            _nameController.clear();
            _employeeIdController.clear();
            _dobController.clear();
            _isTraineeFetched = false;
          });
          return;
        } else {
          setState(() {
            _infoMessage = 'This trainee is already assigned to you';
          });
        }
      } else {
        setState(() {
          _isTraineeFetched = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching trainee data: ${e.toString()}';
        _emailController.clear();
        _nameController.clear();
        _employeeIdController.clear();
        _dobController.clear();
        _isTraineeFetched = false;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Submits the trainee data to be added to the supervisor's list.
  Future<void> _submit() async {
    if (!_isTraineeFetched) {
      setState(() {
        _errorMessage = 'Please search for a trainee before adding';
      });
      return;
    }

    final email = _emailController.text;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'User not logged in';
      });
      return;
    }

    final supervisorId = user.uid;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _errorMessage = 'No trainee found with this email';
        });
        return;
      }

      final traineeData = snapshot.docs.first.data();
      final traineeId = snapshot.docs.first.id;

      // Add supervisor ID to trainee data in users collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(traineeId)
          .update({'supervisorId': supervisorId});

      // Save the trainee to the supervisor's list
      await FirebaseFirestore.instance
          .collection('supervisorsTraineeRelation')
          .doc(supervisorId)
          .collection('trainees')
          .doc(traineeId)
          .set({
            ...traineeData,
            'supervisorId': supervisorId
          });

      setState(() {
        _successMessage = 'Trainee added successfully';
        _errorMessage = null;
      });

      // Optionally clear fields or perform additional actions
      _emailController.clear();
      _nameController.clear();
      _employeeIdController.clear();
      _dobController.clear();
      _isTraineeFetched = false;

    } catch (e) {
      setState(() {
        _errorMessage = 'Error adding trainee: ${e.toString()}';
      });
    }
  }

  // Returns the decoration for text input fields.
  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(
          color: Color.fromARGB(255, 174, 174, 174),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(
          color: const Color.fromARGB(255, 174, 174, 174),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(
          color: const Color.fromARGB(255, 87, 87, 87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Add Trainee'),
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
          child: Container(
            padding: const EdgeInsets.all(32.0),
            margin: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Email field with search icon
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        decoration: _inputDecoration('Email').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: _searchTrainee,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: _inputDecoration('Name'),
                  enabled: false, // Disable field
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _employeeIdController,
                  decoration: _inputDecoration('Employee ID'),
                  enabled: false, // Disable field
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _dobController,
                  decoration: _inputDecoration('Date of Birth'),
                  enabled: false, // Disable field
                ),
                SizedBox(height: 20),
                _loading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _submit,
                      child: Text('Add Trainee'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, 
                        backgroundColor: Color.fromARGB(255, 195, 77, 69), 
                        fixedSize: Size(270, 35), // Button size
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                if (_errorMessage != null) ...[
                  SizedBox(height: 10),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ],
                if (_infoMessage != null) ...[
                  SizedBox(height: 10),
                  Text(
                    _infoMessage!,
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
                if (_successMessage != null) ...[
                  SizedBox(height: 10),
                  Text(
                    _successMessage!,
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
