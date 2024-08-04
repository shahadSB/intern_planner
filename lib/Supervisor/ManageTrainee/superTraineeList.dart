import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intern_planner/Database/TraineeDetails.dart';
import 'package:intern_planner/Login/login.dart';
import 'package:intern_planner/Supervisor/ManageTrainee/superAddTrainee.dart';
import 'package:intern_planner/Supervisor/ManageTrainee/superTraineeDetails.dart';
import 'package:intern_planner/Widgets/supervisorNav.dart';

// StatefulWidget that displays a list of trainees managed by the current supervisor.
class TraineePage extends StatefulWidget {
  @override
  _TraineePageState createState() => _TraineePageState();
}

class _TraineePageState extends State<TraineePage> {
  User? currentUser; // The currently authenticated user.
  int _selectedIndex = 0; // The index of the selected bottom navigation item.

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // Retrieve the current user on initialization.
  }

  // Retrieves the currently authenticated user from FirebaseAuth.
  Future<void> _getCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
  }

  /* 
    Deletes a trainee from the Firestore database.
    [trainee] is the Trainee object to be deleted. The deletion is performed
    from the collection of trainees associated with the current supervisor.
  */
  void _deleteTrainee(Trainee trainee) async {
    final supervisorId = currentUser?.uid;
    if (supervisorId == null) return;

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('supervisors')
        .doc(supervisorId)
        .collection('trainees')
        .where('id', isEqualTo: trainee.id)
        .get();

    for (var doc in snapshot.docs) {
      await FirebaseFirestore.instance
          .collection('supervisors')
          .doc(supervisorId)
          .collection('trainees')
          .doc(doc.id)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Trainee List',
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
              FirebaseAuth.instance.signOut().then((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              });
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('supervisorId', isEqualTo: currentUser?.uid)
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
              return Center(child: Text('No trainees found.'));
            }

            List<Trainee> trainees = snapshot.data!.docs.map((doc) {
              return Trainee(
                name: doc['name'],
                id: doc.id,
                employeeId: doc['employeeId'],
                email: doc['email'],
                dob: doc['dateOfBirth'],
                supervisorId: '', // Supervisor ID is not needed for this display
              );
            }).toList();

            return ListView.builder(
              itemCount: trainees.length,
              itemBuilder: (context, index) {
                Trainee trainee = trainees[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TraineeListDetailsPage(
                          trainee: trainee,
                          onDelete: _deleteTrainee,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 187, 217, 164),
                        radius: 28,
                        child: Text(
                          trainee.name[0],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                      title: Text(
                        trainee.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color.fromARGB(255, 24, 27, 22),
                        ),
                      ),
                      subtitle: Text(
                        trainee.employeeId,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(255, 176, 176, 176),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: SupervisorNavBar(
        currentIndex: _selectedIndex,
        onItemTapped: (context, index) {
          setState(() {
            _selectedIndex = index;
          });
          onItemTapped(context, index); // Handle bottom navigation item tap
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTraineePage(onAdd: (trainee) {
                // No need to manually add trainee; StreamBuilder will update the list automatically
              }),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 195, 77, 69),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
