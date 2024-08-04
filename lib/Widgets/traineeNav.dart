import 'package:flutter/material.dart';
import 'package:intern_planner/Trainee/TaskPage/taskList.dart';
import 'package:intern_planner/Trainee/traineeCalendar.dart';
import 'package:intern_planner/Trainee/traineeHomepage.dart';
import 'package:intern_planner/Trainee/traineeProfile.dart';

/*
  This widget provides navigation options for the trainee, including Calendar,
  Home, Tasks, and Settings. The [currentIndex] parameter determines the currently
  selected tab, and the [onItemTapped] callback function is invoked when a tab is tapped.
*/
class TraineeNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(BuildContext, int) onItemTapped; 

  /*
    Constructor for the TraineeNavigationBar:
    Takes the [currentIndex] to highlight the selected tab and the [onItemTapped]
    callback function to handle navigation.
  */
  TraineeNavigationBar({
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white, // Background color of the navigation bar.
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month), // Icon for Calendar tab.
          label: 'Calendar', // Label for Calendar tab.
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home), // Icon for Home tab.
          label: 'Home', // Label for Home tab.
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task_alt_rounded), // Icon for Tasks tab.
          label: 'Tasks', // Label for Tasks tab.
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings), // Icon for Settings tab.
          label: 'Settings', // Label for Settings tab.
        ),
      ],
      currentIndex: currentIndex, // Currently selected tab index.
      selectedItemColor: const Color.fromARGB(255, 70, 24, 20), // Color for selected tab.
      unselectedItemColor: Colors.grey, // Color for unselected tabs.
      showSelectedLabels: false, // Hide labels for selected tabs.
      showUnselectedLabels: false, // Hide labels for unselected tabs.
      onTap: (index) => onItemTapped(context, index), // Pass context and index.
    );
  }
}

/*
  Handles navigation for the TraineeNavigationBar: 
  This function takes the [context] and [index] as parameters and
  navigates to the corresponding page based on the index.
*/
void onItemTapped(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TraineeCalendarPage()), // Navigate to Calendar page.
      );
      break;
    case 1:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TraineeHomepage()), // Navigate to Home page.
      );
      break;
    case 2:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TaskManagerScreen()), // Navigate to Tasks page.
      );
      break;
    case 3:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()), // Navigate to Profile page.
      );
      break;
  }
}
