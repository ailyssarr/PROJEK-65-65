class Recipe {
  final int id;
  final String nama;
  final String asalDaerah;
  final String deskripsi;
  final String urlGambar;
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
    required this.tagMakanan,
    required this.porsi,
    required this.waktuMemasak,
    required this.bahan,
    required this.langkahMemasak,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int,
      nama: json['nama'] as String,
      asalDaerah: json['asal_daerah'] as String,
      deskripsi: json['deskripsi'] as String,
      urlGambar: json['url_gambar'] as String,
      tagMakanan: List<String>.from(json['tag_makanan'] ?? []),
      porsi: json['porsi'] as String,
      waktuMemasak: json['waktu_memasak'] as String,
      bahan: List<String>.from(json['bahan'] ?? []),
      langkahMemasak: List<String>.from(json['langkah_memasak'] ?? []),
    );
  }
}
