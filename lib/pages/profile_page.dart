import 'package:flutter/material.dart';
import 'dart:async';  
import 'package:geolocator/geolocator.dart';
import '../services/hive_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _locationText;
  bool _locLoading = false;

  final Color _bgColor = const Color(0xFFFFF7F0);
  final Color _primary = const Color(0xFFFFB074);

  @override
  Widget build(BuildContext context) {
    final name = HiveService.getUserName();
    final email = HiveService.getUserEmail();
    final offset = DateTime.now().timeZoneOffset.inHours;

    String zona = 'Zona lain';
    if (offset == 7) zona = 'WIB';
    if (offset == 8) zona = 'WITA';
    if (offset == 9) zona = 'WIT';

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: const Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(email),
            const SizedBox(height: 8),
            Text('Zona waktu perangkat: $zona (UTC$offset)'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Lokasi Saat Ini'),
              subtitle: Text(
                _locationText ??
                    'Belum diambil. Ketuk baris ini untuk mengambil lokasi.',
              ),
              onTap: _locLoading ? null : _getLocation,
              trailing: _locLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: () {
                  HiveService.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getLocation() async {
  setState(() {
    _locLoading = true;
  });

  try {
    // 1. cek dulu apakah layanan lokasi aktif
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locLoading = false;
        _locationText =
            'Layanan lokasi nonaktif. Aktifkan GPS / Location di perangkat/emulator.';
      });
      return;
    }

    // 2. cek & minta izin runtime
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      setState(() {
        _locLoading = false;
        _locationText =
            'Izin lokasi ditolak. Buka pengaturan dan izinkan akses lokasi.';
      });
      return;
    }

    // 3. ambil posisi dengan timeout 10 detik
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).timeout(const Duration(seconds: 10));

    setState(() {
      _locLoading = false;
      _locationText =
          'Lat: ${pos.latitude.toStringAsFixed(4)}, Lng: ${pos.longitude.toStringAsFixed(4)}';
    });
  } on TimeoutException {
    setState(() {
      _locLoading = false;
      _locationText = 'Gagal mengambil lokasi (timeout). Coba lagi.';
    });
  } catch (e) {
    setState(() {
      _locLoading = false;
      _locationText = 'Terjadi error lokasi: $e';
    });
  }
}
}
