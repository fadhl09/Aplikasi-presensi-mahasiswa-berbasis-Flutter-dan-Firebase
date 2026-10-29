import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'attendance_screen.dart';
import 'history_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String studentName;

  const DashboardScreen({
    super.key,
    required this.studentName,
  });

  static const List<_CourseItem> courses = [
    _CourseItem(
      title: 'MOBILE PROGRAMMING',
      subtitle: 'Pengembangan aplikasi mobile',
      icon: Icons.phone_android_rounded,
      color: Color(0xFF3867D6),
    ),
    _CourseItem(
      title: 'NUMERICAL METHODS',
      subtitle: 'Metode numerik dan perhitungan',
      icon: Icons.functions_rounded,
      color: Color(0xFF0F9D8A),
    ),
    _CourseItem(
      title: 'DATA STRUCTURE PRACTICUM',
      subtitle: 'Praktik struktur data',
      icon: Icons.account_tree_rounded,
      color: Color(0xFF8B5CF6),
    ),
    _CourseItem(
      title: 'FILSAFAT ILMU',
      subtitle: 'Dasar pemikiran dan filsafat ilmu',
      icon: Icons.psychology_alt_rounded,
      color: Color(0xFFEA8A24),
    ),
    _CourseItem(
      title: 'COMPUTER SYSTEM',
      subtitle: 'Konsep dan arsitektur sistem komputer',
      icon: Icons.computer_rounded,
      color: Color(0xFF168AAD),
    ),
    _CourseItem(
      title: 'COMPUTER SYSTEM PRACTICUM',
      subtitle: 'Praktik sistem komputer',
      icon: Icons.memory_rounded,
      color: Color(0xFFB45309),
    ),
    _CourseItem(
      title: 'TEOSOFI',
      subtitle: 'Mata kuliah Teosofi',
      icon: Icons.auto_stories_rounded,
      color: Color(0xFF7C3AED),
    ),
    _CourseItem(
      title: 'STATISTICS',
      subtitle: 'Statistik dan analisis data',
      icon: Icons.bar_chart_rounded,
      color: Color(0xFF0D9488),
    ),
    _CourseItem(
      title: 'STUDI FIQIH',
      subtitle: 'Kajian dasar fiqih',
      icon: Icons.menu_book_rounded,
      color: Color(0xFFCA6F1E),
    ),
    _CourseItem(
      title: 'DATA STRUCTURE',
      subtitle: 'Konsep struktur data',
      icon: Icons.account_tree_rounded,
      color: Color(0xFF4F46E5),
    ),
    _CourseItem(
      title: 'BAHASA INGGRIS UMUM',
      subtitle: 'Pembelajaran bahasa Inggris',
      icon: Icons.translate_rounded,
      color: Color(0xFFDB2777),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.fact_check_rounded, color: Color(0xFF2457C5)),
            SizedBox(width: 9),
            Text(
              'Presensi Mahasiswa',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              tooltip: 'Detail akun',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2457C5),
              ),
              icon: const Icon(Icons.person_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Riwayat presensi',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2457C5),
              ),
              icon: const Icon(Icons.history_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2457C5), Color(0xFF4D82F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2457C5).withValues(alpha: 0.20),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.waving_hand_rounded,
                            size: 15, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Selamat datang',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    studentName.trim().isEmpty ? 'Halo, Mahasiswa!' : 'Halo, $studentName!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Siap mengikuti perkuliahan hari ini? Pilih mata kuliah untuk mulai presensi.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            color: Colors.white, size: 23),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Presensi menggunakan lokasi GPS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Icon(Icons.verified_user_rounded,
                            color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mata Kuliah',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF172B4D),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Pilih mata kuliah yang ingin kamu hadiri',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EDFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${courses.length} mata kuliah',
                    style: const TextStyle(
                      color: Color(0xFF2457C5),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ...courses.map((course) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttendanceScreen(
                              studentName: studentName,
                              course: course.title,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE9EDF5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: course.color.withValues(alpha: 0.11),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                course.icon,
                                color: course.color,
                                size: 27,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.title,
                                    style: const TextStyle(
                                      color: Color(0xFF172B4D),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    course.subtitle,
                                    style: const TextStyle(
                                      color: Color(0xFF718096),
                                      fontSize: 12,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.location_on_outlined,
                                          size: 14, color: course.color),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Presensi GPS',
                                        style: TextStyle(
                                          color: course.color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF2F5FA),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Color(0xFF52627A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF7E7B7)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Color(0xFF9A6A12), size: 21),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pastikan GPS aktif dan izinkan akses lokasi agar presensi dapat diproses.',
                      style: TextStyle(
                        color: Color(0xFF7A5A1A),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _CourseItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
