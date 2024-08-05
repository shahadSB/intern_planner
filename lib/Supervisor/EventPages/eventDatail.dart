import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intern_planner/Database/Event.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

/// A page to view and edit details of an event.
class EventDetailPage extends StatefulWidget {
  final Event event; // The event object to display and edit
  final Function(Event) onSave; // Callback function to notify parent widget about save

  EventDetailPage({required this.event, required this.onSave});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _typeController;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  bool isEditing = false; // Flag to indicate if the page is in edit mode
  List<MultiSelectItem<String>> traineeItems = [];
  List<String> selectedTrainees = [];
  Map<String, String> traineeNames = {}; // Map to store ID-to-name mapping for trainees
  String? selectedType;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with event data
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _typeController = TextEditingController(text: widget.event.type);
    selectedDate = widget.event.dueDate;
    selectedTime = TimeOfDay(
      hour: widget.event.dueDate.hour,
      minute: widget.event.dueDate.minute,
    );
    selectedType = widget.event.type;
    selectedTrainees = widget.event.student; // Initialize selected trainees
    _fetchTrainees(); // Fetch trainees and set items
  }

  /// Fetches the list of trainees from Firestore and updates the traineeItems list.
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
          traineeNames[id] = name; // Map ID to name
          return MultiSelectItem<String>(id, name);
        })
        .toList();

    setState(() {
      traineeItems = traineeData;
    });
  }

  /// Opens a date picker to select a new date.
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

  /// Opens a time picker to select a new time.
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

  /// Saves the updated event details to Firestore.
  Future<void> _saveEvent() async {
    if (isEditing) {
      final event = Event(
        id: widget.event.id,
        title: _titleController.text,
        description: _descriptionController.text,
        type: selectedType ?? widget.event.type,
        dueDate: DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        ),
        student: selectedTrainees,
      );

      try {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.event.id)
            .update({
          'title': event.title,
          'description': event.description,
          'type': event.type,
          'dueDate': Timestamp.fromDate(event.dueDate),
          'student': event.student,
        });

        widget.onSave(event); // Notify parent widget about the save
        _fetchTrainees(); // Re-fetch to ensure trainee names are updated
        setState(() {
          isEditing = false;
        });
      } catch (e) {
        print('Error updating event: $e');
      }
    }
  }

  /// Toggles between edit and view modes.
  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  /// Exits edit mode and resets fields to original values.
  void _exitEditMode() {
    setState(() {
      isEditing = false;
      _titleController.text = widget.event.title;
      _descriptionController.text = widget.event.description;
      _typeController.text = widget.event.type;
      selectedDate = widget.event.dueDate;
      selectedTime = TimeOfDay(
        hour: widget.event.dueDate.hour,
        minute: widget.event.dueDate.minute,
      );
      selectedType = widget.event.type;
      selectedTrainees = widget.event.student;
    });
  }

  /// Deletes the event from Firestore.
  Future<void> _deleteEvent() async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .delete();
      Navigator.of(context).pop(); // Go back to the previous screen
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.close, color: Color.fromARGB(255, 107, 107, 107)),
              onPressed: _exitEditMode,
            ),
          if (!isEditing)
            IconButton(
              icon: Icon(Icons.edit, color: Color.fromARGB(255, 107, 107, 107)),
              onPressed: _toggleEdit,
            ),
          IconButton(
            icon: Icon(Icons.delete, color: Color.fromARGB(255, 107, 107, 107)),
            onPressed: _deleteEvent,
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
                  buildTextField('Title', _titleController, enabled: isEditing),
                  SizedBox(height: 10),
                  buildTextField('Description', _descriptionController, enabled: isEditing),
                  SizedBox(height: 10),
                  buildDateTimeField(),
                  SizedBox(height: 10),
                  buildDropdownField(
                    'Type',
                    'Select type',
                    selectedType,
                    ['Deadline', 'Meeting'],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    },
                    enabled: isEditing,
                  ),
                  SizedBox(height: 15),
                  if (isEditing && traineeItems.isNotEmpty) 
                    MultiSelectDialogField(
                      items: traineeItems,
                      title: Text("Trainees"),
                      selectedColor: Color.fromARGB(255, 187, 217, 164),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        border: Border.all(
                          color: Color.fromARGB(255, 224, 224, 224),
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
                          color: Color.fromARGB(255, 224, 224, 224),
                          fontSize: 16,
                        ),
                      ),
                      initialValue: selectedTrainees,
                      onConfirm: (results) {
                        setState(() {
                          selectedTrainees = List<String>.from(results);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select at least one trainee';
                        }
                        return null;
                      },
                    )
                  else
                    buildReadOnlyField(
                      'Trainees',
                      selectedTrainees.isEmpty
                        ? 'None'
                        : selectedTrainees.map((id) => traineeNames[id] ?? 'Unknown').join(', '),
                    ),
                  SizedBox(height: 30),
                  if (isEditing)
                    ElevatedButton(
                      onPressed: _saveEvent,
                      child: Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 187, 217, 164),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a text field with the specified label and controller.
  Widget buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        enabled: enabled,
      ),
      maxLines: null,
    );
  }

  /// Builds a read-only field with the specified label and value.
  Widget buildReadOnlyField(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      child: Text(value),
    );
  }

  /// Builds a date and time selection field.
  Widget buildDateTimeField() {
    return Row(
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: isEditing ? () => _selectDate(context) : null,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: isEditing ? () => _selectTime(context) : null,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(),
              ),
              child: Text(selectedTime.format(context)),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a dropdown field with the specified label, hint, value, and options.
  Widget buildDropdownField(String label, String hint, String? value, List<String> options, 
  {ValueChanged<String?>? onChanged, bool enabled = true}) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      hint: Text(hint),
      onChanged: enabled ? onChanged : null,
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
    );
  }
}
