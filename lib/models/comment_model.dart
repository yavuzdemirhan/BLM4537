class Comment {
  final int id;
  final int tourId;
  final String username;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.tourId,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  // JSON'dan Dart Nesnesine (Backend'den veri gelirken)
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      tourId: json['tourId'] ?? 0,
      username: json['username'] ?? "Anonim",
      content: json['content'] ?? "",
      // Backend'den gelen String tarihi DateTime objesine çeviriyoruz
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  // Dart Nesnesinden JSON'a (Backend'e veri gönderirken)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tourId': tourId,
      'username': username,
      'content': content,
      // DateTime objesini ISO8601 String formatına çeviriyoruz
      'createdAt': createdAt.toIso8601String(),
    };
  }
}