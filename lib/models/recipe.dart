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
  final List<String> langkah;

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
    required this.langkah,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      nama: json['nama'],
      asalDaerah: json['asal_daerah'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      urlGambar: json['url_gambar'],
      tagMakanan: List<String>.from(json['tag_makanan'] ?? []),
      porsi: json['porsi'] ?? '',
      waktuMemasak: json['waktu_memasak'] ?? '',
      bahan: List<String>.from(json['bahan'] ?? []),
      langkah: List<String>.from(json['langkah_masak'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'asal_daerah': asalDaerah,
      'deskripsi': deskripsi,
      'url_gambar': urlGambar,
      'tag_makanan': tagMakanan,
      'porsi': porsi,
      'waktu_memasak': waktuMemasak,
      'bahan': bahan,
      'langkah_masak': langkah,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      nama: map['nama'],
      asalDaerah: map['asal_daerah'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      urlGambar: map['url_gambar'],
      tagMakanan: List<String>.from(map['tag_makanan'] ?? []),
      porsi: map['porsi'] ?? '',
      waktuMemasak: map['waktu_memasak'] ?? '',
      bahan: List<String>.from(map['bahan'] ?? []),
      langkah: List<String>.from(map['langkah_masak'] ?? []),
    );
  }
}
