import 'dart:io';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AbsensiApp());
}

class AbsensiApp extends StatelessWidget {
  const AbsensiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AbsensiScreen(),
    );
  }
}

class AbsensiScreen extends StatefulWidget {
  const AbsensiScreen({Key? key}) : super(key: key);

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  LocationData? _locationData;
  File? _foto;
  bool _isLoading = false;

  /// Mengambil lokasi pengguna
  Future<void> _getLocation() async {
    final location = Location();

    if (!await location.serviceEnabled() && !await location.requestService()) {
      return;
    }

    if (await location.hasPermission() == PermissionStatus.denied &&
        await location.requestPermission() != PermissionStatus.granted) {
      return;
    }

    final locationData = await location.getLocation();
    setState(() {
      _locationData = locationData;
    });
  }

  /// Mengambil foto menggunakan kamera
  Future<void> _getPhoto() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _foto = File(pickedFile.path);
      });
    }
  }

  /// Mengirim data absensi ke API
  Future<void> _submitAbsensi() async {
    if (_locationData == null || _foto == null) {
      _showSnackBar('Pastikan lokasi dan foto sudah diambil!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://1462-36-69-143-50.ngrok-free.app/api/absensi'), // Sesuaikan URL API Anda
      )
        ..fields['user_id'] = '1' // Ganti sesuai user ID dari sistem Anda
        ..fields['latitude'] = _locationData!.latitude.toString()
        ..fields['longitude'] = _locationData!.longitude.toString()
        ..files.add(await http.MultipartFile.fromPath('foto', _foto!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        _showSnackBar('Absensi berhasil!');
      } else {
        _showSnackBar('Gagal melakukan absensi!');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan!');
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Menampilkan pesan snack bar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Masuk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_locationData != null)
              Text(
                'Lokasi: ${_locationData!.latitude}, ${_locationData!.longitude}',
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getLocation,
              child: const Text('Ambil Lokasi'),
            ),
            const SizedBox(height: 20),
            if (_foto != null)
              Image.file(
                _foto!,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ElevatedButton(
              onPressed: _getPhoto,
              child: const Text('Ambil Foto'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitAbsensi,
                    child: const Text('Kirim Absensi'),
                  ),
          ],
        ),
      ),
    );
  }
}