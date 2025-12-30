import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tour_model.dart';
import '../services/api_service.dart';
import '../models/route_stop.dart';

class AddTourScreen extends StatefulWidget {
  const AddTourScreen({super.key});
  @override
  State<AddTourScreen> createState() => _AddTourScreenState();
}

class _AddTourScreenState extends State<AddTourScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baslikCtrl = TextEditingController();
  final _rotaCtrl = TextEditingController();
  final _aciklamaCtrl = TextEditingController();
  final _imageCtrl = TextEditingController(); 
  
  String _kategori = "Touring";
  DateTime _selectedDate = DateTime.now();
  
  // Durakları burada tutacağız
  List<Map<String, String>> _tempStops = [];
  final _stopNameCtrl = TextEditingController();
  final _stopTimeCtrl = TextEditingController();

  void _addTempStop() {
    if (_stopNameCtrl.text.isEmpty) return;
    setState(() {
      _tempStops.add({
        "name": _stopNameCtrl.text,
        "time": _stopTimeCtrl.text.isEmpty ? "--:--" : _stopTimeCtrl.text
      });
      _stopNameCtrl.clear();
      _stopTimeCtrl.clear();
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String username = prefs.getString('saved_username') ?? "Misafir";

      final newTour = Tour(
        id: 0,
        baslik: _baslikCtrl.text,
        aciklama: _aciklamaCtrl.text,
        rota: _rotaCtrl.text,
        motosikletKategorisi: _kategori,
        tarih: _selectedDate,
        olusturanKisi: username,
        viewCount: 0,
        customImageUrl: _imageCtrl.text.isNotEmpty ? _imageCtrl.text : null,
        averageRating: 0
      );

      // 1. TURU OLUŞTUR VE ID'SİNİ AL
      final tourId = await ApiService().createTour(newTour, username);

      if (tourId != -1) {
        // 2. EĞER GEÇİCİ LİSTEDE DURAK VARSA ONLARI NESNEYE ÇEVİRİP EKLE
        for (int i = 0; i < _tempStops.length; i++) {
          
          // Model nesnesini oluşturuyoruz
          RouteStop newStop = RouteStop(
            tourId: tourId, 
            stopName: _tempStops[i]['name'] ?? "", 
            description: "Tur Başlangıcı", 
            orderIndex: i + 1, 
            time: _tempStops[i]['time'] ?? "",
          );

          // API servisine nesne olarak gönderiyoruz
          await ApiService().addRouteStop(newStop);
        }

        // İşlem bitince ekranı kapat veya başarı mesajı göster
        if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tur ve rotalar başarıyla oluşturuldu!"), backgroundColor: Colors.green)
            );
        }


        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rota ve Duraklar Oluşturuldu! 🏁"), backgroundColor: Colors.redAccent));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hata oluştu"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212), 
      appBar: AppBar(title: const Text("Yeni Rota Planla"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _inputField(_baslikCtrl, "Tur Başlığı", Icons.title),
              const SizedBox(height: 15),
              _inputField(_rotaCtrl, "Rota (Başlangıç - Bitiş)", Icons.map),
              const SizedBox(height: 15),
              _inputField(_imageCtrl, "Kapak Fotoğrafı URL (İsteğe Bağlı)", Icons.image, isRequired: false),
              const SizedBox(height: 15),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _kategori,
                      dropdownColor: Colors.grey[900],
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecor("Kategori"),
                      items: ["Touring", "Enduro", "Racing", "Chopper"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _kategori = v!),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2030), initialDate: DateTime.now(),
                          builder: (context, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Colors.redAccent)), child: child!));
                        if (d != null) setState(() => _selectedDate = d);
                      },
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade700), borderRadius: BorderRadius.circular(10), color: const Color(0xFF1E1E1E)),
                        child: Row(children: [const Icon(Icons.calendar_today, color: Colors.redAccent), const SizedBox(width: 10), Text("${_selectedDate.day}.${_selectedDate.month}", style: const TextStyle(color: Colors.white))]),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(controller: _aciklamaCtrl, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: _inputDecor("Detaylı Açıklama"), validator: (v) => v!.isEmpty ? "Gerekli" : null),
              
              const SizedBox(height: 30),
              const Text("📍 Duraklar (Mola Yerleri)", style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              // DURAK EKLEME KISMI
              Row(children: [
                Expanded(flex: 2, child: SizedBox(height: 50, child: TextField(controller: _stopNameCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDecor("Durak Adı", padding: 10)))),
                const SizedBox(width: 10),
                Expanded(flex: 1, child: SizedBox(height: 50, child: TextField(controller: _stopTimeCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDecor("Saat", padding: 10)))),
                IconButton(onPressed: _addTempStop, icon: const Icon(Icons.add_circle, color: Colors.green, size: 40))
              ]),
              
              // EKLENEN DURAKLARIN LİSTESİ
              if(_tempStops.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: _tempStops.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        const Icon(Icons.place, color: Colors.redAccent, size: 16),
                        const SizedBox(width: 10),
                        Text(s['name']!, style: const TextStyle(color: Colors.white)),
                        const Spacer(),
                        Text(s['time']!, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 10),
                        InkWell(onTap: (){ setState(() => _tempStops.remove(s)); }, child: const Icon(Icons.close, color: Colors.red, size: 16))
                      ]),
                    )).toList(),
                  ),
                ),

              const SizedBox(height: 30),
              SizedBox(width: double.infinity, height: 55, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: _submit, child: const Text("ROTAYI OLUŞTUR", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, IconData icon, {bool isRequired = true}) => TextFormField(
    controller: ctrl, 
    style: const TextStyle(color: Colors.white),
    decoration: _inputDecor(label, icon: icon), 
    validator: (v) => isRequired && v!.isEmpty ? "Gerekli" : null
  );

  InputDecoration _inputDecor(String label, {IconData? icon, double padding = 15}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: icon != null ? Icon(icon, color: Colors.redAccent) : null,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade800)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent)),
      filled: true, fillColor: const Color(0xFF1E1E1E),
      contentPadding: EdgeInsets.all(padding),
    );
  }
}