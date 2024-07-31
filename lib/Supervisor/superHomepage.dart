import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intern_planner/Database/Event.dart';
import 'package:intern_planner/Login/login.dart';
import 'package:intern_planner/Supervisor/EventPages/addEvent.dart';
import 'package:intern_planner/Supervisor/EventPages/eventDatail.dart';
import 'package:intern_planner/Widgets/supervisorNav.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';


class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _selectedIndex = 1;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Event> events = [];
  User? currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _listenForEvents();
    }
  }

  void _listenForEvents() {
    FirebaseFirestore.instance
        .collection('events')
        .where('adminID', isEqualTo: currentUser?.uid)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        events = snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
        _isLoading = false;
      });
    });
  }

  Future<void> _fetchEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('adminID', isEqualTo: currentUser?.uid) //there is admin ID in both collections!!!
          .get();

      setState(() {
        events = snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events.where((event) {
      return isSameDay(event.dueDate, day);
    }).toList();
  }

  List<Event> _getUpcomingEvents() {
    return events.where((event) {
      return event.dueDate.isAfter(DateTime.now()) || isSameDay(event.dueDate, DateTime.now());
    }).toList();
  }

  List<Event> _getPassedEvents() {
    return events.where((event) {
      return event.dueDate.isBefore(DateTime.now());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final upcomingEvents = _getUpcomingEvents();
    final passedEvents = _getPassedEvents();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Supervisor Homepage',
          style: TextStyle(
            fontFamily: 'YourCustomFont', // Replace with the desired font family
            color: Color(0xFF31231A), // Set the text color
            fontSize: 20.0,
            fontWeight: FontWeight.bold, // Adjust the font size as needed
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Use the logout icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
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
          child: _isLoading
              ? Image.asset(
                  'resources/tamimi.gif', // Path to your GIF
                  width: 50.0,
                  height: 50.0,
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.info_outline, size: 25),
                          onPressed: _showInfoDialog,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2024, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onFormatChanged: (format) {
                            if (_calendarFormat != format) {
                              setState(() {
                                _calendarFormat = format;
                              });
                            }
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                          eventLoader: _getEventsForDay,
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, date, events) {
                              if (events.isNotEmpty) {
                                // Check if there are both types of events
                                bool hasDeadline = events.any((event) => (event as Event).type == 'Deadline');
                                bool hasMeeting = events.any((event) => (event as Event).type == 'Meeting');

                                List<Widget> markers = [];
                                if (hasDeadline && hasMeeting) {
                                  markers.add(
                                    Positioned(
                                      bottom: 1,
                                      child: Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color.fromARGB(255, 84, 166, 224),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  for (var event in events) {
                                    final eventType = (event as Event).type;
                                    if (eventType == 'Deadline') {
                                      markers.add(
                                        Positioned(
                                          bottom: 1,
                                          child: Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else if (eventType == 'Meeting') {
                                      markers.add(
                                        Positioned(
                                          bottom: 1,
                                          child: Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color.fromARGB(255, 135, 181, 65),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                                return Stack(
                                  alignment: Alignment.center,
                                  children: markers,
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Upcoming Events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF31231A),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ...upcomingEvents.map((event) {
                        return _buildEventCard(context, event);
                      }).toList(),
                      SizedBox(height: 20),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Passed Events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF31231A),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ...passedEvents.map((event) {
                        return _buildEventCard(context, event);
                      }).toList(),
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: SupervisorNavBar(
        currentIndex: _selectedIndex,
        onItemTapped: (index) {
          onItemTapped(context, index); // Call the refactored method
          setState(() {
            _selectedIndex = index; // Update the state
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddToCalendarPage()),
          );
        },
        backgroundColor: Color.fromARGB(255, 195, 77, 69),
        shape: CircleBorder(),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  

  Widget _buildEventCard(BuildContext context, Event event) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(
              event: event,
              onSave: (updatedEvent) => _updateEvent(event.id, updatedEvent),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            width: 5,
            color: event.type == 'Deadline' ? Colors.red : Color.fromARGB(255, 135, 181, 65),
          ),
          title: Text(
            event.title,
            style: TextStyle(
              color: Color(0xFF31231A),
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            event.type,
            style: const TextStyle(
              color: Color(0xFF31231A),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(event.dueDate),
                style: const TextStyle(
                  color: Color(0xFF31231A),
                ),
              ),
              Text(
                DateFormat('h:mm a').format(event.dueDate),
                style: const TextStyle(
                  color: Color(0xFF31231A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateEvent(String eventId, Event updatedEvent) {
    FirebaseFirestore.instance.collection('events').doc(eventId).update({
      'title': updatedEvent.title,
      'type': updatedEvent.type,
      'dueDate': Timestamp.fromDate(updatedEvent.dueDate),
    }).then((_) {
      print('Event updated successfully');
    }).catchError((error) {
      print('Failed to update event: $error');
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Calendar Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 10,
                ),
                SizedBox(width: 10),
                Text('Deadlines'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 135, 181, 65),
                  radius: 10,
                ),
                SizedBox(width: 10),
                Text('Meetings'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 84, 166, 224),
                  radius: 10),
                SizedBox(width: 10),
                Text('Deadlines and Meetings'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class CalendarEvent {
  final String id;
  final String title;
  final String type;
  final DateTime dueDate;

  CalendarEvent({required this.id, required this.title, required this.type, required this.dueDate});

  factory CalendarEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CalendarEvent(
      id: doc.id,
      title: data['title'] ?? '',
      type: data['type'] ?? 'Meeting',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
    );
  }
}
