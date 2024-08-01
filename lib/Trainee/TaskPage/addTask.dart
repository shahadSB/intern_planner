import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intern_planner/Widgets/buildWidgets.dart'; // Import the buildWidgets file

/// This page allows a trainee to add a new task.
class AddTaskPage extends StatefulWidget {
  final User? currentUser;

  AddTaskPage({required this.currentUser});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _priority = 'Low';
  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Add New Task',
          style: TextStyle(
            fontFamily: 'YourCustomFont',
            color: Color(0xFF31231A),
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40.0),
                    buildTextField(
                      label: 'Title',
                      onSaved: (value) => _title = value!,
                    ),
                    const SizedBox(height: 40.0),
                    buildDropdownField(
                      label: 'Priority',
                      value: _priority,
                      items: ['Low', 'Medium', 'High'],
                      onChanged: (value) => _priority = value!,
                    ),
                    const SizedBox(height: 28.0),
                    _buildDateField(),
                    const SizedBox(height: 2.0),
                    _buildTimeField(),
                    const SizedBox(height: 60.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          // Save the task to Firestore
                          final task = {
                            'title': _title,
                            'priority': _priority,
                            'dueDate': Timestamp.fromDate(DateTime(
                              _dueDate.year,
                              _dueDate.month,
                              _dueDate.day,
                              _dueTime.hour,
                              _dueTime.minute,
                            )),
                          };
                          // Assign the task to the current trainee
                          _assignTaskToTrainee(task);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromARGB(255, 224, 97, 85),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 110, vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the date picker field for selecting the due date of the task.
  Widget _buildDateField() {
    return TextButton(
      onPressed: () {
        showDatePicker(
          context: context,
          initialDate: _dueDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2060),
        ).then((pickedDate) {
          if (pickedDate != null) {
            setState(() {
              _dueDate = pickedDate;
            });
          }
        });
      },
      child: Text(
        'Due Date: ${_dueDate.toString().substring(0, 10)}',
        style: const TextStyle(
          color: Color.fromARGB(255, 224, 97, 85),
        ),
      ),
    );
  }

  /// Builds the time picker field for selecting the due time of the task.
  Widget _buildTimeField() {
    return TextButton(
      onPressed: () {
        showTimePicker(
          context: context,
          initialTime: _dueTime,
        ).then((pickedTime) {
          if (pickedTime != null) {
            setState(() {
              _dueTime = pickedTime;
            });
          }
        });
      },
      child: Text(
        'Due Time: ${_dueTime.format(context)}',
        style: const TextStyle(
          color: Color.fromARGB(255, 224, 97, 85),
        ),
      ),
    );
  }

  /* 
    Assigns the task to the current trainee and saves it to Firestore.
    [taskData] is a map containing the task details to be saved.
  */
  Future<void> _assignTaskToTrainee(Map<String, dynamic> taskData) async {
    if (widget.currentUser == null) return;

    // Get the trainee's ID from the currentUser object
    String traineeId = widget.currentUser!.uid;

    // Add the traineeId to the task data
    taskData['traineeId'] = traineeId;

    // Create a new task document
    DocumentReference taskRef = await FirebaseFirestore.instance.collection('tasks').add(taskData);

    // Update the trainee's document with the new taskId
    await FirebaseFirestore.instance.collection('users').doc(traineeId).update({
      'taskIds': FieldValue.arrayUnion([taskRef.id])
    });
  }
}
