import 'package:flutter/material.dart';

class KesanPesanPage extends StatelessWidget {
  const KesanPesanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F0), // langsung di sini
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB074), // langsung di sini
        foregroundColor: Colors.white,
        title: const Text("Kesan & Pesan"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ====== KESAN ======
            const Text(
              "Kesan",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // ---- BOX KESAN ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, // langsung
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                "Tuliskan kesan kamu di sini.\n"
                "Contoh: Selama mengikuti mata kuliah Pemrograman Aplikasi Mobile, "
                "saya merasa mendapatkan banyak ilmu baru terutama tentang penggunaan API, Hive, "
                "dan pengembangan aplikasi mobile berbasis Flutter.",
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
            ),

            const SizedBox(height: 28),

            // ====== PESAN ======
            const Text(
              "Pesan",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // ---- BOX PESAN ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, // langsung di sini juga
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                "Tuliskan pesan kamu di sini.\n"
                "Contoh: Semoga ke depannya mata kuliah ini bisa terus memberikan studi kasus nyata "
                "dan proyek yang relevan dengan kebutuhan industri. Terima kasih atas bimbingan dan "
                "ilmu yang sudah diberikan, Pak/Bu.",
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
