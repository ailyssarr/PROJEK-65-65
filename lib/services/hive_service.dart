import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';

class HiveService {
  static const usersBoxName = 'usersBox';
  static const sessionBoxName = 'sessionBox';
  static const favBoxName = 'favBox';
  static const uploadedBox = 'uploaded_recipes'; // 🔥 buat upload resep

  // Inisialisasi Hive
  static Future<void> init() async {
    await Hive.initFlutter();

    // 🔥 WAJIB DIBUKA
    await Hive.openBox(uploadedBox);

    // Enkripsi users box
    final key = sha256.convert(utf8.encode('foodmate-secret-key')).bytes;
    final cipher = HiveAesCipher(Uint8List.fromList(key));

    await Hive.openBox(usersBoxName, encryptionCipher: cipher);
    await Hive.openBox(sessionBoxName);
    await Hive.openBox(favBoxName); // Pastikan favBox dibuka
  }

  static String _hash(String s) => sha256.convert(utf8.encode(s)).toString();

  // ===================== REGISTER =====================
  static String? register(String name, String email, String password) {
    final usersBox = Hive.box(usersBoxName);

    if (usersBox.containsKey(email)) {
      return 'Email sudah terdaftar. Silakan gunakan email lain.';
    }

    final userData = {
      'name': name,
      'email': email,
      'password_hash': _hash(password),
    };

    usersBox.put(email, userData);
    return null;
  }

  // ===================== LOGIN =====================
  static bool login(String email, String password) {
    final usersBox = Hive.box(usersBoxName);
    if (!usersBox.containsKey(email)) return false;

    final userData = usersBox.get(email) as Map;
    if (_hash(password) != userData['password_hash']) return false;

    final sessionBox = Hive.box(sessionBoxName);
    sessionBox.put('isLoggedIn', true);
    sessionBox.put('currentEmail', email);

    return true;
  }

  static bool isLoggedIn() {
    final sessionBox = Hive.box(sessionBoxName);
    return sessionBox.get('isLoggedIn', defaultValue: false) as bool;
  }

  static void logout() {
    final sessionBox = Hive.box(sessionBoxName);
    sessionBox.put('isLoggedIn', false);
    sessionBox.delete('currentEmail');
  }

  static String getUserEmail() {
    final sessionBox = Hive.box(sessionBoxName);
    return sessionBox.get('currentEmail', defaultValue: '') as String;
  }

  static String getUserName() {
    final email = getUserEmail();
    if (email.isEmpty) return 'FoodMate User';

    final usersBox = Hive.box(usersBoxName);
    if (!usersBox.containsKey(email)) return 'FoodMate User';

    final user = usersBox.get(email) as Map;
    return user['name'] ?? 'FoodMate User';
  }

  static String _userFavKey() {
    final email = getUserEmail();
    return 'fav_$email';
  }

  static List<String> getFavoriteIds() {
    final box = Hive.box(favBoxName);
    final list =
        box.get(_userFavKey(), defaultValue: <String>[]) as List<dynamic>;
    return list.cast<String>();
  }

  // Memeriksa apakah resep ada di favorit
  static bool isFavorite(String id) => getFavoriteIds().contains(id);

  // Menambah atau menghapus favorit
  static void toggleFavorite(String id) {
    final box = Hive.box(favBoxName);
    final list = getFavoriteIds();

    if (list.contains(id)) {
      list.remove(id); // Jika sudah favorit, hapus
    } else {
      list.add(id); // Jika belum favorit, tambahkan
    }

    // Update list favorit di Hive
    box.put(_userFavKey(), list);
  }

  // ===================== UPLOADED RECIPES =====================
  static void addUploadedRecipe(Recipe recipe) {
    final box = Hive.box(uploadedBox);
    box.put(recipe.id, recipe.toMap());
  }

  static List<Recipe> getUploadedRecipes() {
    final box = Hive.box(uploadedBox);
    return box.values
        .map((data) => Recipe.fromMap(Map<String, dynamic>.from(data)))
        .toList();
  }
}
