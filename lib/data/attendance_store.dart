import '../models/attendance.dart';

class AttendanceStore {
  static final List<Attendance> attendances = [];

  static void addAttendance(Attendance attendance) {
    attendances.add(attendance);
  }

  static List<Attendance> getAll() {
    return List.unmodifiable(attendances);
  }
}