import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intern_planner/Database/Event.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

/* 
  A StatefulWidget that displays the details of a specific event.
  The event details are displayed in a read-only format with options to view
  the title, description, date & time, and type of the event.
*/
class EventViewPage extends StatefulWidget {
  /* 
    Creates an instance of [EventViewPage].
    [event] is the event to be displayed.
  */
  final Event event;

  EventViewPage({required this.event});

  @override
  _EventViewPageState createState() => _EventViewPageState();
}

class _EventViewPageState extends State<EventViewPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _typeController;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  List<MultiSelectItem<String>> traineeItems = [];
  List<String> selectedTrainees = [];
  String? selectedType;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with event data
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _typeController = TextEditingController(text: widget.event.type);

    // Set initial date and time
    selectedDate = widget.event.dueDate;
    selectedTime = TimeOfDay(
      hour: widget.event.dueDate.hour,
      minute: widget.event.dueDate.minute,
    );

    // Set initial type and selected trainees
    selectedType = widget.event.type;
    selectedTrainees = widget.event.student; // Initialize selected trainees

    // Fetch list of trainees from Firestore
    _fetchTrainees();
  }

  // Fetches the list of trainees from Firestore based on the current user's supervisor ID.
  Future<void> _fetchTrainees() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final supervisorId = user.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('supervisorId', isEqualTo: supervisorId)
        .get();

    final traineeData = snapshot.docs
        .map((doc) {
          final id = doc.id;
          final name = doc.data()['name'] ?? '';
          return MultiSelectItem<String>(id, name);
        })
        .toList();

    setState(() {
      traineeItems = traineeData;
    });
  }

  // Opens a date picker dialog to select a date.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // Opens a time picker dialog to select a time.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        actions: [],
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
            padding: EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                   SizedBox(height: 30),
                  // Build read-only text fields for title and description
                  buildTextField('Title', _titleController, enabled: false),
                  SizedBox(height: 10),
                  buildTextField('Description', _descriptionController, enabled: false),
                  SizedBox(height: 10),
                  // Build the date and time display field
                  buildDateTimeField(),
                  SizedBox(height: 10),
                  // Build the dropdown field for event type
                  buildDropdownField(
                    'Type',
                    'Select type',
                    selectedType,
                    ['Deadline', 'Meeting'],
                    onChanged: (value) {},
                    enabled: false,
                  ),
                  SizedBox(height: 30),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* 
    Builds a text field widget with the provided label and controller.
    [label] is the text label for the field.
    [controller] is the TextEditingController managing the text for the field.
    [enabled] specifies whether the field is editable. Defaults to true.
  */
  Widget buildTextField(String label, TextEditingController controller, {bool enabled = true, IconData? suffixIcon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 224, 224, 224)),
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: Color.fromARGB(255, 255, 255, 255),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
      ),
      enabled: enabled,
    );
  }

  /* 
    Builds a widget to display the selected date and time.
    Users can tap this field to open the date and time pickers.
  */
  Widget buildDateTimeField() {
    return InkWell(
      onTap: () async {
        await _selectDate(context);
        await _selectTime(context);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date & Time',
          labelStyle: TextStyle(color: Color(0xFF31231A)),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 224, 224, 224)),
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

  /*
    Builds a dropdown field for selecting event type.
    [label] is the text label for the dropdown.
    [hint] is the hint text displayed when no value is selected.
    [selectedValue] is the currently selected value.
    [items] is the list of possible values to choose from.
    [onChanged] is the callback function triggered when the selected value changes.
    [enabled] specifies whether the dropdown is interactive. Defaults to true.
  */
  Widget buildDropdownField(
    String label,
    String hint,
    String? selectedValue,
    List<String> items, {
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return IgnorePointer(
      ignoring: !enabled,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 224, 224, 224)),
            borderRadius: BorderRadius.circular(30),
          ),
          filled: true,
          fillColor: Color.fromARGB(255, 255, 255, 255),
        ),
        value: selectedValue,
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: enabled ? onChanged : null,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a type';
          }
          return null;
        },
      ),
    );
  }

  /* 
    Builds a read-only text field with the provided label and value.
    [label] is the text label for the field.
    [value] is the text displayed in the field.
  */
  Widget buildReadOnlyField(String label, String value) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 224, 224, 224)),
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: Color.fromARGB(255, 255, 255, 255),
      ),
      controller: TextEditingController(text: value),
      enabled: false, // Read-only
    );
  }
}
