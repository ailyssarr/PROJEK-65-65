import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/recipe.dart';

class HiveService {
  // ===============================
  // BOX NAMES
  // ===============================
  static const usersBoxName = 'usersBox';
  static const sessionBoxName = 'sessionBox';
  static const favBoxName = 'favBox';
  static const uploadedBox = 'uploaded_recipes';

  // ===============================
  // INIT
  // ===============================
  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(uploadedBox);        // upload resep
    await Hive.openBox(sessionBoxName);     // session
    await Hive.openBox(favBoxName);         // favorite

    // AES encrypted box untuk user
    final key = sha256.convert(utf8.encode('foodmate-secret-key')).bytes;
    final cipher = HiveAesCipher(Uint8List.fromList(key));
    await Hive.openBox(usersBoxName, encryptionCipher: cipher);
  }

  // ===============================
  // TOOLS
  // ===============================
  static String _hash(String s) =>
      sha256.convert(utf8.encode(s)).toString();

  // ===============================
  // REGISTER USER
  // ===============================
  static String? register(String name, String email, String password) {
    final usersBox = Hive.box(usersBoxName);

    if (usersBox.containsKey(email)) {
      return 'Email sudah terdaftar.';
    }

    final userData = {
      'name': name,
      'email': email,
      'password_hash': _hash(password),
    };

    usersBox.put(email, userData);
    return null;
  }

  // ===============================
  // LOGIN
  // ===============================
  static bool login(String email, String password) {
    final usersBox = Hive.box(usersBoxName);
    if (!usersBox.containsKey(email)) return false;

    final user = usersBox.get(email) as Map;
    if (_hash(password) != user['password_hash']) return false;

    final session = Hive.box(sessionBoxName);
    session.put('isLoggedIn', true);
    session.put('currentEmail', email);

    return true;
  }

  // ===============================
  // SESSION
  // ===============================
  static bool isLoggedIn() {
    final session = Hive.box(sessionBoxName);
    return session.get('isLoggedIn', defaultValue: false);
  }

  static void logout() {
    final session = Hive.box(sessionBoxName);
    session.put('isLoggedIn', false);
    session.delete('currentEmail');
  }

  static String getUserEmail() {
    final session = Hive.box(sessionBoxName);
    return session.get('currentEmail', defaultValue: '');
  }

  static String getUserName() {
    final email = getUserEmail();
    if (email.isEmpty) return 'FoodMate User';

    final users = Hive.box(usersBoxName);
    if (!users.containsKey(email)) return 'FoodMate User';

    final user = users.get(email) as Map;
    return user['name'] ?? 'FoodMate User';
  }

  // ===============================
  // FAVORITE
  // ===============================
  static String _favKey() => 'fav_${getUserEmail()}';

  static List<int> getFavoriteIds() {
    final box = Hive.box(favBoxName);
    return List<int>.from(box.get(_favKey(), defaultValue: <int>[]));
  }

  static bool isFavorite(int id) {
    return getFavoriteIds().contains(id);
  }

  static void toggleFavorite(int id) {
    final box = Hive.box(favBoxName);
    final favs = getFavoriteIds();

    if (favs.contains(id)) {
      favs.remove(id);
    } else {
      favs.add(id);
    }

    box.put(_favKey(), favs);
  }

  // ===============================
  // UPLOADED RECIPES
  // ===============================
  static void addUploadedRecipe(Recipe recipe) {
    final box = Hive.box(uploadedBox);
    box.add(recipe.toMap());   // simpan MAP ke Hive
  }

  static List<Recipe> getUploadedRecipes() {
    final box = Hive.box(uploadedBox);

    return box.values
        .map((item) => Recipe.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }
}
