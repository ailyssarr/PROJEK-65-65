import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../services/api_service.dart';
import '../models/recipe.dart';
import 'recipe_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _api = ApiService();
  List<Recipe> _all = [];
  bool _loading = true;

  final Color _bgColor = const Color(0xFFFFF7F0);
  final Color _primary = const Color(0xFFFFB074);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _api.fetchRecipes();
    setState(() {
      _all = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favIds = HiveService.getFavoriteIds();
    final favRecipes = _all.where((r) => favIds.contains(r.id)).toList();

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: const Text('Resep Favorit'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : favRecipes.isEmpty
              ? const Center(child: Text('Belum ada resep favorit.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favRecipes.length,
                  itemBuilder: (c, i) {
                    final r = favRecipes[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            r.urlGambar,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(r.nama),
                        subtitle: Text(r.asalDaerah),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailPage(recipe: r),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
