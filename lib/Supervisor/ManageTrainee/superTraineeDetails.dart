import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intern_planner/Database/TraineeDetails.dart';

/* 
  A page that displays detailed information about a trainee.
  This page includes a profile picture, name, ID, email, and date of birth of the trainee.
  It also provides an option to delete the trainee's profile.
*/
class TraineeListDetailsPage extends StatelessWidget {
  final Trainee trainee; // The trainee whose details are to be displayed.
  final void Function(Trainee) onDelete; // Callback function to handle deletion of the trainee.

  TraineeListDetailsPage({required this.trainee, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Trainee Profile",
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
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // Clear the supervisorId field before deleting the trainee
              await _clearSupervisorId(trainee.id);
              onDelete(trainee); // Notify parent widget about deletion
              Navigator.pop(context); // Close the details page
            },
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
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
        child: Padding(
          padding: const EdgeInsets.all(23.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(37.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 23.0),
                    // Display the trainee's profile picture
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color.fromARGB(255, 187, 217, 164),
                      child: Text(
                        trainee.name[0],
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 34.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 23.0),
                    // Display trainee details
                    _buildInfoRow("Trainee Name", trainee.name),
                    _buildInfoRow("Trainee ID", trainee.employeeId),
                    _buildInfoRow("Trainee Email", trainee.email),
                    _buildInfoRow("Trainee DOB", trainee.dob),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* 
    Clears the supervisorId field from the trainee document in Firestore.
    [traineeId] is the ID of the trainee whose supervisorId needs to be cleared.
  */
  Future<void> _clearSupervisorId(String traineeId) async {
    await FirebaseFirestore.instance.collection('users').doc(traineeId).update({
      'supervisorId': FieldValue.delete(),
    });
  }

  /* 
    Builds a row displaying a label and a value.
    [label] is the text label for the information.
    [value] is the text value to display.
  */
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 19.0,
              color: Color(0xFF31231A),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18.0,
                color: Color.fromARGB(255, 24, 27, 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
