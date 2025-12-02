import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  static const String _url = 'https://api-recipe-wheat.vercel.app/data_recipe.json'; // Endpoint API untuk mengambil resep

  // Fungsi untuk mengambil data resep
  Future<List<Recipe>> fetchRecipes() async {
    try {
      final res = await http.get(Uri.parse(_url));
      if (res.statusCode != 200) {
        throw Exception('Gagal memuat data: ${res.statusCode}');
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = data['resep_makanan_indonesia'] as List<dynamic>;
      return list.map((e) => Recipe.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching recipes: $e');
      rethrow;
    }
  }
}
