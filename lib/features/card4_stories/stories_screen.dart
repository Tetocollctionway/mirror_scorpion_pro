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
      // Combine all stories for "All" filter
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
        title: const Text('أحاديث وقصص وإلهام', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
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
    // Shuffle hadiths for random order as requested
    List<Map<String, dynamic>> shuffledHadiths = List.from(_hadiths)..shuffle();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shuffledHadiths.length,
      itemBuilder: (context, index) {
        final hadith = shuffledHadiths[index];
        return _buildContentCard(
          title: hadith['narrator'] ?? 'حديث شريف',
          content: hadith['text'] ?? '',
          subtitle: hadith['source'] ?? '',
          icon: Icons.auto_stories,
          color: Colors.amber,
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
                color: Colors.blue,
                showVideoBtn: true,
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
        children: [
          TextField(
            controller: _inspirationController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'اكتب ما تشعر به للحصول على إلهام...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isGenerating ? null : _generateInspiration,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            child: Text(_isGenerating ? 'جاري التوليد...' : 'احصل على إلهام'),
          ),
          if (_inspirationResult.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildContentCard(
              title: 'رسالة ملهمة',
              content: _inspirationResult,
              subtitle: 'توليد ذكاء اصطناعي',
              icon: Icons.lightbulb,
              color: Colors.orange,
            ),
          ]
        ],
      ),
    );
  }

  Future<void> _generateInspiration() async {
    setState(() => _isGenerating = true);
    // Simulate AI Generation or call service
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _inspirationResult = "تذكر دائماً أن كل انكسار هو بداية لانطلاقة أعظم. قصتك لا تزال تُكتب، والنهاية لم يحن وقتها بعد.";
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              if (showVideoBtn)
                IconButton(
                  icon: const Icon(Icons.smart_display, color: Colors.red),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('جاري توليد فيديو القصة بالذكاء الاصطناعي...')),
                    );
                  },
                ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.blue),
                onPressed: () {
                  Provider.of<TTSService>(context, listen: false).speak(content);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: color.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
