import 'package:cloud_firestore/cloud_firestore.dart';

/* 
  This class defines the structure of an event, which includes an ID, title,
  due date, type, list of students, and description. It also includes a factory
  constructor to create an Event instance from Firestore data.
*/
class Event {
  final String id; // Unique identifier for the event.
  final String title; // Title of the event.
  final DateTime dueDate; // Due date of the event.
  final String type; // Type/category of the event.
  final List<String> student; // List of students associated with the event.
  final String description; // Description of the event.

  /// Constructs an [Event] instance with the given parameters.
  Event({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.type,
    required this.student,
    required this.description,
  });

/*
  Factory constructor to create an [Event] instance from Firestore [DocumentSnapshot].
  This constructor extracts data from the Firestore document and maps it to the
  corresponding fields of the [Event] class.
  */
  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map; // Extract data from the Firestore document.
    return Event(
      id: doc.id, // Set the event ID to the document ID.
      title: data['title'] ??
          '', // Extract the title, defaulting to an empty string if null.
      dueDate: (data['dueDate'] as Timestamp)
          .toDate(), // Convert Firestore Timestamp to DateTime.
      type: data['type'] ??
          '', // Extract the type, defaulting to an empty string if null.
      student: List<String>.from(
          data['student'] ?? []), // Convert the student list to a List<String>.
      description: data['description'] ??
          '', // Extract the description, defaulting to an empty string if null.
    );
  }
}
