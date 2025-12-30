import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://images.unsplash.com/photo-1609630875171-b1321377ee65?q=80&w=1000"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.7)), // Karartma
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.two_wheeler, size: 80, color: Colors.redAccent),
                    const SizedBox(height: 20),
                    const Text("MOTO ROTA", style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 5)),
                    const SizedBox(height: 10),
                    Text("Özgürlüğe Giden En Kısa Yol", style: TextStyle(color: Colors.grey[300], fontSize: 16)),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: double.infinity, height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                        child: const Text("ROTA OLUŞTUR", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, height: 55,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreenWrapper(initialIndex: 1))),
                        child: const Text("PROFİLİME GİT", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}