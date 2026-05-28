import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ai_service.dart';
import '../../services/tts_service.dart';
import '../../services/database_service.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _hadiths = [];
  List<Map<String, dynamic>> _stories = [];
  bool _dataLoaded = false;
  String _storyFilter = 'الكل';
  final TextEditingController _inspirationController = TextEditingController();
  String _inspirationResult = '';
  bool _isGenerating = false;
  bool _autoInspirationEnabled = false;

  static const List<String> _storyCategories = [
    'الكل', 'قصص قرآنية', 'قصص الأنبياء', 'نساء مؤمنات',
    'قصص الحيوان', 'قصص البشر', 'الأمم السابقة',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inspirationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = Provider.of<DatabaseService>(context, listen: false);
    await db.loadAllData();
    setState(() {
      _hadiths = List.from(db.hadiths)..shuffle();
      _stories = [
        ...db.quranStories.map((e) => {...e, 'category': 'قصص قرآنية'}),
        ...db.prophetStories.map((e) => {...e, 'category': 'قصص الأنبياء'}),
        ...db.womenStories.map((e) => {...e, 'category': 'نساء مؤمنات'}),
        ...db.animalStories.map((e) => {...e, 'category': 'قصص الحيوان'}),
        ...db.humanStories.map((e) => {...e, 'category': 'قصص البشر'}),
        ...db.nationsStories.map((e) => {...e, 'category': 'الأمم السابقة'}),
      ];
      _dataLoaded = true;
    });
  }

  void _showStoryDialog(Map<String, dynamic> story) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(story['title'] ?? 'قصة', style: const TextStyle(color: Colors.white)),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionBtn(
                        icon: Icons.volume_up,
                        label: 'سماع القصة',
                        color: Colors.blueAccent,
                        onTap: () => Provider.of<TTSService>(context, listen: false).speak(story['text_ar'] ?? story['text'] ?? ''),
                      ),
                      _buildActionBtn(
                        icon: Icons.video_library,
                        label: 'مشاهدة القصة',
                        color: Colors.redAccent,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('سيتم توليد فيديو ذكاء اصطناعي مذهل مدته 10-15 دقيقة (نسخة برو)')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    story['text_ar'] ?? story['text'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      height: 1.8,
                      fontWeight: FontWeight.w400,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أحاديث وقصص وإلهام', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B2A),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'أحاديث'),
            Tab(text: 'قصص'),
            Tab(text: 'أسباب النزول'),
            Tab(text: 'إلهام AI'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)]
          )
        ),
        child: _dataLoaded
            ? TabBarView(
                controller: _tabController,
                children: [
                  _buildHadithsTab(),
                  _buildStoriesTab(),
                  _buildAsbabNuzulTab(),
                  _buildInspirationTab(),
                ],
              )
            : const Center(child: CircularProgressIndicator(color: Colors.amber)),
      ),
    );
  }

  Widget _buildHadithsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _hadiths.length,
      itemBuilder: (context, index) {
        final hadith = _hadiths[index];
        return _buildContentCard(
          title: hadith['narrator'] ?? 'حديث قدسي',
          content: hadith['text'] ?? '',
          subtitle: "${hadith['source'] ?? ''}\n${hadith['explanation'] ?? ''}",
          icon: Icons.auto_stories,
          color: Colors.amber,
          isHadith: true,
        );
      },
    );
  }

  Widget _buildStoriesTab() {
    final filtered = _storyFilter == 'الكل'
        ? _stories
        : _stories.where((s) => s['category'] == _storyFilter).toList();

    return Column(
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _storyCategories.map((cat) {
              final isSelected = _storyFilter == cat;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  label: Text(cat, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _storyFilter = cat),
                  selectedColor: Colors.amber,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final story = filtered[index];
              return _buildContentCard(
                title: story['title'] ?? '',
                content: story['text_ar'] ?? story['text'] ?? '',
                subtitle: story['category'] ?? '',
                icon: Icons.history_edu,
                color: Colors.blueAccent,
                showVideoBtn: true,
                showListenBtn: true,
                onTap: () => _showStoryDialog(story),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAsbabNuzulTab() {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final nuzulList = db.asbabNuzul;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: nuzulList.length,
      itemBuilder: (context, index) {
        final item = nuzulList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.teal.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.menu_book, color: Colors.teal, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'سورة ${item['surah']} - ${item['ayah']}',
                      style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.2)),
                ),
                child: Text(
                  item['text_ayah'] ?? '',
                  style: const TextStyle(color: Colors.amber, fontSize: 18, height: 1.6, fontFamily: 'serif'),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'سبب النزول:',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 6),
              Text(
                item['sabab'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.7),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 10),
              Text(
                item['source'] ?? '',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInspirationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("تفعيل الإلهام التلقائي (كل 3 ساعات)", style: TextStyle(color: Colors.white, fontSize: 14)),
              Switch(
                value: _autoInspirationEnabled,
                onChanged: (v) => setState(() => _autoInspirationEnabled = v),
                activeColor: Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _inspirationController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'كيف تشعر اليوم؟ (فرح، حزن، تعب...)',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateInspiration,
              icon: const Icon(Icons.auto_awesome),
              label: Text(_isGenerating ? 'جاري التحليل...' : 'اطلب كلمة تثبت فؤادك'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber, 
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_inspirationResult.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildContentCard(
              title: 'رسالة لقلبك',
              content: _inspirationResult,
              subtitle: 'بناءً على حالتك الحالية',
              icon: Icons.favorite,
              color: Colors.pinkAccent,
            ),
          ]
        ],
      ),
    );
  }

  Future<void> _generateInspiration() async {
    setState(() => _isGenerating = true);
    try {
      final result = await AIService.generateInspiration(
        userMood: _inspirationController.text.isNotEmpty
            ? _inspirationController.text
            : 'مستخدم يبحث عن الإلهام',
        context: 'Stories & Inspiration Screen',
      );
      setState(() {
        _inspirationResult = result;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _inspirationResult = "تذكر أن كل عسر يتبعه يسر، وأن ميرور سكربيون هنا ليدعم رحلتك.";
        _isGenerating = false;
      });
    }
  }

  Widget _buildContentCard({
    required String title,
    required String content,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool showVideoBtn = false,
    bool showListenBtn = true,
    bool isHadith = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(subtitle, style: TextStyle(color: color.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 15),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9), 
              fontSize: isHadith ? 20 : 16, // Larger for weak vision as requested
              height: 1.6,
              fontWeight: isHadith ? FontWeight.w500 : FontWeight.normal,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showVideoBtn)
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('سيتم توليد فيديو مبهر مدته 10-15 دقيقة (نسخة برو)')),
                    );
                  },
                  icon: const Icon(Icons.movie_creation, color: Colors.redAccent),
                  label: const Text('مشاهدة', style: TextStyle(color: Colors.redAccent)),
                ),
              if (showListenBtn)
                TextButton.icon(
                  onPressed: () {
                    Provider.of<TTSService>(context, listen: false).speak(content);
                  },
                  icon: const Icon(Icons.volume_up, color: Colors.blueAccent),
                  label: const Text('استماع', style: TextStyle(color: Colors.blueAccent)),
                ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}
