import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Sesi login tidak ditemukan.')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Detail Akun', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2457C5),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data?.data() ?? <String, dynamic>{};
          final name = (data['name'] as String?)?.trim() ?? 'Belum diisi';
          final nim = (data['nim'] as String?)?.trim() ?? 'Belum diisi';
          final email = user.email ?? (data['email'] as String? ?? '-');

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2457C5), Color(0xFF4D82F0)]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(children: [
                  const CircleAvatar(radius: 42, backgroundColor: Colors.white,
                    child: Icon(Icons.person_rounded, size: 52, color: Color(0xFF2457C5))),
                  const SizedBox(height: 14),
                  Text(name, textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('NIM: $nim', style: const TextStyle(color: Colors.white, fontSize: 15)),
                ]),
              ),
              const SizedBox(height: 22),
              const Text('Informasi Akun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF172B4D))),
              const SizedBox(height: 12),
              _infoTile(Icons.person_outline, 'Nama Mahasiswa', name, locked: true),
              _infoTile(Icons.badge_outlined, 'NIM', nim, locked: true),
              _infoTile(Icons.email_outlined, 'Email', email),
              const SizedBox(height: 24),
              const Text('Pengaturan Akun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF172B4D))),
              const SizedBox(height: 12),
              Card(
                color: Colors.white,
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.lock_reset_rounded)),
                  title: const Text('Ganti Password'),
                  subtitle: const Text('Perbarui kata sandi akun'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePassword(context),
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.all(14)),
                icon: const Icon(Icons.logout_rounded), label: const Text('Keluar'),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // AuthGate akan menampilkan halaman login setelah sesi berakhir.
                },
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _infoTile(IconData icon, String label, String value, {bool locked = false}) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2457C5)),
        title: Text(label, style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text(value, style: const TextStyle(fontSize: 16, color: Color(0xFF172B4D)))),
        trailing: locked ? const Icon(Icons.lock_outline, color: Colors.blueGrey, size: 19) : null,
      ),
    );
  }

  static Future<void> _showChangePassword(BuildContext parentContext) async {
    final changed = await showDialog<bool>(
      context: parentContext,
      barrierDismissible: false,
      builder: (_) => const _ChangePasswordDialog(),
    );

    if (!parentContext.mounted) return;
    if (changed == true) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        const SnackBar(content: Text('Password berhasil diganti.')),
      );
    }
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _errorMessage;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      if (user == null || email == null || email.isEmpty) {
        setState(() {
          _busy = false;
          _errorMessage = 'Email login Firebase tidak ditemukan. Keluar lalu masuk kembali.';
        });
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: _current.text,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_next.text);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
        case 'user-mismatch':
          message = 'Password saat ini tidak cocok dengan password akun Firebase. Masukkan password yang dipakai saat daftar/login.';
          break;
        case 'requires-recent-login':
          message = 'Sesi login sudah lama. Keluar dari akun, login kembali, lalu coba lagi.';
          break;
        case 'weak-password':
          message = 'Password baru terlalu lemah. Gunakan minimal 6 karakter.';
          break;
        case 'network-request-failed':
          message = 'Koneksi internet bermasalah. Periksa internet lalu coba lagi.';
          break;
        default:
          message = 'Gagal mengganti password (${e.code}): ${e.message ?? 'Silakan coba lagi.'}';
      }
      if (!mounted) return;
      setState(() {
        _busy = false;
        _errorMessage = message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _errorMessage = 'Terjadi kesalahan. Periksa koneksi dan coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ganti Password'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _current,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(labelText: 'Password saat ini'),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _next,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(labelText: 'Password baru'),
                validator: (v) {
                  if (v == null || v.length < 6) return 'Minimal 6 karakter';
                  if (v == _current.text) return 'Password baru harus berbeda';
                  return null;
                },
              ),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(labelText: 'Ulangi password baru'),
                validator: (v) => v != _next.text ? 'Password tidak sama' : null,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red),),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _busy ? null : _savePassword,
          child: _busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
