import 'package:flutter/material.dart';
import '../models/tour_model.dart';

class TourDetailScreen extends StatelessWidget {
  final Tour tour;
  final String imageUrl; // Resmi ana sayfadan paslıyoruz
  const TourDetailScreen({super.key, required this.tour, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300, pinned: true, backgroundColor: Colors.redAccent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(tag: "img-${tour.id}", child: Image.network(imageUrl, fit: BoxFit.cover)),
                ),
                leading: Container(margin: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Chip(label: Text(tour.motosikletKategorisi), backgroundColor: Colors.red[50], labelStyle: const TextStyle(color: Colors.red)),
                        Text("${tour.tarih.day}.${tour.tarih.month}.${tour.tarih.year}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ]),
                      const SizedBox(height: 10),
                      Text(tour.baslik, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      Row(children: [const Icon(Icons.location_on, color: Colors.red), const SizedBox(width: 5), Text(tour.rota, style: const TextStyle(fontSize: 16, color: Colors.black87))]),
                      const Divider(height: 40),
                      const Text("Açıklama", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(tour.aciklama, style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black54)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 10),
              onPressed: () {},
              child: const Text("TURA KATIL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}