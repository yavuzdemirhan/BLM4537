import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tour_model.dart';

class ApiService {
  //  HTTP PORT (LaunchSettings'den baktığın)
  final String baseUrl = "http://localhost:5293/api"; 

// --- 1. GİRİŞ YAPMA ----
  Future<bool> login(String email, String password) async {
    try {
      print("Giriş isteği atılıyor: $email"); // KONSOL LOGU
      final response = await http.post(
        Uri.parse('$baseUrl/Account/login'), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Email": email,
          "Password": password,
        }),
      );

      print("Backend Cevabı Code: ${response.statusCode}"); // KONSOL LOGU
      print("Backend Cevabı Body: ${response.body}");      

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        String token = data['token'];
        String username = data['username'] ?? data['userName'] ?? data['UserName'] ?? "İsimsiz Sürücü";
        String userEmail = email; // Giriş yapılan maili alıyoruz

        // Telefona Kaydet
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('saved_username', username);
        await prefs.setString('saved_email', userEmail);
        await prefs.setBool('is_logged_in', true);
        
        print("Telefona kaydedildi: $username"); // KONSOL LOGU
        return true;
      }
      return false;
    } catch (e) {
      print("Login hatası: $e");
      return false;
    }
  }


 // ---- 2. KAYIT OLMA ---
  Future<bool> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Account/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"Username": username, "Email": email, "Password": password}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // --- 3. TURLARI GETİR ---
  Future<List<Tour>> getAllTours() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tours'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Tour.fromJson(item)).toList();
      } else {
        return []; 
      }
    } catch (e) {
      return [];
    }
  }
  
  // --- 4. TUR EKLE ---
  Future<bool> createTour(Tour tour) async {
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
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

// -- 5 ÇIKIŞ YAPMA ----
 Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Her şeyi sil
      print("Hafıza temizlendi, çıkış yapıldı.");
    } catch (e) {
      print("Çıkış hatası: $e");
    }
  }
}