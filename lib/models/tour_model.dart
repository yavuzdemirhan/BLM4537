class Tour {
  final int id;
  final String baslik;
  final String aciklama;
  final String rota;
  final DateTime tarih;
  final String motosikletKategorisi;

  Tour({
    required this.id,
    required this.baslik,
    required this.aciklama,
    required this.rota,
    required this.tarih,
    required this.motosikletKategorisi,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'] ?? 0,
      baslik: json['baslik'] ?? '',
      aciklama: json['aciklama'] ?? '',
      rota: json['rota'] ?? '',
      tarih: json['tarih'] != null ? DateTime.parse(json['tarih']) : DateTime.now(),
      motosikletKategorisi: json['motosikletKategorisi'] ?? 'Genel',
    );
  }
}