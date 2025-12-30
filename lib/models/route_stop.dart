class RouteStop {
  final int id;
  final int tourId;
  final String stopName;    // C#: StopName
  final String description; // C#: Description
  final int orderIndex;     // C#: OrderIndex
  final String time;        // C#: Time

  RouteStop({
    this.id = 0, // Yeni eklerken ID 0 gönderilir, DB otomatik atar.
    required this.tourId,
    required this.stopName,
    required this.description,
    required this.orderIndex,
    required this.time,
  });

  // JSON'dan Dart nesnesine
  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      id: json['id'] ?? 0,
      tourId: json['tourId'] ?? 0,
      stopName: json['stopName'] ?? "",
      description: json['description'] ?? "",
      orderIndex: json['orderIndex'] ?? 0,
      time: json['time'] ?? "",
    );
  }

  // Dart nesnesinden JSON'a (API'ye gönderirken)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tourId': tourId,
      'stopName': stopName,
      'description': description,
      'orderIndex': orderIndex,
      'time': time,
    };
  }
}