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

  final Map<String, double> _costMap = {
    '1': 80000,
    '2': 65000,
    '3': 50000,
    '4': 45000,
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
    final isFav = HiveService.isFavorite(r.id);
    final converted = convertFromIdr(_baseCostIdr, _selectedCurrency);

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
              // Toggle favorite status
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
            // GAMBAR
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.network(r.urlGambar),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.room_service,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          r.porsi,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          r.waktuMemasak,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              r.nama,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              r.asalDaerah,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: r.tagMakanan
                  .map(
                    (t) => Chip(
                      label: Text(t),
                      backgroundColor: _chipBg,
                      labelStyle: const TextStyle(fontSize: 12),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            // BAHAN
            _buildSectionCard(
              title: 'Bahan-bahan',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: r.bahan.map((b) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• ", style: TextStyle(height: 1.4)),
                        Expanded(
                          child: Text(b, style: const TextStyle(height: 1.4)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // LANGKAH
            _buildSectionCard(
              title: 'Langkah Memasak',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: r.langkahMemasak.asMap().entries.map((e) {
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

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
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
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildTimeRow(AppTimeZone tz) {
    final t = convertFromWib(_startTimeWib, tz);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.public, size: 18),
      title: Text(timeZoneLabel(tz)),
      subtitle: Text(formatDateTime(t)),
    );
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startTimeWib,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (pickedDate == null) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTimeWib),
    );
    if (pickedTime == null) return;

    setState(() {
      _startTimeWib = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Jadwal masak diperbarui ✅')));
  }
}
