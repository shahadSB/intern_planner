import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intern_planner/Database/Event.dart';
import 'package:intern_planner/Login/login.dart';
import 'package:intern_planner/Trainee/traineeEventDetails.dart';
import 'package:intern_planner/Widgets/traineeNav.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// A StatefulWidget that displays a calendar with events for the trainee.
class TraineeCalendarPage extends StatefulWidget {
  @override
  _TraineeCalendarPageState createState() => _TraineeCalendarPageState();
}

class _TraineeCalendarPageState extends State<TraineeCalendarPage> {
  int _selectedIndex = 0;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Event> events = [];
  List<Event> upcomingEvents = [];
  List<Event> pastEvents = [];
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Retrieves the currently authenticated user and initiates event listening.
  void _getCurrentUser() {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _listenForEvents();
    }
  }

  // Sets up a listener to Firestore for real-time updates on events.
  void _listenForEvents() {
    FirebaseFirestore.instance
        .collection('events')
        .where('student', arrayContains: currentUser?.uid)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        events = snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
        _categorizeEvents();
      });
    });
  }

  // Categorizes events into upcoming and past based on the current date.
  void _categorizeEvents() {
    final now = DateTime.now();
    upcomingEvents = events.where((event) => event.dueDate.isAfter(now)).toList();
    pastEvents = events.where((event) => event.dueDate.isBefore(now)).toList();
  }

  // Returns a list of events for the specified day.
  List<Event> _getEventsForDay(DateTime day) {
    return events.where((event) {
      return isSameDay(event.dueDate, day);
    }).toList();
  }

  // Displays a dialog with information about calendar markers.
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
                  radius: 10,
                ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Trainee Calendar',
          style: TextStyle(
            fontFamily: 'YourCustomFont',
            color: Color(0xFF31231A),
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.info_outline, size: 25),
                            onPressed: _showInfoDialog,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 0,
                                blurRadius: 4,
                                offset: const Offset(0, 4),
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
                                          decoration: const BoxDecoration(
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
                                              decoration: const BoxDecoration(
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
                                              decoration: const BoxDecoration(
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
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Upcoming Events',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF31231A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...upcomingEvents.map((event) {
                          return _buildEventCard(context, event);
                        }).toList(),
                        const SizedBox(height: 20),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Past Events',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF31231A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...pastEvents.map((event) {
                          return _buildEventCard(context, event);
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: TraineeNavigationBar(
        currentIndex: _selectedIndex,
       onItemTapped: (context, index) {
          setState(() {
            _selectedIndex = index;
          });
          onItemTapped(context, index); // Handle bottom navigation item tap
        },
      ),
    );
  }

  // Builds a card widget for displaying an individual event.
  Widget _buildEventCard(BuildContext context, Event event) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventViewPage(event: event),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 4),
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
            style: const TextStyle(
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
}
