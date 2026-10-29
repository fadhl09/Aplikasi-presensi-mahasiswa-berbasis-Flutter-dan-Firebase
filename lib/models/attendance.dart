class Attendance {
  final String studentName;
  final String course;
  final DateTime dateTime;
  final double latitude;
  final double longitude;
  final double distance;
  final String status;

  Attendance({
    required this.studentName,
    required this.course,
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.status,
  });
}