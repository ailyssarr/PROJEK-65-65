import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  static const String _url =
      'https://api-recipe-wheat.vercel.app/data_recipe.json';

  Future<List<Recipe>> fetchRecipes() async {
    final res = await http.get(Uri.parse(_url));
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat data: ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = data['resep_makanan_indonesia'] as List<dynamic>;
    return list.map((e) => Recipe.fromJson(e)).toList();
  }
}
