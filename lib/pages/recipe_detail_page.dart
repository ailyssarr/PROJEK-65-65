import 'dart:io';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/hive_service.dart';
import '../utils/currency_time_utils.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late DateTime _startTimeWib;
  Currency _selectedCurrency = Currency.idr;

  // fallback cost jika id tidak ada di map
  final Map<int, double> _costMap = {
    1: 80000,
    2: 65000,
    3: 50000,
    4: 45000,
  };

  final Color _bgColor = const Color(0xFFFFF7F0);
  final Color _primary = const Color(0xFFFFB074);
  final Color _primaryDark = const Color(0xFFE58A45);
  final Color _chipBg = const Color(0xFFFFF0E2);

  @override
  void initState() {
    super.initState();
    _startTimeWib = DateTime.now().add(const Duration(minutes: 15));
  }

  double get _baseCostIdr => _costMap[widget.recipe.id] ?? 60000;

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;

    final bool isFav = HiveService.isFavorite(r.id);

    final tagList = r.tagMakanan ?? [];
    final bahanList = r.bahan ?? [];
    final langkahList = r.langkahMemasak ?? [];

    final convertedCost = convertFromIdr(_baseCostIdr, _selectedCurrency);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: Text(r.nama),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              HiveService.toggleFavorite(r.id);
              setState(() {});

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFav ? 'Dihapus dari favorit' : 'Ditambahkan ke favorit',
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================
            // GAMBAR FIX (LOCAL / NETWORK)
            // ============================
            _buildRecipeImage(r.urlGambar),

            const SizedBox(height: 14),

            Text(
              r.nama,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              r.asalDaerah,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 12),

            // TAG MAKANAN
            Wrap(
              spacing: 8,
              children: tagList
                  .map((t) => Chip(
                        label: Text(t),
                        backgroundColor: _chipBg,
                        labelStyle: const TextStyle(fontSize: 12),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 16),

            // ============================
            // BAHAN
            // ============================
            _buildSectionCard(
              title: 'Bahan-bahan',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: bahanList.map((b) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• ", style: TextStyle(height: 1.4)),
                        Expanded(
                          child: Text(
                            b,
                            style: const TextStyle(height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // ============================
            // LANGKAH
            // ============================
            _buildSectionCard(
              title: 'Langkah Memasak',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: langkahList.asMap().entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('${e.key + 1}. ${e.value}'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================
  // GAMBAR LOCAL & NETWORK HANDLER
  // ==================================
  Widget _buildRecipeImage(String url) {
    final isLocalFile = url.startsWith("/") ||
        url.contains("\\") ||
        url.contains("C:") ||
        url.contains("storage/emulated");

    if (isLocalFile) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          File(url),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              height: 200,
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.image_not_supported, size: 50),
              ),
            );
          },
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            height: 200,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.image_not_supported, size: 50),
            ),
          );
        },
      ),
    );
  }

  // ==================================
  // SECTION CARD BUILDER
  // ==================================
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
