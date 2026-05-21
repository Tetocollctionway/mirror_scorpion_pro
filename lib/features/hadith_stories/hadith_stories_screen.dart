import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/hadith_model.dart';
import 'models/story_model.dart';
import 'services/hadith_service.dart';
import 'services/quote_service.dart';
import 'data/stories_data.dart';

class HadithStoriesScreen extends StatefulWidget {
  const HadithStoriesScreen({super.key});

  @override
  State<HadithStoriesScreen> createState() => _HadithStoriesScreenState();
}

class _HadithStoriesScreenState extends State<HadithStoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Hadith State ---
  Hadith? _currentHadith;
  bool _hadithLoading = false;
  String? _hadithError;
  HadithCollection _selectedCollection = HadithCollection.collections[0];
  bool _showArabicHadith = true;

  // --- Story State ---
  String _selectedStoryCategory = 'prophets'; // التصنيف الفرعي المختار
  IslamicStory? _currentStory;
  bool _showArabicStory = true;
  final TextEditingController _creativityController = TextEditingController(); // لمحطة الإبداع

  // --- Quote State ---
  IslamicQuote? _currentQuote;
  bool _quoteLoading = false;
  String? _quoteError;
  bool _islamicQuoteMode = true;
  final List<IslamicQuote> _savedQuotes = [];

  // --- Daily Wisdom ---
  bool _showDailyWisdom = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRandomHadith();
    _filterStoriesByCategory();
    _loadRandomQuote();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _creativityController.dispose();
    super.dispose();
  }

  // ===================== HADITH =====================

  Future<void> _loadRandomHadith() async {
    setState(() {
      _hadithLoading = true;
      _hadithError = null;
    });
    try {
      final hadith = await HadithService.fetchRandomHadith(_selectedCollection.apiPrefix);
      setState(() {
        _currentHadith = hadith;
        _hadithLoading = false;
      });
    } catch (e) {
      setState(() {
        _hadithError = e.toString();
        _hadithLoading = false;
      });
    }
  }

  void _selectCollection(HadithCollection collection) {
    setState(() {
      _selectedCollection = collection;
    });
    _loadRandomHadith();
  }

  // ===================== STORIES =====================

  void _filterStoriesByCategory() {
    // تصفية القصص بناءً على التصنيف المختار
    final filtered = StoriesData.stories
        .where((s) => s.category == _selectedStoryCategory)
        .toList();

    if (filtered.isNotEmpty) {
      final random = Random();
      setState(() {
        _currentStory = filtered[random.nextInt(filtered.length)];
      });
    } else {
      setState(() {
        _currentStory = null; // في حال لم تتوفر داتا بعد
      });
    }
  }

  void _nextStory() {
    if (_selectedStoryCategory == 'creativity') return;
    _filterStoriesByCategory();
  }

  // دالة فحص المحتوى الصارمة لمحطة الإبداع
  bool _isContentSafe(String text) {
    final bannedWords = [
      'تنمر', 'سخرية', 'شتيمة', 'كره', 'عنصرية', 'طائفية'
    ]; // سيتم توسيعها برمجياً
    for (var word in bannedWords) {
      if (text.contains(word)) return false;
    }
    return true;
  }

  void _generateCreativeStory() {
    final userMood = _creativityController.text.trim();
    if (userMood.isEmpty) return;

    if (!_isContentSafe(userMood)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('عذراً، يجب أن يكون المحتوى خالياً من الكراهية أو التنمر أو الإساءة.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // منطق التوليد (برمجياً أو عبر الـ API) سيتم ربطه هنا
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري إلهام قصة خاصة بمزاجك...')),
    );
  }

  // ===================== QUOTES =====================

  Future<void> _loadRandomQuote() async {
    setState(() {
      _quoteLoading = true;
      _quoteError = null;
    });
    try {
      IslamicQuote quote;
      if (_islamicQuoteMode) {
        quote = QuoteService.getRandomIslamicQuote();
      } else {
        quote = await QuoteService.fetchZenQuote();
      }
      setState(() {
        _currentQuote = quote;
        _quoteLoading = false;
      });
    } catch (e) {
      final quote = QuoteService.getRandomIslamicQuote();
      setState(() {
        _currentQuote = quote;
        _quoteLoading = false;
        _quoteError = null;
      });
    }
  }

  void _toggleQuoteMode() {
    setState(() {
      _islamicQuoteMode = !_islamicQuoteMode;
    });
    _loadRandomQuote();
  }

  void _saveQuote() {
    if (_currentQuote != null) {
      setState(() {
        _savedQuotes.insert(0, _currentQuote!);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حفظ الاقتباس ✓'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeSavedQuote(int index) {
    setState(() {
      _savedQuotes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF0D1B2A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHadithTab(),
                    _buildStoriesTab(),
                    _buildInspirationTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإلهام الروحي',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade300,
                    fontFamily: 'sans-serif',
                  ),
                ),
                Text(
                  'Hadith • Stories • Inspiration',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.amber.shade700.withOpacity(0.3),
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.amber.shade300,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(icon: Icon(Icons.menu_book, size: 18), text: 'حديث'),
          Tab(icon: Icon(Icons.auto_stories, size: 18), text: 'قصص'),
          Tab(icon: Icon(Icons.lightbulb_outline, size: 18), text: 'إلهام'),
        ],
      ),
    );
  }

  // ===================== HADITH TAB =====================

  Widget _buildHadithTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCollectionSelector(),
          const SizedBox(height: 16),
          _hadithLoading
              ? _buildLoadingState('جاري تحميل الحديث...')
              : _hadithError != null
                  ? _buildErrorState('فشل تحميل الحديث، حاول مرة أخرى')
                  : _currentHadith != null
                      ? _buildHadithCard()
                      : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildCollectionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر الموسوعة الحديثية',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: HadithCollection.collections.map((collection) {
              final isSelected = collection.name == _selectedCollection.name;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    isSelected ? collection.displayNameAr : collection.displayNameAr.split(' ').last,
                    style: TextStyle(
                      color: isSelected ? Colors.amber.shade300 : Colors.white70,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.amber.shade700.withOpacity(0.3),
                  backgroundColor: Colors.white.withOpacity(0.08),
                  side: BorderSide(
                    color: isSelected ? Colors.amber.shade600 : Colors.white24,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (_) => _selectCollection(collection),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHadithCard() {
    final hadith = _currentHadith!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A3A4A).withOpacity(0.8),
            const Color(0xFF0F2A38).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade700.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade900.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 14, color: Colors.amber.shade300),
                      const SizedBox(width: 6),
                      Text(
                        _selectedCollection.displayNameAr,
                        style: TextStyle(
                          color: Colors.amber.shade300,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildIconButton(Icons.copy, () {
                      Clipboard.setData(ClipboardData(text: hadith.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ الحديث')),
                      );
                    }),
                    const SizedBox(width: 6),
                    _buildIconButton(Icons.refresh, _loadRandomHadith),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: Colors.amber.shade700.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'الحديث رقم ${hadith.hadithNumber}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            if (hadith.textAr != null && _showArabicHadith)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2A38).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    hadith.textAr!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.8,
                      color: Colors.white,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                ),
              ),
            if (hadith.text.isNotEmpty)
              Text(
                hadith.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.white.withOpacity(0.85),
                  fontFamily: 'serif',
                ),
              ),
            const SizedBox(height: 16),
            if (hadith.grade != null || hadith.section != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hadith.grade != null)
                      _buildInfoRow(Icons.star_half, 'التقييم', hadith.grade!),
                    if (hadith.section != null)
                      Padding(
                        padding: EdgeInsets.only(top: hadith.grade != null ? 6 : 0),
                        child: _buildInfoRow(Icons.bookmark, 'القسم', hadith.section!),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() => _showArabicHadith = !_showArabicHadith);
                  },
                  icon: Icon(
                    _showArabicHadith ? Icons.language : Icons.text_fields,
                    size: 16,
                    color: Colors.amber.shade300,
                  ),
                  label: Text(
                    _showArabicHadith ? 'إخفاء العربية' : 'إظهار العربية',
                    style: TextStyle(color: Colors.amber.shade300, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.amber.shade300),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
          ),
        ),
      ],
    );
  }

  // ===================== STORIES TAB =====================

  Widget _buildStoriesTab() {
    final categories = [
      {'id': 'prophets', 'title': 'قصص الأنبياء'},
      {'id': 'animals', 'title': 'قصص الحيوان'},
      {'id': 'women', 'title': 'قصص النساء'},
      {'id': 'creativity', 'title': 'محطة الإبداع'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط التصنيفات الفرعية الجديد للقصص
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories.map((cat) {
                final isSelected = _selectedStoryCategory == cat['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      cat['title']!,
                      style: TextStyle(
                        color: isSelected ? Colors.purple.shade200 : Colors.white70,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.purple.shade700.withOpacity(0.3),
                    backgroundColor: Colors.white.withOpacity(0.08),
                    side: BorderSide(
                      color: isSelected ? Colors.purple.shade400 : Colors.white24,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (_) {
                      setState(() {
                        _selectedStoryCategory = cat['id']!;
                      });
                      _filterStoriesByCategory();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // الـ Card الخاص بالقصص أو بمحطة الإبداع
          _selectedStoryCategory == 'creativity'
              ? _buildCreativityCard()
              : _buildStoryCard(),
          const SizedBox(height: 16),
          // زر الانتقال (يختفي في محطة الإبداع)
          if (_selectedStoryCategory != 'creativity')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade600, Colors.deepPurple.shade700],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _nextStory,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shuffle, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'قصة أخرى',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStoryCard() {
    if (_currentStory == null) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('قريباً.. جاري تجميع داتا هذا القسم بمصادرها الموثوقة', style: TextStyle(color: Colors.white54)),
      );
    }

    final story = _currentStory!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2A1A3A).withOpacity(0.8),
            const Color(0xFF1A0F28).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade300.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _showArabicStory ? story.titleAr : story.titleEn,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade200,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                ),
                if (story.isProphetsStory)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 12, color: Colors.amber.shade300),
                        const SizedBox(width: 4),
                        Text(
                          'قصة نبي',
                          style: TextStyle(color: Colors.amber.shade300, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              story.source,
              style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.purple.shade300.withOpacity(0.2)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Directionality(
                textDirection: _showArabicStory ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  _showArabicStory ? story.storyAr : story.storyEn,
                  textAlign: _showArabicStory ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: _showArabicStory ? 16 : 14,
                    height: 1.7,
                    color: Colors.white.withOpacity(0.85),
                    fontFamily: 'sans-serif',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade700.withOpacity(0.2), Colors.teal.shade900.withOpacity(0.2)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade300.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: Colors.teal.shade300),
                      const SizedBox(width: 8),
                      Text(
                        'العبرة المستفادة',
                        style: TextStyle(color: Colors.teal.shade300, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Directionality(
                    textDirection: _showArabicStory ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      _showArabicStory ? story.moralAr : story.moralEn,
                      textAlign: _showArabicStory ? TextAlign.right : TextAlign.left,
                      style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white.withOpacity(0.8), fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() => _showArabicStory = !_showArabicStory);
                  },
                  icon: Icon(_showArabicStory ? Icons.translate : Icons.language, size: 16, color: Colors.purple.shade300),
                  label: Text(_showArabicStory ? 'عرض بالإنجليزية' : 'عرض بالعربية', style: TextStyle(color: Colors.purple.shade300, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreativityCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1E1A3A).withOpacity(0.8), const Color(0xFF100F28).withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.deepPurple.shade300.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'محطة الإبداع لتوليد القصص',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade200),
            ),
            const SizedBox(height: 8),
            Text(
              'اكتب تفاصيل أو مزاج القصة التي تريدها وسيقوم التطبيق بنسجها لك بشرط خلوها من أي محتوى مسيء.',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _creativityController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'مثال: قصة عن الصبر في مواجهة الصعاب ونهايتها سعيدة...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _generateCreativeStory,
              icon: const Icon(Icons.auto_fix_high, size: 18),
              label: const Text('توليد القصة الآن'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== INSPIRATION TAB =====================

  Widget _buildInspirationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModeToggle(),
          const SizedBox(height: 16),
          _quoteLoading
              ? _buildLoadingState('جاري تحميل الاقتباس...')
              : _currentQuote != null
                  ? _buildQuoteCard()
                  : _buildErrorState('فشل تحميل الاقتباس'),
          const SizedBox(height: 20),
          _buildDailyWisdomSection(),
          const SizedBox(height: 20),
          if (_savedQuotes.isNotEmpty) _buildSavedQuotesSection(),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_islamicQuoteMode) _toggleQuoteMode();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _islamicQuoteMode ? Colors.green.shade700.withOpacity(0.4) : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mosque, size: 16, color: _islamicQuoteMode ? Colors.green.shade300 : Colors.white54),
                    const SizedBox(width: 6),
                    Text(
                      'اقتباسات إسلامية',
                      style: TextStyle(color: _islamicQuoteMode ? Colors.green.shade300 : Colors.white54, fontWeight: _islamicQuoteMode ? FontWeight.bold : FontWeight.normal, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_islamicQuoteMode) _toggleQuoteMode();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_islamicQuoteMode ? Colors.blue.shade700.withOpacity(0.4) : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.light_mode, size: 16, color: !_islamicQuoteMode ? Colors.blue.shade300 : Colors.white54),
                    const SizedBox(width: 6),
                    Text(
                      'عام',
                      style: TextStyle(color: !_islamicQuoteMode ? Colors.blue.shade300 : Colors.white54, fontWeight: !_islamicQuoteMode ? FontWeight.bold : FontWeight.normal, fontSize: 12),
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

  Widget _buildQuoteCard() {
    final quote = _currentQuote!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A3A2A).withOpacity(0.8), const Color(0xFF0F2A1A).withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade300.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.format_quote, size: 40, color: Colors.green.shade300.withOpacity(0.3)),
            const SizedBox(height: 8),
            if (quote.textAr != null)
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  quote.textAr!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, height: 1.6, color: Colors.white, fontFamily: 'sans-serif'),
                ),
              ),
            if (quote.textAr != null) const SizedBox(height: 12),
            Text(
              quote.text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white.withOpacity(0.85), fontFamily: 'serif', fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 14, color: Colors.green.shade300),
                  const SizedBox(width: 6),
                  Text(
                    quote.attribution ?? '',
                    style: TextStyle(color: Colors.green.shade300, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.content_copy, 'نسخ', () {
                  Clipboard.setData(ClipboardData(text: quote.text));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الاقتباس')));
                }),
                _buildActionButton(Icons.bookmark_add, 'حفظ', _saveQuote),
                _buildActionButton(Icons.shuffle, 'تجديد', _loadRandomQuote),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: Colors.green.shade300),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildDailyWisdomSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade900.withOpacity(0.3), Colors.orange.shade900.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, size: 18, color: Colors.amber.shade300),
                const SizedBox(width: 8),
                Text('حكمة اليوم', style: TextStyle(color: Colors.amber.shade300, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, height: 1.6, color: Colors.white, fontFamily: 'sans-serif'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"Our Lord, give us in this world good and in the Hereafter good and protect us from the torment of the Fire."',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white.withOpacity(0.6)),
            ),
            const SizedBox(height: 8),
            Text(
              '— Quran 2:201',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.amber.shade300.withOpacity(0.7), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedQuotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bookmarks, size: 18, color: Colors.amber.shade300),
            const SizedBox(width: 8),
            Text('المحفوظات (${_savedQuotes.length})', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _savedQuotes.length,
            itemBuilder: (context, index) {
              final saved = _savedQuotes[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.08))),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(saved.text, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8), fontStyle: FontStyle.italic)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(saved.attribution ?? '', style: TextStyle(fontSize: 9, color: Colors.green.shade300.withOpacity(0.7)), overflow: TextOverflow.ellipsis),
                          ),
                          GestureDetector(
                            onTap: () => _removeSavedQuote(index),
                            child: Icon(Icons.delete_outline, size: 14, color: Colors.red.shade400),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          CircularProgressIndicator(color: Colors.amber.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadRandomHadith,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('حاول مرة أخرى'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: Colors.amber.shade300),
      ),
    );
  }
}
