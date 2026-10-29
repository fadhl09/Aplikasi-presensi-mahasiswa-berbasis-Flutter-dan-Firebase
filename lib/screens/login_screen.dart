import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _isLoading = false;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final nim = _nimController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email dan password wajib diisi.');
      return;
    }
    if (_isRegisterMode && (name.isEmpty || nim.isEmpty)) {
      _showMessage('Nama lengkap dan NIM wajib diisi saat mendaftar.');
      return;
    }
    if (_isRegisterMode && password.length < 6) {
      _showMessage('Password minimal 6 karakter.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential credential;
      if (_isRegisterMode) {
        credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = credential.user!;
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'nim': nim,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        _showMessage('Pendaftaran berhasil. Sesi login aktif.');
      } else {
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = credential.user!;
        final profileRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final profile = await profileRef.get();

        if (!profile.exists) {
          await FirebaseAuth.instance.signOut();
          _showMessage(
            'Profil mahasiswa untuk akun ini belum ditemukan. Silakan daftar akun baru atau hubungi admin.',
          );
          return;
        }
        // AuthGate akan mendeteksi sesi aktif dan membuka beranda secara otomatis.
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code}');
      debugPrint('Firebase Auth Message: ${e.message}');

      
      if (e.code == 'email-already-in-use') {
        _showMessage('Email sudah terdaftar. Silakan masuk.');
      } else if (e.code == 'weak-password') {
        _showMessage('Password terlalu lemah. Gunakan minimal 6 karakter.');
      } else if (e.code == 'invalid-email') {
        _showMessage('Format email tidak valid.');
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        _showMessage('Email atau password salah.');
      } else {
        _showMessage(e.message ?? 'Autentikasi gagal. Coba lagi.');
      }
    } catch (e) {
      _showMessage('Terjadi kesalahan. Periksa koneksi dan aturan Firestore.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  const Icon(Icons.school_rounded, size: 82, color: Colors.blue),
                  const SizedBox(height: 18),
                  const Text(
                    'Presensi Mahasiswa',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRegisterMode
                        ? 'Buat akun dan lengkapi identitas mahasiswa'
                        : 'Login untuk melanjutkan presensi',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  if (_isRegisterMode) ...[
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _nimController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'NIM',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _isRegisterMode ? 'DAFTAR' : 'LOGIN',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(
                              () => _isRegisterMode = !_isRegisterMode,
                            ),
                    child: Text(
                      _isRegisterMode
                          ? 'Sudah punya akun? Login'
                          : 'Belum punya akun? Daftar mahasiswa',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
