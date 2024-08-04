import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intern_planner/Database/Task.dart';
import 'package:intern_planner/Login/login.dart';
import 'package:intern_planner/Trainee/TaskPage/addTask.dart';
import 'package:intern_planner/Trainee/TaskPage/taskTile.dart';
import 'package:intern_planner/Widgets/traineeNav.dart';

// A StatefulWidget that manages and displays the tasks for a trainee.
class TaskManagerScreen extends StatefulWidget {
  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  List<Task> tasks = [];
  User? currentUser;
  int _selectedIndex = 2;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Gets the currently authenticated user and starts listening for tasks.
  void _getCurrentUser() {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _listenForTasks();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Listens for real-time updates to the tasks collection in Firestore.
  void _listenForTasks() {
    FirebaseFirestore.instance
        .collection('tasks')
        .where('traineeId', isEqualTo: currentUser?.uid)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        tasks = snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
        tasks = _sortTasksByPriorityAndCompletion(tasks);
        isLoading = false;
      });
    });
  }

  /// Fetches the tasks for the currently authenticated user from Firestore.
  Future<void> _fetchTasks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('traineeId', isEqualTo: currentUser?.uid)
          .get();

      setState(() {
        tasks = snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
        tasks = _sortTasksByPriorityAndCompletion(tasks);
        isLoading = false;
      });
      print(tasks);
    } catch (e) {
      print('Error fetching tasks: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Sorts the tasks by priority and completion status.
  List<Task> _sortTasksByPriorityAndCompletion(List<Task> tasks) {
    // Priority mapping
    Map<String, int> priorityMapping = {
      'High': 1,
      'Medium': 2,
      'Low': 3,
    };

    // Sort by completion status, then by priority, then by due date
    tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      int priorityComparison = priorityMapping[a.priority]!.compareTo(priorityMapping[b.priority]!);
      if (priorityComparison != 0) {
        return priorityComparison;
      } else {
        return a.dueDate.compareTo(b.dueDate);
      }
    });

    return tasks;
  }

  // Shows an information dialog explaining the red mark indicating overdue tasks.
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help'),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.circle, color: Colors.red, size: 20.0),
            const SizedBox(width: 10.0),
            Expanded(
              child: const Text(
                'This red mark indicates that the task has exceeded the deadline.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incompleteTasks = tasks.where((task) => !task.isCompleted).toList();
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Tasks',
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
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
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
        child: Center(
          child: isLoading
              ? Image.asset(
                  'resources/tamimi.gif',
                  width: 50.0,
                  height: 50.0,
                )
              : ListView(
                  children: [
                    ...incompleteTasks.map((task) => TaskTile(
                      taskId: task.id,
                      updateTask: _updateTask,
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
                      updateTask: _updateTask,
                    )).toList(),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddTaskPage(currentUser: currentUser),
          ).then((newTask) {
            if (newTask != null) {
              _fetchTasks();
            }
          });
        },
        backgroundColor: const Color.fromARGB(255, 217, 86, 74),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
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

  // Method to update a task in the list.
  void _updateTask(Task oldTask, Task newTask) {
    setState(() {
      int index = tasks.indexOf(oldTask);
      if (index != -1) {
        tasks[index] = newTask;
        tasks = _sortTasksByPriorityAndCompletion(tasks); // Re-sort tasks after update
      }
    });
  }
}
