import 'dart:io';
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
  List<Recipe> _all = []; // All recipes from the API
  bool _loading = true;

  final Color _bgColor = const Color(0xFFFFF7F0);
  final Color _primary = const Color(0xFFFFB074);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Fetch recipes from the API
    final recipes = await _api.fetchRecipes();
    setState(() {
      _all = recipes; // Save all recipes from the API
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get favorite recipe IDs from Hive
    final favIds = HiveService.getFavoriteIds();
    // Filter the recipes to show only the favorites based on IDs
    final favRecipes = _all.where((r) => favIds.contains(r.id)).toList();

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: const Text('Resep Favorit'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator()) // Loading state
          : favRecipes.isEmpty
          ? const Center(
              child: Text('Belum ada resep favorit.'),
            ) // No favorites
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favRecipes.length,
              itemBuilder: (_, i) {
                final r = favRecipes[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: r.urlGambar == 'local'
                          ? Image.file(
                              File(r.localImage!),
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
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
                      ).then(
                        (_) => setState(() {}),
                      ); // Refresh after navigating back
                    },
                  ),
                );
              },
            ),
    );
  }
}
