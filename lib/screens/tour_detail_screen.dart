import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tour_model.dart';
import '../models/route_stop.dart';
import '../models/comment_model.dart';
import '../services/api_service.dart';

class TourDetailScreen extends StatefulWidget {
  final Tour tour;
  final String imageUrl;

  const TourDetailScreen({super.key, required this.tour, required this.imageUrl});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();

  // -- STATE DEĞİŞKENLERİ --
  bool _isCaptain = false;
  String _currentUsername = "";
  
  // Rating Verileri
  double _currentAverage = 0.0;
  int _ratingCount = 0;

  // Veriler
  List<RouteStop> _stops = [];
  bool _isLoadingStops = true;
  List<Comment> _comments = [];
  bool _isLoadingComments = true;

  // UI Durumları
  bool _isFavorited = false;
  bool _isJoined = false; // BAŞLANGIÇTA FALSE, API İLE KONTROL EDECEĞİZ
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    // Hızlı açılış için modelden gelen puanı koy
    _currentAverage = widget.tour.averageRating;
    
    _loadUserAndCheckStatus(); // <--- KRİTİK KISIM: KONTROL BURADA
    _fetchStops();
    _fetchComments();
    _fetchLiveRating();
  }

  // --- 1. KULLANICIYI YÜKLE, FAVORİ VE KATILIM DURUMUNU KONTROL ET ---
  Future<void> _loadUserAndCheckStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('saved_username') ?? "Anonim";
    
    setState(() {
      _currentUsername = user;
      _isCaptain = user == widget.tour.olusturanKisi;
    });

    if (user != "Anonim") {
      // A) FAVORİ KONTROLÜ
      bool favStatus = await _apiService.isFavorite(user, widget.tour.id);
      
      // B) KATILIM KONTROLÜ (SENİN CHECK API'N)
      bool joinStatus = await _apiService.isJoined(widget.tour.id, user);

      if (mounted) {
        setState(() {
          _isFavorited = favStatus;
          _isJoined = joinStatus; // Butonun rengini ve yazısını bu belirleyecek
        });
      }
    }
  }

  // --- 2. KATIL / AYRIL İŞLEMİ (TOGGLE) ---
  Future<void> _toggleJoin() async {
    // Eğer zaten katılmışsak -> Ayrıl (Leave)
    if (_isJoined) {
       bool success = await _apiService.leaveTour(widget.tour.id, _currentUsername);
       if (success) {
         setState(() => _isJoined = false);
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Turdan ayrıldınız."), backgroundColor: Colors.orange));
       } else {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ayrılırken hata oluştu."), backgroundColor: Colors.red));
       }
    } 
    // Katılmamışsak -> Katıl (Join)
    else {
      bool success = await _apiService.joinTour(widget.tour.id, widget.tour.baslik, _currentUsername);
      if (success) {
        setState(() => _isJoined = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tura başarıyla katıldınız!"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Katılırken hata oluştu."), backgroundColor: Colors.red));
      }
    }
  }

  // --- DİĞER API İŞLEMLERİ ---
  
  Future<void> _toggleFavorite() async {
    // Optimistic Update (Hemen tepki ver)
    setState(() => _isFavorited = !_isFavorited);
    bool success = await _apiService.toggleFavorite(widget.tour.id, _currentUsername, widget.tour.baslik, widget.imageUrl);
    if (!success) setState(() => _isFavorited = !_isFavorited); // Hata olursa geri al
  }

  Future<void> _fetchLiveRating() async {
    var data = await _apiService.getRating(widget.tour.id);
    setState(() {
      _currentAverage = (data['average'] as num).toDouble();
      _ratingCount = data['count'] as int;
    });
  }

  Future<void> _submitRating(int score) async {
    Navigator.pop(context); // Dialogu kapat
    bool success = await _apiService.rateTour(widget.tour.id, _currentUsername, score);
    if (success) {
      await _fetchLiveRating();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$score Yıldız verdiniz!"), backgroundColor: Colors.amber[700]));
    }
  }

  Future<void> _fetchStops() async {
    try {
      var s = await _apiService.getRouteStops(widget.tour.id);
      setState(() { _stops = s; _isLoadingStops = false; });
    } catch (e) { setState(() => _isLoadingStops = false); }
  }

  Future<void> _fetchComments() async {
    try {
      var c = await _apiService.getComments(widget.tour.id);
      setState(() { _comments = c; _isLoadingComments = false; });
    } catch (e) { setState(() => _isLoadingComments = false); }
  }

  Future<void> _handlePostComment() async {
    if (_commentController.text.isEmpty) return;
    Comment c = Comment(id: 0, tourId: widget.tour.id, username: _currentUsername, content: _commentController.text, createdAt: DateTime.now());
    if (await _apiService.postComment(c)) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
      _fetchComments();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Yorum paylaşıldı"), backgroundColor: Colors.green));
    }
  }

  String _formatDate(DateTime date) => "${date.day.toString().padLeft(2,'0')}.${date.month.toString().padLeft(2,'0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          // HEADER (Geri ve Favori)
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
            ),
            actions: [
              IconButton(
                icon: Icon(_isFavorited ? Icons.favorite : Icons.favorite_border, color: _isFavorited ? Colors.red : Colors.white),
                onPressed: _toggleFavorite,
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
              ),
              const SizedBox(width: 15),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.imageUrl, fit: BoxFit.cover),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.95)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
                ],
              ),
            ),
          ),

          // İÇERİK
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. KATEGORİ & PUAN (TIKLANABİLİR)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
                        child: Text(widget.tour.motosikletKategorisi.toUpperCase(), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      InkWell(
                        onTap: _showRatingDialog,
                        borderRadius: BorderRadius.circular(5),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 22),
                              const SizedBox(width: 4),
                              Text(_currentAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4),
                              Text("($_ratingCount oy)", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  Text(widget.tour.baslik, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, height: 1.1)),
                  const SizedBox(height: 15),

                  // 2. ROTA & TARİH
                  Row(children: [const Icon(Icons.map, color: Colors.redAccent, size: 20), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("ROTA", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)), Text(widget.tour.rota, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))]))]),
                  const SizedBox(height: 12),
                  Row(children: [const Icon(Icons.calendar_today, color: Colors.redAccent, size: 18), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("TARİH", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)), Text("${widget.tour.tarih.day}.${widget.tour.tarih.month}.${widget.tour.tarih.year}", style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))])]),

                  const SizedBox(height: 25),

                  // 3. KAPTAN
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const CircleAvatar(radius: 20, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=11")),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.tour.olusturanKisi, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const Text("Tur Kaptanı", style: TextStyle(color: Colors.grey, fontSize: 12))]),
                      const Spacer(),
                      if (!_isCaptain)
                        TextButton(onPressed: () => setState(() => _isFollowing = !_isFollowing), style: TextButton.styleFrom(backgroundColor: _isFollowing ? Colors.transparent : Colors.white, side: _isFollowing ? const BorderSide(color: Colors.white30) : null, padding: const EdgeInsets.symmetric(horizontal: 16)), child: Text(_isFollowing ? "Takipte" : "Takip Et", style: TextStyle(color: _isFollowing ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.bold)))
                      else
                        const Text("SEN", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ]),
                  ),

                  const SizedBox(height: 25),

                  // 4. AÇIKLAMA
                  const Text("AÇIKLAMA", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.tour.aciklama, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6)),

                  const SizedBox(height: 30),

                  // 5. DETAYLI ROTA PLANI
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("DETAYLI ROTA PLANI", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)), if (_isCaptain) InkWell(onTap: _showAddStopDialog, child: Row(children: const [Icon(Icons.add_circle, color: Colors.redAccent, size: 16), SizedBox(width: 4), Text("Durak Ekle", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold))]))]),
                  const SizedBox(height: 15),
                  if (_isLoadingStops) const Center(child: CircularProgressIndicator(color: Colors.redAccent)) else if (_stops.isEmpty) Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)), child: const Text("Henüz detaylı durak planı oluşturulmadı.", style: TextStyle(color: Colors.white54))) else ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _stops.length, itemBuilder: (context, index) => _buildTimelineItem(_stops[index], index == _stops.length - 1, index)),

                  const SizedBox(height: 30),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 20),

                  // 6. YORUMLAR
                  Text("YORUMLAR (${_comments.length})", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  if (_isLoadingComments) const Center(child: CircularProgressIndicator(color: Colors.redAccent)) else if (_comments.isEmpty) const Text("Henüz yorum yapılmamış.", style: TextStyle(color: Colors.grey)) else ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _comments.length, itemBuilder: (context, index) { final comment = _comments[index]; return Padding(padding: const EdgeInsets.only(bottom: 15), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 18, backgroundColor: Colors.grey[800], child: Text(comment.username.isNotEmpty ? comment.username[0].toUpperCase() : "?", style: const TextStyle(color: Colors.white))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(comment.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), Text(_formatDate(comment.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 10))]), const SizedBox(height: 4), Text(comment.content, style: const TextStyle(color: Colors.white70, fontSize: 13))]))])); }),

                  // Yorum Inputu
                  const SizedBox(height: 10),
                  TextField(controller: _commentController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Yorum yap...", hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), suffixIcon: IconButton(icon: const Icon(Icons.send, color: Colors.redAccent), onPressed: _handlePostComment))),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // --- ALT BAR (Full Width & Kutu İçinde) ---
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16), 
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E), 
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: ElevatedButton(
          onPressed: _toggleJoin, // YENİ KATILMA FONKSİYONU
          style: ElevatedButton.styleFrom(
            backgroundColor: _isJoined ? Colors.green[800] : Colors.redAccent, // Yeşil/Kırmızı Durumu
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text(
            _isJoined ? "KATILDINIZ (İPTAL ET)" : "TURA KATIL",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ),
      ),
    );
  }

  // --- OY VERME DİYALOĞU (Sade IconButton) ---
  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Center(child: Text("Turu Puanla", style: TextStyle(color: Colors.white))),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => _submitRating(index + 1),
                splashRadius: 24, 
                icon: const Icon(Icons.star, color: Colors.amber, size: 40),
              );
            }),
          ),
        );
      },
    );
  }

  // Helper Widgets
  Widget _buildTimelineItem(RouteStop stop, bool isLast, int index) {
    return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Column(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: index == 0 ? Colors.redAccent : (isLast ? Colors.white : Colors.grey[800]), shape: BoxShape.circle, border: Border.all(color: index == 0 ? Colors.redAccent : Colors.white24, width: 2))), if (!isLast) Expanded(child: Container(width: 2, color: Colors.white12))]), const SizedBox(width: 15), Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 25.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(stop.stopName, style: TextStyle(color: index == 0 ? Colors.white : (isLast ? Colors.white : Colors.white70), fontSize: 16, fontWeight: index == 0 || isLast ? FontWeight.bold : FontWeight.normal)), if (stop.time.isNotEmpty) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)), child: Text(stop.time, style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)))]), if (stop.description.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(stop.description, style: TextStyle(color: Colors.grey[600], fontSize: 12))) ]))) ]));
  }

  void _showAddStopDialog() {
    TextEditingController n=TextEditingController(),d=TextEditingController(),t=TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: const Color(0xFF1E1E1E), title: const Text("Yeni Durak Ekle", style: TextStyle(color: Colors.white)), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: n, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Durak Adı", hintStyle: TextStyle(color: Colors.white24))), TextField(controller: d, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Açıklama", hintStyle: TextStyle(color: Colors.white24))), TextField(controller: t, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Saat", hintStyle: TextStyle(color: Colors.white24)))]), actions: [TextButton(onPressed:()=>Navigator.pop(context),child:const Text("İptal",style:TextStyle(color:Colors.grey))),TextButton(onPressed:()async{if(n.text.isNotEmpty){Navigator.pop(context);bool s=await _apiService.addRouteStop(RouteStop(tourId:widget.tour.id,stopName:n.text,description:d.text,orderIndex:_stops.length+1,time:t.text));if(s){_fetchStops();ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Eklendi"),backgroundColor:Colors.green));}}},child:const Text("Ekle",style:TextStyle(color:Colors.redAccent,fontWeight:FontWeight.bold)))]));
  }
}