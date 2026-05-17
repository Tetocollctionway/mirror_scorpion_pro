import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/ai_service.dart';
import '../../services/tts_service.dart';
import '../../services/database_service.dart';

/// ───────────────────────────────────────────────
///  Card 4: Hadith / Stories / Inspiration
///  Three tabs: أحاديث | قصص | إلهام AI
/// ───────────────────────────────────────────────

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // ── Data ──
  List<Hadith> _hadiths = [];
  List<Story> _stories = [];
  bool _dataLoaded = false;

  // ── Filters ──
  String _storyFilter = 'الكل';

  // ── AI Inspiration ──
  final TextEditingController _inspirationController = TextEditingController();
  String _inspirationResult = '';
  bool _isGenerating = false;

  // ── Translation ──
  bool _showTranslation = false;
  String _translatedText = '';

  // ── Languages ──
  static const List<Map<String, String>> _languages = [
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'it', 'name': 'Italiano'},
    {'code': 'pt', 'name': 'Português'},
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'zh', 'name': '中文'},
    {'code': 'ja', 'name': '日本語'},
    {'code': 'ko', 'name': '한국어'},
    {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'ur', 'name': 'اردو'},
    {'code': 'fa', 'name': 'فارسی'},
    {'code': 'hi', 'name': 'हिन्दी'},
    {'code': 'id', 'name': 'Bahasa Indonesia'},
    {'code': 'ms', 'name': 'Bahasa Melayu'},
    {'code': 'sw', 'name': 'Kiswahili'},
    {'code': 'ha', 'name': 'Hausa'},
    {'code': 'ta', 'name': 'தமிழ்'},
    {'code': 'te', 'name': 'తెలుగు'},
    {'code': 'th', 'name': 'ไทย'},
    {'code': 'vi', 'name': 'Tiếng Việt'},
    {'code': 'nl', 'name': 'Nederlands'},
    {'code': 'pl', 'name': 'Polski'},
    {'code': 'uk', 'name': 'Українська'},
    {'code': 'el', 'name': 'Ελληνικά'},
    {'code': 'he', 'name': 'עברית'},
  ];
  String _targetLang = 'en';

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

  @override
  void dispose() {
    _tabController.dispose();
    _inspirationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final db = Provider.of<DatabaseService>(context, listen: false);
      final hadithsJson = await db.loadJson('assets/data/hadiths.json');
      final storiesJson = await db.loadJson('assets/data/stories.json');

      setState(() {
        _hadiths = (hadithsJson as List).map((e) => Hadith.fromJson(e)).toList();
        _stories = (storiesJson as List).map((e) => Story.fromJson(e)).toList();
        _dataLoaded = true;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تحميل البيانات')),
        );
      }
    }
  }

  // ── AI Inspiration ──
  Future<void> _generateInspiration() async {
    final topic = _inspirationController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال موضوع للإلهام')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _inspirationResult = '';
      _translatedText = '';
      _showTranslation = false;
    });

    try {
      final ai = Provider.of<AIService>(context, listen: false);
      final result = await ai.generateInspiration(topic: topic);
      setState(() {
        _inspirationResult = result;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل توليد الإلهام')),
        );
      }
    }
  }

  // ── Translate ──
  Future<void> _translateText(String text) async {
    if (text.isEmpty) return;
    try {
      final ai = Provider.of<AIService>(context, listen: false);
      final result = await ai.translate(
        text: text,
        fromLanguage: 'ar',
        toLanguage: _targetLang,
      );
      setState(() {
        _translatedText = result;
        _showTranslation = !_showTranslation;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشلت الترجمة')),
        );
      }
    }
  }

  // ── Speaker ──
  Future<void> _speakText(String text, String language) async {
    if (text.isEmpty) return;
    final tts = Provider.of<TTSService>(context, listen: false);
    await tts.speak(text, language: language);
  }

  // ── Copy ──
  void _copyText(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم النسخ'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أحاديث وقصص'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book), text: 'أحاديث'),
            Tab(icon: Icon(Icons.auto_stories), text: 'قصص'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'إلهام AI'),
          ],
        ),
      ),
      body: _dataLoaded
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildHadithsTab(),
                _buildStoriesTab(),
                _buildInspirationTab(),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  // ═══════════════════════════════════════════════
  //  TAB 1: Hadiths
  // ═══════════════════════════════════════════════
  Widget _buildHadithsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _hadiths.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSectionHeader(
            icon: Icons.menu_book,
            title: 'أحاديث نبوية',
            subtitle: '${_hadiths.length} أحاديث مع ترجمة وسماع',
          );
        }
        final hadith = _hadiths[index - 1];
        return _buildHadithCard(hadith);
      },
    );
  }

  Widget _buildHadithCard(Hadith hadith) {
    // Find a unique index for expansion
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_drop_down_circle, size: 20, color: Colors.deepOrange),
        ),
        title: Text(
          hadith.text.length > 60 ? '${hadith.text.substring(0, 60)}...' : hadith.text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          textDirection: TextDirection.rtl,
        ),
        subtitle: Text(
          hadith.source,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          // Full hadith text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.deepOrange.withOpacity(0.1)),
            ),
            child: Text(
              hadith.text,
              style: const TextStyle(fontSize: 15, height: 1.7),
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 8),
          // Source & narrator
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                'عن ${hadith.narrator}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hadith.source,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Translation ──
          TranslationSection(
            text: hadith.text,
            onTranslate: (lang) => _translateHadith(hadith.text, lang),
            onSpeak: (_) => _speakText(hadith.text, 'ar'),
            onCopy: () => _copyText(hadith.text),
            translatedText: _translatedText,
            showTranslation: _showTranslation,
            targetLang: _targetLang,
            onToggle: () => setState(() => _showTranslation = !_showTranslation),
            onLangChange: (v) => setState(() => _targetLang = v),
          ),
        ],
      ),
    );
  }

  Future<void> _translateHadith(String text, String targetLang) async {
    try {
      final ai = Provider.of<AIService>(context, listen: false);
      final result = await ai.translate(
        text: text,
        fromLanguage: 'ar',
        toLanguage: targetLang,
      );
      setState(() {
        _translatedText = result;
        _showTranslation = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشلت الترجمة')),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════
  //  TAB 2: Stories
  // ═══════════════════════════════════════════════
  Widget _buildStoriesTab() {
    final filtered = _storyFilter == 'الكل'
        ? _stories
        : _stories.where((s) => s.category == _storyFilter).toList();

    return Column(
      children: [
        // Category filter chips
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _storyCategories.map((cat) {
              final isSelected = _storyFilter == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(cat, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _storyFilter = cat),
                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Stories list
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('لا توجد قصص في هذا التصنيف'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildStoryCard(filtered[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStoryCard(Story story) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _getStoryColor(story.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.article, size: 20, color: _getStoryColor(story.category)),
        ),
        title: Text(
          story.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          textDirection: TextDirection.rtl,
        ),
        subtitle: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getStoryColor(story.category).withOpacity(0.08),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            story.category,
            style: TextStyle(fontSize: 10, color: _getStoryColor(story.category)),
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          // Story content
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStoryColor(story.category).withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getStoryColor(story.category).withOpacity(0.1)),
            ),
            child: Text(
              story.content,
              style: const TextStyle(fontSize: 14, height: 1.7),
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 8),

          // ── Story Reference ──
          if (story.reference.isNotEmpty)
            Row(
              children: [
                Icon(Icons.bookmark, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  story.reference,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          const SizedBox(height: 8),

          // ── Translation section ──
          TranslationSection(
            text: story.content,
            onTranslate: (lang) => _translateStory(story.content, lang),
            onSpeak: (_) => _speakText(story.content, 'ar'),
            onCopy: () => _copyText(story.content),
            translatedText: _translatedText,
            showTranslation: _showTranslation,
            targetLang: _targetLang,
            onToggle: () => setState(() => _showTranslation = !_showTranslation),
            onLangChange: (v) => setState(() => _targetLang = v),
          ),
        ],
      ),
    );
  }

  Future<void> _translateStory(String text, String targetLang) async {
    try {
      final ai = Provider.of<AIService>(context, listen: false);
      final result = await ai.translate(
        text: text,
        fromLanguage: 'ar',
        toLanguage: targetLang,
      );
      setState(() {
        _translatedText = result;
        _showTranslation = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشلت الترجمة')),
        );
      }
    }
  }

  Color _getStoryColor(String category) {
    switch (category) {
      case 'قصص قرآنية':
        return Colors.teal;
      case 'قصص الأنبياء':
        return Colors.indigo;
      case 'نساء مؤمنات':
        return Colors.pink;
      case 'قصص الحيوان':
        return Colors.green;
      case 'قصص البشر':
        return Colors.brown;
      case 'الأمم السابقة':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  // ═══════════════════════════════════════════════
  //  TAB 3: AI Inspiration
  // ═══════════════════════════════════════════════
  Widget _buildInspirationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Header ──
          _buildSectionHeader(
            icon: Icons.auto_awesome,
            title: 'توليد إلهام بالذكاء الاصطناعي',
            subtitle: 'اكتب موضوعاً ليولد لك AI نصاً ملهمًا',
          ),
          const SizedBox(height: 16),

          // ── Input field ──
          TextField(
            controller: _inspirationController,
            maxLines: 3,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'اكتب موضوع الإلهام... مثلاً: "الأمل" أو "النجاح" أو "الصبر"',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
              ),
              prefixIcon: Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 12),

          // ── Generate button ──
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateInspiration,
              icon: _isGenerating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.bolt),
              label: Text(_isGenerating ? 'جاري التوليد...' : 'توليد الإلهام'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Inspiration result ──
          if (_inspirationResult.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepOrange.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 18, color: Colors.deepOrange),
                      const SizedBox(width: 6),
                      const Text('نص ملهم', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.deepOrange)),
                      const Spacer(),
                      // Actions
                      _smallActionButton(Icons.volume_up, Colors.teal, () => _speakText(_inspirationResult, 'ar')),
                      const SizedBox(width: 6),
                      _smallActionButton(Icons.copy, Colors.blueGrey, () => _copyText(_inspirationResult)),
                      const SizedBox(width: 6),
                      _smallActionButton(Icons.translate, Colors.deepOrange, () => _translateText(_inspirationResult)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _inspirationResult,
                    style: const TextStyle(fontSize: 15, height: 1.8),
                    textDirection: TextDirection.rtl,
                  ),

                  // ── Translation result ──
                  if (_showTranslation && _translatedText.isNotEmpty) ...[
                    const Divider(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.indigo.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.translate, size: 14, color: Colors.indigo),
                              const SizedBox(width: 4),
                              Text(
                                'ترجمة (${_getLangName(_targetLang)})',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.indigo),
                              ),
                              const Spacer(),
                              _smallActionButton(Icons.volume_up, Colors.teal, () => _speakText(_translatedText, _targetLang)),
                              const SizedBox(width: 4),
                              _smallActionButton(Icons.copy, Colors.blueGrey, () => _copyText(_translatedText)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _translatedText,
                            style: const TextStyle(fontSize: 14, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Language selector ──
                  if (!_showTranslation)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('ترجمة إلى: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _targetLang,
                                isDense: true,
                                style: const TextStyle(fontSize: 12),
                                items: _languages.map((l) {
                                  return DropdownMenuItem(value: l['code'], child: Text(l['name']!));
                                }).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _targetLang = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

          // ── Suggested topics ──
          const SizedBox(height: 20),
          const Text('مواضيع مقترحة:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'الأمل', 'النجاح', 'الصبر', 'العزيمة', 'التحدي',
              'الإيمان', 'القوة', 'التسامح', 'العمل', 'الحكمة',
              'الشجاعة', 'الرحمة', 'العدل', 'الصدق', 'الطموح',
            ].map((topic) {
              return ActionChip(
                label: Text(topic, style: const TextStyle(fontSize: 12)),
                avatar: const Icon(Icons.touch_app, size: 14),
                onPressed: () {
                  _inspirationController.text = topic;
                  _generateInspiration();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _smallActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepOrange.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.deepOrange, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLangName(String code) {
    for (final l in _languages) {
      if (l['code'] == code) return l['name']!;
    }
    return code;
  }
}

// ═══════════════════════════════════════════════
//  Reusable Translation Section Widget
// ═══════════════════════════════════════════════

class TranslationSection extends StatelessWidget {
  final String text;
  final Function(String) onTranslate;
  final Function(String) onSpeak;
  final VoidCallback onCopy;
  final String translatedText;
  final bool showTranslation;
  final String targetLang;
  final VoidCallback onToggle;
  final Function(String) onLangChange;

  static const List<Map<String, String>> _langs = [
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'ur', 'name': 'اردو'},
    {'code': 'fa', 'name': 'فارسی'},
    {'code': 'id', 'name': 'Bahasa Indonesia'},
    {'code': 'ms', 'name': 'Bahasa Melayu'},
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'zh', 'name': '中文'},
    {'code': 'ja', 'name': '日本語'},
    {'code': 'ko', 'name': '한국어'},
    {'code': 'hi', 'name': 'हिन्दी'},
    {'code': 'sw', 'name': 'Kiswahili'},
    {'code': 'ha', 'name': 'Hausa'},
  ];

  const TranslationSection({
    super.key,
    required this.text,
    required this.onTranslate,
    required this.onSpeak,
    required this.onCopy,
    required this.translatedText,
    required this.showTranslation,
    required this.targetLang,
    required this.onToggle,
    required this.onLangChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Action buttons row ──
        Row(
          children: [
            // Speak
            _actionBtn(Icons.volume_up, Colors.teal, () => onSpeak('ar')),
            const SizedBox(width: 6),
            // Copy
            _actionBtn(Icons.copy, Colors.blueGrey, onCopy),
            const Spacer(),

            // Language selector
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: targetLang,
                  isDense: true,
                  style: const TextStyle(fontSize: 11),
                  items: _langs.map((l) {
                    return DropdownMenuItem(value: l['code'], child: Text(l['name']!, style: const TextStyle(fontSize: 11)));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) onLangChange(v);
                  },
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Translate button
            _actionBtn(
              Icons.translate,
              Colors.deepOrange,
              () => onTranslate(targetLang),
            ),
          ],
        ),

        // ── Translation result ──
        if (showTranslation) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.indigo.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.translate, size: 12, color: Colors.indigo),
                    const SizedBox(width: 4),
                    Text(
                      'ترجمة ($targetLang)',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.indigo),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => onToggle(),
                      child: const Icon(Icons.close, size: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  translatedText,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _actionBtn(Icons.volume_up, Colors.teal, () => onSpeak(targetLang)),
                    const SizedBox(width: 6),
                    _actionBtn(Icons.copy, Colors.blueGrey, () {
                      Clipboard.setData(ClipboardData(text: translatedText));
                    }),
                  ],
                ),
              ],
            ),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: () => onTranslate(targetLang),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.translate, size: 12, color: Colors.deepOrange),
                    const SizedBox(width: 4),
                    const Text('ترجمة', style: TextStyle(fontSize: 11, color: Colors.deepOrange)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Data Models
// ═══════════════════════════════════════════════

class Hadith {
  final String text;
  final String narrator;
  final String source;

  Hadith({required this.text, required this.narrator, required this.source});

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      text: json['text'] as String,
      narrator: json['narrator'] as String? ?? 'غير معروف',
      source: json['source'] as String? ?? '',
    );
  }
}

class Story {
  final String title;
  final String content;
  final String category;
  final String reference;

  Story({required this.title, required this.content, required this.category, this.reference = ''});

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? 'عام',
      reference: json['reference'] as String? ?? '',
    );
  }
}
