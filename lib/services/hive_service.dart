import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const usersBoxName = 'usersBox';
  static const sessionBoxName = 'sessionBox';
  static const favBoxName = 'favBox';

  static Future<void> init() async {
    await Hive.initFlutter();

    final key = sha256.convert(utf8.encode('foodmate-secret-key')).bytes;
    final cipher = HiveAesCipher(Uint8List.fromList(key));

    // box untuk MENYIMPAN BANYAK USER (key = email)
    await Hive.openBox(usersBoxName, encryptionCipher: cipher);
    // box untuk session (login state)
    await Hive.openBox(sessionBoxName);
    // box untuk favorit
    await Hive.openBox(favBoxName);
  }

  static String _hash(String s) =>
      sha256.convert(utf8.encode(s)).toString();

  /// SIGN UP
  /// return null kalau sukses, atau pesan error kalau gagal
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
    return null; // sukses
  }

  /// LOGIN
  static bool login(String email, String password) {
    final usersBox = Hive.box(usersBoxName);

    if (!usersBox.containsKey(email)) {
      return false;
    }

    final userData = usersBox.get(email) as Map;
    final storedHash = userData['password_hash'] as String;

    if (_hash(password) != storedHash) {
      return false;
    }

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
    final usersBox = Hive.box(usersBoxName);

    final currentEmail =
        sessionBox.get('currentEmail', defaultValue: '') as String;
    if (currentEmail.isEmpty) return '-';

    if (!usersBox.containsKey(currentEmail)) return currentEmail;

    return currentEmail;
  }

  static String getUserName() {
    final sessionBox = Hive.box(sessionBoxName);
    final usersBox = Hive.box(usersBoxName);

    final currentEmail =
        sessionBox.get('currentEmail', defaultValue: '') as String;
    if (currentEmail.isEmpty) return 'FoodMate User';

    if (!usersBox.containsKey(currentEmail)) return 'FoodMate User';

    final userData = usersBox.get(currentEmail) as Map;
    return userData['name'] as String? ?? 'FoodMate User';
  }

  // ========= FAVORIT (masih global, tidak per-user, cukup untuk tugas) =========

  static List<int> getFavoriteIds() {
    final box = Hive.box(favBoxName);
    final list = box.get('ids', defaultValue: <int>[]) as List<dynamic>;
    return list.cast<int>();
  }

  static bool isFavorite(int id) => getFavoriteIds().contains(id);

  static void toggleFavorite(int id) {
    final box = Hive.box(favBoxName);
    final list = getFavoriteIds();
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    box.put('ids', list);
  }
}
