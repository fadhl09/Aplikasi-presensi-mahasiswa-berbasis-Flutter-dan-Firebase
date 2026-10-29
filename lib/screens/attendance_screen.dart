
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../services/location_service.dart';

class AttendanceScreen extends StatefulWidget {
  final String studentName;
  final String course;

  const AttendanceScreen({
    super.key,
    required this.studentName,
    required this.course,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool isLoading = false;
  XFile? selfie;

  static const double campusLatitude = -7.950000;
  static const double campusLongitude = 112.610000;
  static const double maximumDistance = 1000;

  Future<void> takeSelfie() async {
    if (isLoading) return;

    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 75,
      );

      if (!mounted || photo == null) return;

      setState(() => selfie = photo);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka kamera: $error')),
      );
    }
  }

  Future<void> doAttendance() async {
    if (isLoading) return;

    if (selfie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ambil selfie terlebih dahulu.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Silakan login terlebih dahulu.');
      }

      // Periksa lokasi HP.
      final position = await LocationService.getCurrentLocation();

      final distance = LocationService.calculateDistance(
        position.latitude,
        position.longitude,
        campusLatitude,
        campusLongitude,
      );

      if (distance > maximumDistance) {
        if (!mounted) return;

        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Presensi Ditolak'),
            content: Text(
              'Lokasi terlalu jauh dari lokasi perkuliahan.\n\n'
              'Jarak: ${distance.toStringAsFixed(2)} meter\n'
              'Batas: $maximumDistance meter',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final profileData = profile.data() ?? {};
      final name = (profileData['nama'] ??
              profileData['name'] ??
              widget.studentName)
          .toString();
      final nim = (profileData['nim'] ?? '').toString();

      final now = DateTime.now();
      final dateKey =
          '${now.year.toString().padLeft(4, '0')}'
          '${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}';

      final courseKey = base64Url
          .encode(utf8.encode(widget.course))
          .replaceAll('=', '');

      final docId = '${user.uid}_${courseKey}_$dateKey';
      final attendanceRef = FirebaseFirestore.instance
          .collection('presensi')
          .doc(docId);

      final result = await FirebaseFirestore.instance
          .runTransaction<String>((transaction) async {
        final existing = await transaction.get(attendanceRef);

        if (existing.exists) {
          return 'duplicate';
        }

        transaction.set(attendanceRef, {
          'uid': user.uid,
          'nama': name,
          'nim': nim,
          'mataKuliah': widget.course,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'jarak': distance,
          'status': 'Hadir',
          'waktu': FieldValue.serverTimestamp(),
          'tanggal': dateKey,

          // Foto tetap berada di HP, bukan di Firebase.
          'fotoNamaFile': selfie!.name,
          'fotoLokal': true,
        });

        return 'success';
      });

      if (!mounted) return;

      if (result == 'duplicate') {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sudah Presensi'),
            content: Text(
              'Kamu sudah presensi ${widget.course} hari ini.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Presensi Berhasil'),
          content: Text(
            'Presensi berhasil disimpan ke Firebase.\n\n'
            'Mata kuliah: ${widget.course}\n'
            'Jarak: ${distance.toStringAsFixed(2)} meter\n'
            'Bukti selfie diambil: ${selfie!.name}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('FIREBASE ERROR CODE: ${error.code}');
      debugPrint('FIREBASE ERROR MESSAGE: ${error.message}');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase: ${error.code}')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.location_on,
              size: 75,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            const Text(
              'Presensi Mata Kuliah',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Nama Mahasiswa',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.studentName),
                    const SizedBox(height: 12),
                    const Text(
                      'Mata Kuliah',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.course),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bukti foto selfie',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: selfie == null
                    ? const Icon(
                        Icons.account_circle,
                        size: 110,
                        color: Colors.grey,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(selfie!.path),
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: isLoading ? null : takeSelfie,
              icon: const Icon(Icons.camera_alt),
              label: Text(
                selfie == null ? 'AMBIL SELFIE' : 'ULANGI SELFIE',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : doAttendance,
                icon: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  isLoading
                      ? 'Menyimpan Presensi...'
                      : 'KONFIRMASI PRESENSI',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
