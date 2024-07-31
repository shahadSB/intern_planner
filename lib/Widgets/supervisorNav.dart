import 'package:flutter/material.dart';
import 'package:intern_planner/Supervisor/ManageTrainee/superTraineeList.dart';
import 'package:intern_planner/Supervisor/superHomepage.dart';
import 'package:intern_planner/Supervisor/superProfile.dart';

/* 
  This widget provides navigation options for the supervisor, including Trainee List,
  Calendar, and Settings. The (currentIndex) determines the currently selected
  tab, and (onItemTapped) is the callback function invoked when a tab is tapped.
*/
class SupervisorNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  SupervisorNavBar({
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white, // Background color of the navigation bar.
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_2), // Icon for Trainee List tab.
          label: 'Trainee List', // Label for Trainee List tab.
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home), // Icon for Calendar tab.
          label: 'Calendar', // Label for Calendar tab.
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings), // Icon for Settings tab.
          label: 'Settings', // Label for Settings tab.
        ),
      ],
      currentIndex: currentIndex, // Currently selected tab index.
      selectedItemColor: Color.fromARGB(255, 70, 24, 20), // Color for selected tab.
      unselectedItemColor: Colors.grey, // Color for unselected tabs.
      showSelectedLabels: false, // Hide labels for selected tabs.
      showUnselectedLabels: false, // Hide labels for unselected tabs.
      onTap: (index) => onItemTapped(index), // Callback for tab item tap events.
    );
  }
}

/*
  Handles navigation to different pages based on the selected tab index.
  - context: is the BuildContext used to navigate between pages.
  - index: determines which page to navigate to based on the selected tab.
*/

void onItemTapped(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TraineePage()), // Navigate to Trainee List page.
      );
      break;
    case 1:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CalendarPage()), // Navigate to Calendar page.
      );
      break;
    case 2:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Supervisorprofile()), // Navigate to Settings page.
      );
      break;
  }
}
