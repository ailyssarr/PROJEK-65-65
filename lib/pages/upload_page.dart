import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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
  final TextEditingController _bahanCtrl = TextEditingController();
  final TextEditingController _langkahCtrl = TextEditingController();

  final Color _primary = const Color(0xFFFFB074);

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Save image ke folder app sendiri
  Future<File> _saveImage(File image) async {
    final dir = await getApplicationDocumentsDirectory();
    final filename = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    final newFile = File("${dir.path}/$filename");

    return image.copy(newFile.path);
  }

  // Pick image
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile == null) return;

    final temp = File(pickedFile.path);
    final savedImage = await _saveImage(temp);

    setState(() {
      _imageFile = savedImage;
    });
  }

  // Save recipe
  void _save() {
    if (_namaCtrl.text.isEmpty ||
        _deskripsiCtrl.text.isEmpty ||
        _imageFile == null ||
        _bahanCtrl.text.isEmpty ||
        _langkahCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field wajib diisi!")),
      );
      return;
    }

    final recipe = Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nama: _namaCtrl.text,
      asalDaerah: _asalCtrl.text,
      deskripsi: _deskripsiCtrl.text,

      // ✅ penting buat gambar upload
      urlGambar: "",
      localImage: _imageFile!.path,

      tagMakanan: ["Upload"],
      porsi: _porsiCtrl.text,
      waktuMemasak: _waktuCtrl.text,
      bahan: _bahanCtrl.text.split("\n"),
      langkahMemasak: _langkahCtrl.text.split("\n"),
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
            borderRadius: BorderRadius.circular(12.0),
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
      backgroundColor: const Color(0xFFFFF7F0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _input("Nama Masakan", _namaCtrl),
            _input("Asal Daerah", _asalCtrl),
            _input("Deskripsi Masakan", _deskripsiCtrl, maxLines: 3),
            _input("Porsi", _porsiCtrl),
            _input("Waktu Memasak", _waktuCtrl),

            // IMAGE PICKER
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Foto Masakan", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),

                  if (_imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _imageFile!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Kamera"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text("Galeri"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _input("Bahan-bahan (pisahkan ENTER)", _bahanCtrl, maxLines: 6),
            _input("Langkah Memasak (pisahkan ENTER)", _langkahCtrl, maxLines: 6),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text("Upload Resep"),
            ),
          ],
        ),
      ),
    );
  }
}
