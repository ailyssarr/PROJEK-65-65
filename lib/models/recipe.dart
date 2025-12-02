class Recipe {
  final String id;
  final String nama;
  final String asalDaerah;
  final String deskripsi;
  final String urlGambar;
  final String? localImage;
  final List<String> tagMakanan;
  final String porsi;
  final String waktuMemasak;
  final List<String> bahan;
  final List<String> langkahMemasak;

  Recipe({
    required this.id,
    required this.nama,
    required this.asalDaerah,
    required this.deskripsi,
    required this.urlGambar,
    required this.localImage,
    required this.tagMakanan,
    required this.porsi,
    required this.waktuMemasak,
    required this.bahan,
    required this.langkahMemasak,
  });

  // ============================
  // FROM API JSON
  // ============================
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'].toString(),
      nama: json['nama'] as String,
      asalDaerah: json['asal_daerah'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
      urlGambar: json['url_gambar'] as String,
      localImage: null, // API tidak mengirim gambar lokal
      tagMakanan: List<String>.from(json['tag_makanan'] ?? []),
      porsi: json['porsi'] as String? ?? '',
      waktuMemasak: json['waktu_memasak'] as String? ?? '',
      bahan: List<String>.from(json['bahan'] ?? []),
      langkahMemasak: List<String>.from(json['langkah_memasak'] ?? []),
    );
  }

  // ============================
  // TO MAP (untuk Hive)
  // ============================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'asal_daerah': asalDaerah,
      'deskripsi': deskripsi,
      'url_gambar': urlGambar,
      'localImage': localImage,
      'tag_makanan': tagMakanan,
      'porsi': porsi,
      'waktu_memasak': waktuMemasak,
      'bahan': bahan,
      'langkah_memasak': langkahMemasak,
    };
  }

  // ============================
  // FROM MAP (Hive)
  // ============================
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      nama: map['nama'],
      asalDaerah: map['asal_daerah'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      urlGambar: map['url_gambar'] ?? '',
      localImage: map['localImage'], // base64 gambar lokal kamera/galeri
      tagMakanan: List<String>.from(map['tag_makanan'] ?? []),
      porsi: map['porsi'] ?? '',
      waktuMemasak: map['waktu_memasak'] ?? '',
      bahan: List<String>.from(map['bahan'] ?? []),
      langkahMemasak: List<String>.from(map['langkah_memasak'] ?? []),
    );
  }
}
