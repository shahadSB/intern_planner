import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final DateTime dueDate;
  final String type;
  final List<String> student;
  final String description;

  Event({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.type,
    required this.student, 
    required this.description,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      type: data['type'] ?? '',
      student: List<String>.from(data['student'] ?? []),
      description: data['description']??'',
    );
  }
}
