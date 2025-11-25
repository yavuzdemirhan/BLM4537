import 'package:flutter/material.dart';
import '../models/tour_model.dart';
import '../services/api_service.dart';

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
  String _kategori = "Touring";
  DateTime _selectedDate = DateTime.now();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final newTour = Tour(
        id: 0,
        baslik: _baslikCtrl.text,
        aciklama: _aciklamaCtrl.text,
        rota: _rotaCtrl.text,
        motosikletKategorisi: _kategori,
        tarih: _selectedDate,
      );

      final success = await ApiService().createTour(newTour);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rota Oluşturuldu!"), backgroundColor: Colors.green));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Yeni Rota Planla"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _inputField(_baslikCtrl, "Tur Başlığı", Icons.title),
              const SizedBox(height: 15),
              _inputField(_rotaCtrl, "Rota (Başlangıç - Bitiş)", Icons.map),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _kategori,
                      decoration: _inputDecor("Kategori"),
                      items: ["Touring", "Enduro", "Racing", "Chopper"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _kategori = v!),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2030), initialDate: DateTime.now());
                        if (d != null) setState(() => _selectedDate = d);
                      },
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [const Icon(Icons.calendar_today, color: Colors.red), const SizedBox(width: 10), Text("${_selectedDate.day}.${_selectedDate.month}")]),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(controller: _aciklamaCtrl, maxLines: 4, decoration: _inputDecor("Detaylı Açıklama"), validator: (v) => v!.isEmpty ? "Gerekli" : null),
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, height: 55, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: _submit, child: const Text("KAYDET", style: TextStyle(fontSize: 18, color: Colors.white)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, IconData icon) => TextFormField(controller: ctrl, decoration: _inputDecor(label, icon: icon), validator: (v) => v!.isEmpty ? "Gerekli" : null);

  InputDecoration _inputDecor(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.redAccent) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true, fillColor: Colors.grey[50],
    );
  }
}