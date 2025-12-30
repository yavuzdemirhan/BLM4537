class Tour {
  final int id;
  final String baslik;
  final String aciklama;
  final String rota;
  final DateTime tarih;
  final String motosikletKategorisi;
  final String olusturanKisi;
  final int viewCount;
  final String? customImageUrl;
  final double averageRating; 

  Tour({
    required this.id,
    required this.baslik,
    required this.aciklama,
    required this.rota,
    required this.tarih,
    required this.motosikletKategorisi,
    required this.olusturanKisi,
    required this.viewCount,
    this.customImageUrl,
    required this.averageRating,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'] ?? 0,
      baslik: json['baslik'] ?? '',
      aciklama: json['aciklama'] ?? '',
      rota: json['rota'] ?? '',
      tarih: json['tarih'] != null ? DateTime.parse(json['tarih']) : DateTime.now(),
      motosikletKategorisi: json['motosikletKategorisi'] ?? 'Genel',
      olusturanKisi: json['olusturanKisi'] ?? 'Anonim',
      viewCount: json['viewCount'] ?? 0,
      customImageUrl: json['customImageUrl'],
      averageRating: (json['averageRating'] ?? 0).toDouble(), // YENİ
    );
  }
}