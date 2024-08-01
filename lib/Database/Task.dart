import 'package:cloud_firestore/cloud_firestore.dart';

/* 
  A class representing a task with properties such as id, title, priority, due date, and completion status.
  The Task class provides a structure for storing task information, and includes
  a factory constructor to create a Task instance from a Firestore document.
*/
class Task {
  final String id;
  final String title;
  final String priority;
  final DateTime dueDate;
  bool isCompleted;

  /* 
    Constructs a [Task] with the provided parameters.
    [id] is the unique identifier for the task.
    [title] is the title of the task.
    [priority] indicates the priority level of the task.
    [dueDate] is the date by which the task should be completed.
    [isCompleted] indicates whether the task is completed. Defaults to `false`.
  */
  Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
  });

  /* 
    Factory constructor to create a [Task] instance from a Firestore document.
    [doc] is the Firestore document snapshot containing task data.
    Returns a [Task] instance with data extracted from the Firestore document.
  */
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id, // Unique document ID from Firestore.
      title: data['title'] ?? '', // Task title from Firestore document.
      priority: data['priority'] ?? 'Low', // Task priority from Firestore document.
      dueDate: (data['dueDate'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime.
      isCompleted: data['isCompleted'] ?? false, // Task completion status from Firestore document.
    );
  }
}
