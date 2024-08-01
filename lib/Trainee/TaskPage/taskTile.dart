import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intern_planner/Database/Task.dart';
import 'package:intern_planner/Trainee/TaskPage/editTask.dart';

/*
  A widget that displays a task tile with task details fetched from Firestore.
  The [TaskTile] widget fetches task details from Firestore using the provided
  [taskId] and displays the task information in a styled container. The task
  can be edited by tapping on the tile, which navigates to the [EditTaskPage].
  The [updateTask] callback is used to update the task in the parent widget
  after editing.
*/
class TaskTile extends StatelessWidget {
  final String taskId;
  final Function(Task, Task) updateTask;

  TaskTile({required this.taskId, required this.updateTask});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('tasks').doc(taskId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text(' '),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return ListTile(
            title: Text('Task not found'),
          );
        }

        Task task = Task.fromFirestore(snapshot.data!);
        bool isExpired = task.dueDate.isBefore(DateTime.now());
        bool showExpiredIndicator = !task.isCompleted && isExpired;

        return GestureDetector(
          onTap: () async {
            Task? editedTask = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTaskPage(task: task),
              ),
            );
            if (editedTask != null) {
              updateTask(task, editedTask);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showExpiredIndicator)
                      Icon(Icons.circle, color: Colors.red, size: 10.0),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6.0),
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          Text(
                            task.priority,
                            style: TextStyle(
                              color: _getPriorityColor(task.priority),
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) async {
                            Task updatedTask = Task(
                              id: task.id,
                              title: task.title,
                              priority: task.priority,
                              dueDate: task.dueDate,
                              isCompleted: value ?? false,
                            );
                            updateTask(task, updatedTask);
                            // Update the task in Firestore
                            await FirebaseFirestore.instance
                                .collection('tasks')
                                .doc(task.id)
                                .update({'isCompleted': value});
                          },
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          '${task.dueDate.toString().substring(0, 16)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /* 
    Returns a color based on the priority of the task.
    [priority] is the priority level of the task ('High', 'Medium', 'Low').
  */
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color.fromARGB(255, 155, 18, 8);
      case 'Medium':
        return const Color.fromARGB(255, 209, 125, 16);
      case 'Low':
        return const Color.fromARGB(255, 39, 125, 36);
      default:
        return Colors.grey;
    }
  }
}
