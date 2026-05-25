import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final db = Provider.of<DatabaseService>(context, listen: false);
    await db.loadAllData();
    setState(() {
      _hadiths = db.hadiths;
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
          tabs: const [
            Tab(text: 'أحاديث'),
            Tab(text: 'قصص'),
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
                  _buildInspirationTab(),
                ],
              )
            : const Center(child: CircularProgressIndicator(color: Colors.amber)),
      ),
    );
  }

  Widget _buildHadithsTab() {
    List<Map<String, dynamic>> shuffledHadiths = List.from(_hadiths)..shuffle();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shuffledHadiths.length,
      itemBuilder: (context, index) {
        final hadith = shuffledHadiths[index];
        return _buildContentCard(
          title: hadith['narrator'] ?? 'حديث قدسي',
          content: hadith['text'] ?? '',
          subtitle: hadith['source'] ?? 'معاني الكلمات متوفرة بالأسفل',
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
                content: story['text'] ?? '',
                subtitle: story['category'] ?? '',
                icon: Icons.history_edu,
                color: Colors.blueAccent,
                showVideoBtn: true,
                showListenBtn: true,
              );
            },
          ),
        ),
      ],
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
    // Simulate AI understanding user state
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _inspirationResult = "لقد استخدمت أدوات الترجمة والقصص مؤخراً، ويبدو أنك تبحث عن المعنى. تذكر أن كل عسر يتبعه يسر، وأن ميرور سكربيون هنا ليدعم رحلتك.";
      _isGenerating = false;
    });
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
  }) {
    return Container(
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
    );
  }
}
