import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String priority;
  final DateTime dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      priority: data['priority'] ?? 'Low',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
    );
  }
}


