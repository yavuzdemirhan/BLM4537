import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../services/api_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final ApiService _apiService = ApiService();
  List<Comment> _pendingComments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPending();
  }

  void _fetchPending() async {
    final comments = await _apiService.getPendingComments();
    if (mounted) {
      setState(() {
        _pendingComments = comments;
        _isLoading = false;
      });
    }
  }

  void _handleApprove(int id) async {
    bool success = await _apiService.approveComment(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Yorum onaylandı ve yayına alındı ✅"), backgroundColor: Colors.green));
      _fetchPending(); // Listeyi yenile
    }
  }

  void _handleDelete(int id) async {
    bool success = await _apiService.deleteComment(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Yorum reddedildi ve silindi 🗑️"), backgroundColor: Colors.red));
      _fetchPending(); // Listeyi yenile
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Admin Paneli 🛡️"),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : _pendingComments.isEmpty
              ? const Center(child: Text("Onay bekleyen yorum yok.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _pendingComments.length,
                  itemBuilder: (context, index) {
                    final comment = _pendingComments[index];
                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(comment.username, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text("${comment.createdAt.day}.${comment.createdAt.month}.${comment.createdAt.year}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(comment.content, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    onPressed: () => _handleApprove(comment.id),
                                    icon: const Icon(Icons.check, color: Colors.white),
                                    label: const Text("ONAYLA", style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
                                    onPressed: () => _handleDelete(comment.id),
                                    icon: const Icon(Icons.delete, color: Colors.white),
                                    label: const Text("REDDET", style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}