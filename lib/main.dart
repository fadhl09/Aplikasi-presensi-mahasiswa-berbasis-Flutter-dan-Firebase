import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PresensiMahasiswaApp());
}

class PresensiMahasiswaApp extends StatelessWidget {
  const PresensiMahasiswaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Presensi Mahasiswa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

/// Mempertahankan sesi Firebase. Jika mahasiswa masih login, aplikasi langsung
/// membuka beranda; jika sudah logout, halaman login ditampilkan.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  int _profileRetry = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = authSnapshot.data;
        if (user == null) return const LoginScreen();

        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          key: ValueKey('${user.uid}-$_profileRetry'),
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (profileSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Profil mahasiswa gagal dimuat. Periksa koneksi internet dan aturan Firestore.'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async => FirebaseAuth.instance.signOut(),
                          child: const Text('Kembali ke Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            final data = profileSnapshot.data?.data();
            if (data == null) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Profil sedang disiapkan atau belum ditemukan.'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => setState(() => _profileRetry++),
                          child: const Text('Coba Lagi'),
                        ),
                        TextButton(
                          onPressed: () async => FirebaseAuth.instance.signOut(),
                          child: const Text('Keluar'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            final name = (data['name'] as String?)?.trim();
            return DashboardScreen(studentName: (name == null || name.isEmpty) ? 'Mahasiswa' : name);
          },
        );
      },
    );
  }
}
