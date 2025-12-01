import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/hive_service.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _asalCtrl = TextEditingController();
  final TextEditingController _deskripsiCtrl = TextEditingController();
  final TextEditingController _porsiCtrl = TextEditingController();
  final TextEditingController _waktuCtrl = TextEditingController();
  final TextEditingController _fotoCtrl = TextEditingController();
  final TextEditingController _bahanCtrl = TextEditingController();
  final TextEditingController _langkahCtrl = TextEditingController();

  final Color _primary = const Color(0xFFFFB074);

  void _save() {
    if (_namaCtrl.text.isEmpty ||
        _deskripsiCtrl.text.isEmpty ||
        _fotoCtrl.text.isEmpty ||
        _bahanCtrl.text.isEmpty ||
        _langkahCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field wajib diisi!")),
      );
      return;
    }

  final recipe = Recipe(
    id: DateTime.now().millisecondsSinceEpoch,
    nama: _namaCtrl.text,
    asalDaerah: _asalCtrl.text,
    deskripsi: _deskripsiCtrl.text,
    porsi: _porsiCtrl.text,
    waktuMemasak: _waktuCtrl.text,
    urlGambar: _fotoCtrl.text,
    tagMakanan: ["Upload"],
    bahan: _bahanCtrl.text.split("\n"),
    langkah: _langkahCtrl.text.split("\n"), // <-- ini yang benar
  );


    HiveService.addUploadedRecipe(recipe);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Resep berhasil di-upload!")),
    );

    Navigator.pop(context);
  }

  Widget _input(String label, TextEditingController c, {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Resep"),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _input("Nama Masakan", _namaCtrl),
            _input("Asal Daerah", _asalCtrl),
            _input("Deskripsi Masakan", _deskripsiCtrl, maxLines: 3),
            _input("Porsi (cth: 2 Porsi)", _porsiCtrl),
            _input("Waktu Memasak (cth: 15 menit)", _waktuCtrl),
            _input("Link Foto Makanan", _fotoCtrl),
            _input("Bahan-bahan (pisahkan dengan ENTER)", _bahanCtrl, maxLines: 6),
            _input("Langkah Memasak (pisahkan dengan ENTER)", _langkahCtrl, maxLines: 6),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _save,
              child: const Text("Upload Resep"),
            )
          ],
        ),
      ),
      backgroundColor: const Color(0xFFFFF7F0),
    );
  }
}
