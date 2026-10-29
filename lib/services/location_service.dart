import 'package:geolocator/geolocator.dart';

class LocationService {
  // Mengambil lokasi HP saat ini
  static Future<Position> getCurrentLocation() async {
    // 1. Cek apakah GPS aktif
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'GPS belum aktif. Silakan aktifkan lokasi.',
      );
    }

    // 2. Cek izin lokasi
    LocationPermission permission =
        await Geolocator.checkPermission();

    // 3. Kalau izin belum diberikan
    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception(
          'Izin lokasi ditolak.',
        );
      }
    }

    // 4. Kalau izin ditolak permanen
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak permanen. '
        'Aktifkan izin lokasi melalui Settings.',
      );
    }

    // 5. Ambil posisi sekarang
    Position position =
        await Geolocator.getCurrentPosition();

    return position;
  }

  // Menghitung jarak antara 2 lokasi
  static double calculateDistance(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    return Geolocator.distanceBetween(
      latitude1,
      longitude1,
      latitude2,
      longitude2,
    );
  }
}