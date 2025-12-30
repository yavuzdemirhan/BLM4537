import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tour_model.dart';
import '../models/comment_model.dart';
import '../models/route_stop.dart';

class ApiService {
  final String baseUrl = "http://localhost:5293/api"; 

  // --- AUTH ---
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/Account/login'), 
        headers: {"Content-Type": "application/json"}, body: jsonEncode({"Email": email, "Password": password}));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);
        await prefs.setString('saved_username', data['username'] ?? "Sürücü");
        await prefs.setString('saved_email', email);
        return true;
      }
      return false;
    } catch (e) { return false; }
  }

  Future<bool> register(String u, String e, String p) async {
    try { return (await http.post(Uri.parse('$baseUrl/Account/register'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"Username": u, "Email": e, "Password": p}))).statusCode == 200; } catch (e) { return false; }
  }
  
  Future<void> logout() async { (await SharedPreferences.getInstance()).clear(); }

  // --- TOURS ---
  Future<List<Tour>> getAllTours() async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/tours'));
      if (r.statusCode == 200) return (jsonDecode(r.body) as List).map((i) => Tour.fromJson(i)).toList();
      return [];
    } catch (e) { return []; }
  }
  
  Future<List<Tour>> getMyCreatedTours(String u) async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/tours/my-created/$u'));
      if (r.statusCode == 200) return (jsonDecode(r.body) as List).map((i) => Tour.fromJson(i)).toList();
      return [];
    } catch (e) { return []; }
  }

  Future<int> createTour(Tour tour, String creatorUsername) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tours'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "baslik": tour.baslik,
          "aciklama": tour.aciklama,
          "rota": tour.rota,
          "motosikletKategorisi": tour.motosikletKategorisi,
          "tarih": tour.tarih.toIso8601String(),
          "olusturanKisi": creatorUsername,
          "customImageUrl": tour.customImageUrl, // YENİ
        }),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id']; // ID'yi yakaladık!
      }
      return -1;
    } catch (e) { return -1; }
  }

  Future<bool> deleteTour(int id) async { return (await http.delete(Uri.parse('$baseUrl/tours/$id'))).statusCode == 204; }
  Future<void> incrementView(int id) async { await http.post(Uri.parse('$baseUrl/tours/increment-view/$id')); }

  // 1. Yorumları Getir
  Future<List<Comment>> getComments(int tourId) async {
    try {
      // Backend: GET api/Comments/{tourId}
      final response = await http.get(Uri.parse('$baseUrl/Comments/$tourId'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Comment.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Yorum çekme hatası: $e");
      return [];
    }
  }

  // 2. Yorum Gönder
  Future<bool> postComment(Comment comment) async {
    try {
      // Backend: POST api/Comments
      final response = await http.post(
        Uri.parse('$baseUrl/Comments'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(comment.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Yorum gönderme hatası: $e");
      return false;
    }
  }
  Future<bool> joinTour(int id, String t, String u) async { return (await http.post(Uri.parse('$baseUrl/Participations'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"TourId": id, "TourTitle": t, "Username": u}))).statusCode == 200; }
  // --- GÜNCELLENDİ: Katıldığım Turları Getir ---
  Future<List<Tour>> getMyParticipations(String username) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Participations/$username'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Tour.fromJson(item)).toList();
      } else { return []; }
    } catch (e) { return []; }
  }

  Future<bool> toggleFavorite(int id, String u, String t, String i) async { return (await http.post(Uri.parse('$baseUrl/Favorites'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"TourId": id, "Username": u, "TourTitle": t, "TourImage": i}))).statusCode == 200; }
  Future<List<Map<String,dynamic>>> getMyFavorites(String u) async { try{final r=await http.get(Uri.parse('$baseUrl/Favorites/$u')); return r.statusCode==200?List<Map<String,dynamic>>.from(jsonDecode(r.body)):[];}catch(e){return[];} }

  // --- YENİ: GARAGE (GARAJIM) ---
  Future<List<Map<String,dynamic>>> getMyBikes(String u) async { try{final r=await http.get(Uri.parse('$baseUrl/Garage/$u')); return r.statusCode==200?List<Map<String,dynamic>>.from(jsonDecode(r.body)):[];}catch(e){return[];} }
  Future<bool> addBike(String u, String b, String m, int y, int cc) async { return (await http.post(Uri.parse('$baseUrl/Garage'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"OwnerUsername": u, "Brand": b, "Model": m, "Year": y, "EngineCc": cc, "ImageUrl": ""} ))).statusCode == 200; }
  Future<bool> deleteBike(int id) async { return (await http.delete(Uri.parse('$baseUrl/Garage/$id'))).statusCode == 204; }

  // 1. Turun duraklarını getir
  Future<List<RouteStop>> getRouteStops(int tourId) async {
    // URL senin localhost veya sunucu adresin
    final response = await http.get(Uri.parse('$baseUrl/routestops/$tourId'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => RouteStop.fromJson(item)).toList();
    } else {
      return []; // Hata varsa veya liste boşsa boş liste dön
    }
  }

  // 2. Yeni durak ekle
  Future<bool> addRouteStop(RouteStop stop) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routestops'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(stop.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // --- YENİ: RATINGS (PUANLAMA) ---
  Future<Map<String,dynamic>> getRating(int tId) async { try{final r=await http.get(Uri.parse('$baseUrl/Ratings/average/$tId')); return r.statusCode==200?jsonDecode(r.body):{"average":0.0,"count":0};}catch(e){return{"average":0.0,"count":0};} }
  Future<bool> rateTour(int tId, String u, int s) async { return (await http.post(Uri.parse('$baseUrl/Ratings'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"TourId": tId, "Username": u, "Score": s}))).statusCode == 200; }

  // --- YENİ: SOS (ACİL DURUM) ---
  Future<Map<String,dynamic>?> getSOS(String u) async { try{final r=await http.get(Uri.parse('$baseUrl/Emergency/$u')); return r.statusCode==200?jsonDecode(r.body):null;}catch(e){return null;} }
  Future<bool> saveSOS(String u, String b, String n, String p, String notes) async { return (await http.post(Uri.parse('$baseUrl/Emergency'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"Username": u, "BloodType": b, "EmergencyContactName": n, "EmergencyContactPhone": p, "Notes": notes}))).statusCode == 200; }

  // --- YENİ: FOLLOW (TAKİP) ---
  Future<Map<String,dynamic>> getFollowStats(String u) async { try{final r=await http.get(Uri.parse('$baseUrl/Follows/stats/$u')); return r.statusCode==200?jsonDecode(r.body):{"followers":0,"following":0};}catch(e){return{"followers":0,"following":0};} }
  Future<bool> toggleFollow(String me, String other) async { return (await http.post(Uri.parse('$baseUrl/Follows/toggle'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"FollowerUsername": me, "FollowingUsername": other}))).statusCode == 200; }

  Future<bool> isFavorite(String username, int tourId) async {
      // Basit çözüm: Tüm favorileri çekip içinde var mı bakarız
      final favs = await getMyFavorites(username);
      return favs.any((f) => f['tourId'] == tourId);
  }

  Future<bool> isFollowing(String me, String other) async {
      return false; // Varsayılan
  }

  Future<bool> leaveTour(int tourId, String username) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/Participations/leave?tourId=$tourId&username=$username'),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // Katılım Durumunu Kontrol Et
  Future<bool> isJoined(int tourId, String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Participations/check?tourId=$tourId&username=$username'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isJoined'];
      }
      return false;
    } catch (e) { return false; }
  }

 

}
