import 'dart:io';
import 'dart:typed_data'; // Import untuk Uint8List
import 'package:absensi_apps/config/app_asset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Untuk membaca file dari assets
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Import MediaType

void main() {
  runApp(AbsensiApp());
}

class AbsensiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AbsensiScreen(),
    );
  }
}

class AbsensiScreen extends StatefulWidget {
  @override
  _AbsensiScreenState createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  File? _foto;
  bool _isLoading = false;
  Uint8List? _fotoBytes;

  // Mengambil foto dari assets
  Future<void> _getFotoFromAssets() async {
    final ByteData bytes = await rootBundle.load(AppAsset.logo);
    final Uint8List imageBytes = bytes.buffer.asUint8List();  // Mengubah menjadi Uint8List
    
    setState(() {
      _fotoBytes = imageBytes; // Menyimpan gambar sebagai byte array
    });
  }

  // Mengirim data absensi ke API
  Future<void> _submitAbsensi() async {
    if (_fotoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pastikan foto sudah diambil!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });







    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://1462-36-69-143-50.ngrok-free.app/api/absensi'), // Ganti dengan URL API Laravel Anda
      );

      // Isi data absensi
      request.fields['user_id'] = '1'; // Ganti dengan ID user yang valid
      request.fields['latitude'] = '-6.200000'; // Data dummy latitude
      request.fields['longitude'] = '106.816666'; // Data dummy longitude

      // Kirim foto dari assets
      request.files.add(http.MultipartFile.fromBytes(
        'foto',
        _fotoBytes!,
        filename: AppAsset.logo, // Nama file saat dikirim
        contentType: MediaType('image', 'jpeg'), // Menentukan tipe media
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Absensi berhasil!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal melakukan absensi!')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan!')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Absensi Masuk'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Jika foto sudah diambil, tampilkan dengan Image.memory (untuk Web)
            if (_fotoBytes != null)
              Image.memory(
                _fotoBytes!,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getFotoFromAssets, // Ambil foto dari assets
              child: Text('Ambil Foto (Dari Assets)'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitAbsensi,
                    child: Text('Kirim Absensi'),
                  ),
          ],
        ),
      ),
    );
  }
}
