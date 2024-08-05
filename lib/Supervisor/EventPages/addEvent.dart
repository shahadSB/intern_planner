import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

/// A page for adding events to the calendar, including title, description,
/// date, time, type, and a list of selected trainees.
class AddToCalendarPage extends StatefulWidget {
  @override
  _AddToCalendarPageState createState() => _AddToCalendarPageState();
}

class _AddToCalendarPageState extends State<AddToCalendarPage> {
  // Form key to manage the state of the form.
  final _formKey = GlobalKey<FormState>();

  // Variables to store selected date and time.
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 9, minute: 41);

  // Variables to store form input values.
  String? title;
  String? description;
  String? type;
  List<String> selectedTrainees = [];

  /// Opens a date picker dialog and updates the selected date.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(), // Set firstDate to today
      lastDate: DateTime(2060),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  /// Opens a time picker dialog and updates the selected time.
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  /// Fetches the list of trainees from Firestore based on the current user's supervisor ID.
  Future<List<MultiSelectItem<String>>> _fetchTrainees() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final supervisorId = user.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('supervisorId', isEqualTo: supervisorId)
        .get();

    return snapshot.docs
        .map((doc) => MultiSelectItem<String>(doc.id, doc.data()['name'] ?? ''))
        .toList();
  }

  /// Adds a new event to Firestore and updates the selected trainees with the event reference.
  Future<void> _addEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final event = {
        'title': title,
        'description': description ?? '',
        'type': type,
        'dueDate': Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute)),
        'adminID': FirebaseAuth.instance.currentUser?.uid,
        'student': selectedTrainees,
      };

      final eventRef = await FirebaseFirestore.instance.collection('events').add(event);

      for (String traineeId in selectedTrainees) {
        await FirebaseFirestore.instance.collection('users').doc(traineeId).update({
          'eventIds': FieldValue.arrayUnion([eventRef.id])
        });
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Add to Calendar',
          style: TextStyle(
            fontFamily: 'YourCustomFont', 
            color: Color(0xFF31231A), 
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 20),
            child: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Add to Calendar',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    buildTextField('Title *', 'Enter title here', (value) => title = value, true),
                    SizedBox(height: 15),
                    buildTextField('Description', 'Enter description here', (value) => description = value, false),
                    SizedBox(height: 15),
                    buildDateTimeField(),
                    SizedBox(height: 15),
                    buildDropdownField('Type *', 'Select type', (value) => type = value),
                    SizedBox(height: 15),

                    FutureBuilder<List<MultiSelectItem<String>>>(
                      future: _fetchTrainees(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error fetching trainees');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text('No trainees found');
                        } else {
                          return MultiSelectDialogField(
                            items: snapshot.data!,
                            title: Text("Trainees"),
                            selectedColor: Colors.blue,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              border: Border.all(
                                color: Colors.grey,
                                width: 2,
                              ),
                            ),
                            buttonIcon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                            buttonText: Text(
                              "Select Trainees *",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            onConfirm: (results) {
                              selectedTrainees = List<String>.from(results);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select at least one trainee';
                              }
                              return null;
                            },
                          );
                        }
                      },
                    ),
                    SizedBox(height: 35),
                    
                    ElevatedButton(
                      onPressed: _addEvent,
                      child: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromARGB(255, 217, 86, 74),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 120, vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
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

  /// Builds a text field with given label, hint, and onSaved callback.
  Widget buildTextField(String label, String hint, FormFieldSetter<String> onSaved, bool isRequired, {IconData? suffixIcon}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: Color.fromARGB(255, 255, 255, 255),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a value';
              }
              return null;
            }
          : null,
      onSaved: onSaved,
    );
  }

  /// Builds a date and time field that shows the selected date and time.
  Widget buildDateTimeField() {
    return InkWell(
      onTap: () async {
        await _selectDate(context);
        await _selectTime(context);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date & Time *',
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          filled: true,
          fillColor: Color.fromARGB(255, 255, 255, 255),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
            Text(DateFormat('h:mm a').format(DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            ))),
          ],
        ),
      ),
    );
  }

  /// Builds a dropdown field for selecting the event type.
  Widget buildDropdownField(String label, String hint, FormFieldSetter<String> onSaved) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: Color.fromARGB(255, 255, 255, 255),
      ),
      items: ['Deadline', 'Meeting']
          .map((type) => DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          type = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a type';
        }
        return null;
      },
      onSaved: onSaved,
    );
  }
}
