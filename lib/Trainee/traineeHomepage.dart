import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intern_planner/Database/Event.dart';
import 'package:intern_planner/Database/Task.dart';
import 'package:intern_planner/Login/login.dart';
import 'package:intern_planner/Trainee/TaskPage/taskList.dart';
import 'package:intern_planner/Trainee/traineeCalendar.dart';
import 'package:intern_planner/Trainee/traineeEventDetails.dart';
import 'package:intern_planner/Trainee/traineeProfile.dart';
import 'package:intern_planner/Widgets/traineeNav.dart';
import 'package:intl/intl.dart';

import 'TaskPage/taskTile.dart';

// A StatefulWidget that represents the homepage for a trainee, displaying today's schedule and tasks.
class TraineeHomepage extends StatefulWidget {
  @override
  _TraineeHomepageState createState() => _TraineeHomepageState();
}

class _TraineeHomepageState extends State<TraineeHomepage> {
  int _selectedIndex = 1; // Index for bottom navigation bar
  List<Event> todayEvents = []; // List to hold events for today
  User? currentUser; // Holds the currently authenticated user
  bool _isLoading = true; // Flag to show loading state

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // Fetch the current user when the widget initializes
  }

  // Fetches the currently authenticated user from FirebaseAuth.
  void _getCurrentUser() {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _fetchTodayEvents(); // Fetch today's events if user is authenticated
    }
  }

  // Fetches events for the current day from Firestore.
  Future<void> _fetchTodayEvents() async {
    final userId = currentUser?.uid;
    if (userId == null) return;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .get();

      print('Fetched all events: ${querySnapshot.docs.length}'); // Debugging output

      final events = querySnapshot.docs.where((doc) {
        final event = Event.fromFirestore(doc);
        return event.student.contains(userId) && 
               event.dueDate.isAfter(startOfDay) && 
               event.dueDate.isBefore(endOfDay);
      }).map((doc) {
        return Event.fromFirestore(doc);
      }).toList();

      setState(() {
        todayEvents = events;
        _isLoading = false; // Set loading flag to false after data is fetched
      });
    } catch (e) {
      print('Error fetching events: $e');
      setState(() {
        _isLoading = false; // Set loading flag to false in case of an error
      });
    }
  }

  // Filters and sorts tasks to show only those due today.
  List<Task> _filterAndSortTasksForToday(List<Task> tasks) {
    final today = DateTime.now();
    List<Task> filteredTasks = tasks.where((task) {
      return task.dueDate.year == today.year &&
          task.dueDate.month == today.month &&
          task.dueDate.day == today.day;
    }).toList();

    // Priority mapping for sorting tasks
    Map<String, int> priorityMapping = {
      'High': 1,
      'Medium': 2,
      'Low': 3,
    };

    // Sort tasks by priority and then by due time
    filteredTasks.sort((a, b) {
      int priorityComparison = priorityMapping[a.priority]!.compareTo(priorityMapping[b.priority]!);
      if (priorityComparison != 0) {
        return priorityComparison;
      } else {
        return a.dueDate.compareTo(b.dueDate);
      }
    });

    return filteredTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Today\'s Schedule',
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
        child: _isLoading
            ? Center(
                child: Image.asset(
                  'resources/tamimi.gif',
                  width: 50.0,
                  height: 50.0,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: todayEvents.map((event) {
                        return _buildScheduleItem(event);
                      }).toList(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Tasks',
                      style: TextStyle(
                        color: Color(0xFF31231A),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('tasks')
                          .where('traineeId', isEqualTo: currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: Image.asset(
                              'resources/tamimi.gif', 
                              width: 50.0,
                              height: 50.0,
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No tasks for today'));
                        }

                        List<Task> tasks = snapshot.data!.docs
                            .map((doc) => Task.fromFirestore(doc))
                            .toList();

                        List<Task> todayTasks = _filterAndSortTasksForToday(tasks);
                        List<Task> incompleteTasks = todayTasks.where((task) => !task.isCompleted).toList();
                        List<Task> completedTasks = todayTasks.where((task) => task.isCompleted).toList();

                        if (todayTasks.isEmpty) {
                          return Center(child: Text('No tasks for today'));
                        }

                        return ListView(
                          children: [
                            ...incompleteTasks.map((task) => TaskTile(
                              taskId: task.id,
                              updateTask: (oldTask, newTask) {
                                int taskIndex = tasks.indexOf(oldTask);
                                if (taskIndex != -1) {
                                  setState(() {
                                    tasks[taskIndex] = newTask;
                                  });
                                }
                              },
                            )).toList(),
                            if (completedTasks.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ...completedTasks.map((task) => TaskTile(
                              taskId: task.id,
                              updateTask: (oldTask, newTask) {
                                int taskIndex = tasks.indexOf(oldTask);
                                if (taskIndex != -1) {
                                  setState(() {
                                    tasks[taskIndex] = newTask;
                                  });
                                }
                              },
                            )).toList(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
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

  // Builds a schedule item widget for an event.
  Widget _buildScheduleItem(Event event) {
    final borderSide = _getBorderSide(event.type);
    final textColor = _getTextColor(event.type);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventViewPage(event: event),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 120,
          height: 110,
          decoration: _getScheduleItemDecoration(borderSide),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(event.title, style: TextStyle(color: Color(0xFF31231A))),
                const SizedBox(height: 4.0),
                Text(
                  DateFormat('h:mm a').format(event.dueDate),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  event.type,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Returns the decoration for a schedule item container based on the event type.
  BoxDecoration _getScheduleItemDecoration(BorderSide borderSide) {
    return BoxDecoration(
      color: const Color(0xFFFFFFFF),
      border: Border(
        left: borderSide,
      ),
      borderRadius: BorderRadius.circular(17.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // Returns the border side color for the schedule item based on event type.
  BorderSide _getBorderSide(String type) {
    switch (type) {
      case 'Deadline':
        return const BorderSide(
            color: Color.fromARGB(255, 235, 127, 134), width: 10.0);
      case 'Meeting':
        return const BorderSide(color: Color(0xFF7FA7EB), width: 10.0);
      default:
        return BorderSide.none;
    }
  }

  // Returns the text color for the event type.
  Color _getTextColor(String type) {
    switch (type) {
      case 'Deadline':
        return Colors.red;
      case 'Meeting':
        return Colors.blue;
      default:
        return const Color(0xFF31231A);
    }
  }
}

void onItemTapped(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TraineeCalendarPage()), // Navigate to Calendar page.
      );
      break;
    case 1:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TraineeHomepage()), // Navigate to Home page.
      );
      break;
    case 2:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TaskManagerScreen()), // Navigate to Tasks page.
      );
      break;
    case 3:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()), // Navigate to Profile page.
      );
      break;
  }
}