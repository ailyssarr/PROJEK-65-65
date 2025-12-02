import 'dart:io';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';
import 'recipe_detail_page.dart';
import 'upload_page.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final _api = ApiService();
  List<Recipe> _all = [];
  List<Recipe> _filtered = [];
  List<Recipe> _uploaded = [];

  bool _loading = true;
  String _search = '';
  String _selectedArea = 'Semua';
  List<String> _areas = ['Semua'];

  final Color _bgColor = const Color(0xFFFFF7F0);
  final Color _primary = const Color(0xFFFFB074);
  final Color _primaryDark = const Color(0xFFE58A45);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Widget _buildRecipeImage(String path) {
    final isNetwork = path.startsWith("http");

    if (isNetwork) {
      return Image.network(
        path,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(path),
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        cacheWidth: 200,
        cacheHeight: 200,
      );
    }
  }

  Future<void> _load() async {
    try {
      final apiData = await _api.fetchRecipes();
      final uploaded = HiveService.getUploadedRecipes();

      final setArea = <String>{};
      for (final r in [...uploaded, ...apiData]) {
        setArea.add(r.asalDaerah);
      }

      final areas = ['Semua', ...setArea.toList()..sort()];

      setState(() {
        _uploaded = uploaded;
        _all = [...uploaded, ...apiData];
        _areas = areas;
        _applyFilter();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal memuat resep: $e")));
    }
  }

  void _applyFilter() {
    _filtered = _all.where((r) {
      final matchSearch = r.nama.toLowerCase().contains(_search.toLowerCase()) ||
          r.asalDaerah.toLowerCase().contains(_search.toLowerCase());

      final matchArea =
          _selectedArea == 'Semua' || r.asalDaerah == _selectedArea;

      return matchSearch && matchArea;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final name = HiveService.getUserName();

    return Scaffold(
      backgroundColor: _bgColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primary,
        child: const Icon(Icons.upload),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadPage()),
          ).then((_) => _load());
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person_outline, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, $name 👋',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              'Mau masak apa hari ini?',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari resep / daerah asal...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) {
                      setState(() {
                        _search = v;
                        _applyFilter();
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.filter_list, color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      const Text(
                        'Filter daerah:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: Colors.white,
                            value: _selectedArea,
                            items: _areas
                                .map((a) => DropdownMenuItem(
                                      value: a,
                                      child: Text(a),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val == null) return;
                              setState(() {
                                _selectedArea = val;
                                _applyFilter();
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) {
                          final r = _filtered[i];
                          final isFav = HiveService.isFavorite(r.id);

                          return GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecipeDetailPage(recipe: r),
                                ),
                              ).then((_) => setState(() {}));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      bottomLeft: Radius.circular(18),
                                    ),
                                    child: _buildRecipeImage(r.urlGambar),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            r.nama,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            r.asalDaerah,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.schedule,
                                                size: 14,
                                                color: Colors.orange,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                r.waktuMemasak,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border_outlined,
                                      color: isFav
                                          ? Colors.red
                                          : Colors.grey[400],
                                    ),
                                    onPressed: () {
                                      HiveService.toggleFavorite(r.id);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
