import 'dart:io';
import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../services/hive_service.dart';
import '../services/api_service.dart';
import 'recipe_detail_page.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final _api = ApiService();

  List<Recipe> _recipes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = await _api.fetchRecipes();
      final local = HiveService.getUploadedRecipes();

      setState(() {
        _recipes = [...local, ...api];
        _loading = false;
      });
    } catch (e) {
      _loading = false;
      setState(() {});
      debugPrint("LOAD ERROR: $e");
    }
  }

  Widget _buildImage(Recipe r) {
    if (r.localImage != null && r.localImage!.isNotEmpty) {
      return Image.file(
        File(r.localImage!),
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      r.urlGambar,
      width: 90,
      height: 90,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.image_not_supported),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F0),
      appBar: AppBar(
        title: const Text("Recipes"),
        backgroundColor: const Color(0xFFFFB074),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _recipes.length,
        itemBuilder: (_, i) {
          final r = _recipes[i];
          final fav = HiveService.isFavorite(r.id);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImage(r),
              ),
              title: Text(r.nama),
              subtitle: Text(r.asalDaerah),
              trailing: IconButton(
                icon: Icon(
                  fav
                      ? Icons.favorite
                      : Icons.favorite_border_outlined,
                  color: fav ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  HiveService.toggleFavorite(r.id);
                  setState(() {});
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RecipeDetailPage(recipe: r),
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
