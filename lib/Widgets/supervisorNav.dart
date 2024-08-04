import 'package:flutter/material.dart';
import 'package:intern_planner/Supervisor/ManageTrainee/superTraineeList.dart';
import 'package:intern_planner/Supervisor/superHomepage.dart';
import 'package:intern_planner/Supervisor/superProfile.dart';

/*
  This widget provides navigation options for the supervisor, including:
    - Trainee List
    - Calendar
    - Settings
  The [currentIndex] parameter determines the currently selected tab,
  and the [onItemTapped] callback function is invoked when a tab is tapped.
*/
class SupervisorNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(BuildContext, int) onItemTapped; 

  /*
    Constructor for the SupervisorNavBar:
    Takes the [currentIndex] to highlight the selected tab and the [onItemTapped]
    callback function to handle navigation.
  */
  SupervisorNavBar({
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white, 
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_2), 
          label: 'Trainee List', 
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home), 
          label: 'Calendar', 
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings), 
          label: 'Settings',
        ),
      ],
      currentIndex: currentIndex, // Currently selected tab index.
      selectedItemColor: Color.fromARGB(255, 70, 24, 20), // Color for selected tab.
      unselectedItemColor: Colors.grey, // Color for unselected tabs.
      showSelectedLabels: false, // Hide labels for selected tabs.
      showUnselectedLabels: false, // Hide labels for unselected tabs.
      onTap: (index) => onItemTapped(context, index), // Pass context and index.
    );
  }
}

/*
  Handles navigation for the SupervisorNavBar: 
  This function takes the [context] and [index] as parameters and
  navigates to the corresponding page based on the index.
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
        MaterialPageRoute(builder: (context) => Supervisorprofile()), // Navigate to Supervisor Profile page.
      );
      break;
  }
}
