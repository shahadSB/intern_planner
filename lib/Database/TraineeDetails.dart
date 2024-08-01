// import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Trainee {
  late final String name;
  final String id;
  final String employeeId;
  late final String email;
  final String dob;
  late final String supervisorId;

  Trainee({
    required this.name,
    required this.id,
    required this.employeeId,
    required this.email,
    required this.dob,
    required this.supervisorId,
  });
}

Future<User?> getCurrentUser() async {
  try {
    return FirebaseAuth.instance.currentUser;
  } catch (e) {
    print('Error fetching current user: $e');
    return null;
  }
}

Future<void> fetchTraineeDetails(
  String currentUserId,
  Function(Trainee trainee) onSuccess,
  Function(String error) onError,
) async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final supervisorId = data['supervisorId'] ?? '';

      final trainee = Trainee(
        name: data['name'] ?? '',
        id: data['employeeId'] ?? '',
        employeeId: data['employeeId'] ?? '',
        email: data['email'] ?? '',
        dob: data['dateOfBirth'] != null
            ? DateFormat('yyyy-MM-dd').format(DateTime.parse(data['dateOfBirth']))
            : '',
        supervisorId: supervisorId,
      );

      onSuccess(trainee);
    } else {
      onError('Trainee not found');
    }
  } catch (e) {
    onError('Error fetching trainee details: $e');
  }
}

Future<void> fetchSupervisorName(
  String supervisorId,
  Function(String supervisorName) onSuccess,
  Function(String error) onError,
) async {
  try {
    DocumentSnapshot supervisorDoc = await FirebaseFirestore.instance
        .collection('SupVisUsers') // Ensure this is the correct collection name
        .doc(supervisorId)
        .get();

    if (supervisorDoc.exists) {
      final supervisorData = supervisorDoc.data() as Map<String, dynamic>;
      onSuccess(supervisorData['Name'] ?? 'Not Assigned Yet');
    } else {
      onSuccess('Not Available');
    }
  } catch (e) {
    onError('Error fetching supervisor details: $e');
  }
}

// class TraineeDetailsPage extends StatefulWidget {
//   @override
//   _TraineeDetailsPageState createState() => _TraineeDetailsPageState();
// }

// class _TraineeDetailsPageState extends State<TraineeDetailsPage> {
//   Trainee? _trainee;
//   String _supervisorName = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadTraineeDetails();
//   }

//   Future<void> _loadTraineeDetails() async {
//     User? user = await getCurrentUser();
//     if (user != null) {
//       fetchTraineeDetails(
//         user.uid,
//         (trainee) {
//           setState(() {
//             _trainee = trainee;
//           });
//           _loadSupervisorName(trainee.supervisorId);
//         },
//         (error) {
//           // Handle error
//           print(error);
//         },
//       );
//     }
//   }

//   Future<void> _loadSupervisorName(String supervisorId) async {
//     fetchSupervisorName(
//       supervisorId,
//       (supervisorName) {
//         setState(() {
//           _supervisorName = supervisorName;
//         });
//       },
//       (error) {
//         // Handle error
//         print(error);
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Trainee Details'),
//       ),
//       body: _trainee == null
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Name: ${_trainee!.name}'),
//                   Text('Employee ID: ${_trainee!.employeeId}'),
//                   Text('Email: ${_trainee!.email}'),
//                   Text('Date of Birth: ${_trainee!.dob}'),
//                   Text('Supervisor: $_supervisorName'),
//                 ],
//               ),
//             ),
//     );
//   }
// }
