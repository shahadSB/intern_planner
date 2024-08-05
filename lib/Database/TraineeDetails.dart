/* 
  Represents a trainee with various details including name, 
  ID, email, date of birth, and supervisor information.
*/

class Trainee {
  late final String name;
  final String id;
  final String employeeId;
  late final String email;
  final String dob;
  late final String supervisorId;


  /* 
    Creates a new Trainee instance with the given details.
    All parameters are required.
  */
  Trainee({
    required this.name,
    required this.id,
    required this.employeeId,
    required this.email,
    required this.dob,
    required this.supervisorId,
  });
}
