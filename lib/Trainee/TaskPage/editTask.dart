import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intern_planner/Database/Task.dart';
import 'package:intl/intl.dart';

// Page for editing an existing task.
class EditTaskPage extends StatefulWidget {
  final Task task;

  // Constructor to initialize the task to be edited.
  EditTaskPage({required this.task});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late final TextEditingController _titleController;
  late String _priority;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  late bool _isCompleted;
  late String _id;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _priority = widget.task.priority;
    _dueDate = widget.task.dueDate;
    _dueTime = TimeOfDay(hour: widget.task.dueDate.hour, minute: widget.task.dueDate.minute);
    _isCompleted = widget.task.isCompleted;
    _id = widget.task.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // Saves the updated task details to Firestore.
  Future<void> _saveTask() async {
    final newDueDate = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    Task updatedTask = Task(
      id: _id,
      title: _titleController.text,
      priority: _priority,
      dueDate: newDueDate,
      isCompleted: _isCompleted,
    );

    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(_id)
        .update({
      'title': updatedTask.title,
      'priority': updatedTask.priority,
      'dueDate': updatedTask.dueDate,
      'isCompleted': updatedTask.isCompleted,
    });

    Navigator.pop(context, updatedTask);
  }

  // Allows the user to select a due time using a time picker dialog.
  Future<void> _selectDueTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null && picked != _dueTime) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Edit Task',
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
          padding: const EdgeInsets.symmetric(vertical: 75, horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(label: 'Title', controller: _titleController),
              SizedBox(height: 16.0),
              _buildDropdownField(
                label: 'Priority',
                value: _priority,
                items: ['Low', 'Medium', 'High'],
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: _dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        ).then((pickedDate) {
                          if (pickedDate != null) {
                            setState(() {
                              _dueDate = pickedDate;
                            });
                          }
                        });
                      },
                      child: Text(
                        'Due Date: ${DateFormat('yyyy-MM-dd').format(_dueDate)}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 224, 97, 85),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectDueTime(context),
                      child: Text(
                        'Due Time: ${_dueTime.format(context)}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 224, 97, 85),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              SwitchListTile(
                title: Text(
                  'Completed',
                  style: const TextStyle(
                    color: Color(0xFF31231A),
                  ),
                ),
                activeColor: Color.fromARGB(255, 224, 97, 85),
                value: _isCompleted,
                onChanged: (value) {
                  setState(() {
                    _isCompleted = value;
                  });
                },
              ),
              Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: _saveTask,
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 224, 97, 85),
                    padding: EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds a text field with the specified label and controller.
  Widget _buildTextField({required String label, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF31231A)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF31231A)),
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF31231A)),
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  // Builds a dropdown field with the specified label, value, items, and onChanged callback.
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF31231A)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF31231A)),
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF31231A)),
          borderRadius: BorderRadius.circular(30),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
