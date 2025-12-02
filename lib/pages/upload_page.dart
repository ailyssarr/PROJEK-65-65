import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/recipe.dart';
import '../services/hive_service.dart'; // HiveService untuk menyimpan ke Hive

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

  // Fungsi untuk menyimpan gambar ke direktori aplikasi
  Future<void> _saveImageToAppDirectory(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
    final localImage = File('${directory.path}/$fileName');

    await imageFile.copy(localImage.path);  // Salin gambar ke lokasi aplikasi
    print("Gambar disalin ke: ${localImage.path}");

    setState(() {
      _imageFile = localImage;  // Update file yang akan ditampilkan
    });
  }

  // Fungsi untuk memilih gambar dari kamera atau galeri
  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);  // Path gambar dari kamera atau galeri
      });

      // Menyimpan gambar ke direktori aplikasi
      _saveImageToAppDirectory(_imageFile!);
    }
  }

  // Fungsi untuk menyimpan resep ke Hive
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

    String recipeId = DateTime.now().millisecondsSinceEpoch
        .toString(); // ID unik menggunakan timestamp

    final recipe = Recipe(
      id: recipeId, // ID unik menggunakan UUID
      nama: _namaCtrl.text,
      asalDaerah: _asalCtrl.text,
      deskripsi: _deskripsiCtrl.text,
      urlGambar: _imageFile!.path, // Menyimpan path gambar
      localImage: null, // Bisa gunakan base64 jika perlu
      tagMakanan: ["Upload"], // Bisa menyesuaikan tag makanan
      porsi: _porsiCtrl.text,
      waktuMemasak: _waktuCtrl.text,
      bahan: _bahanCtrl.text.split("\n"),
      langkahMemasak: _langkahCtrl.text.split("\n"),
    );

    // Simpan resep ke Hive
    HiveService.addUploadedRecipe(recipe);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Resep berhasil di-upload!")),
    );

    // Memanggil setState untuk memperbarui tampilan atau kembali
    setState(() {
      // Bisa memperbarui tampilan di halaman ini atau kembali ke halaman sebelumnya
    });

    Navigator.pop(context); // Kembali ke halaman sebelumnya setelah sukses
  }

  // Widget input form
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
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

            // ========================== PILIH FOTO ==========================
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Foto Masakan", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  if (_imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.file(
                        _imageFile!,
                        height: 150,
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
                      const SizedBox(width: 12),
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

            _input(
              "Bahan-bahan (ENTER untuk ganti baris)",
              _bahanCtrl,
              maxLines: 6,
            ),
            _input(
              "Langkah Memasak (ENTER untuk ganti baris)",
              _langkahCtrl,
              maxLines: 6,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
              ),
              onPressed: _save, // Panggil fungsi simpan ke Hive
              child: const Text("Upload Resep"),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFFFF7F0),
    );
  }
}
