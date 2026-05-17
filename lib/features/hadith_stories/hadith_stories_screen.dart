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
  IslamicStory _currentStory = StoriesData.stories[0];
  bool _showArabicStory = true;

  // --- Quote State ---
  Quote? _currentQuote;
  bool _quoteLoading = false;
  String? _quoteError;
  bool _islamicQuoteMode = true;
  final List<Quote> _savedQuotes = [];

  // --- Daily Wisdom ---
  bool _showDailyWisdom = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRandomHadith();
    _loadRandomQuote();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ===================== HADITH =====================

  Future<void> _loadRandomHadith() async {
    setState(() {
      _hadithLoading = true;
      _hadithError = null;
    });
    try {
      final hadith = await HadithService.fetchRandomHadith(_selectedCollection);
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

  void _nextStory() {
    final random = Random();
    final index = random.nextInt(StoriesData.stories.length);
    setState(() {
      _currentStory = StoriesData.stories[index];
    });
  }

  // ===================== QUOTES =====================

  Future<void> _loadRandomQuote() async {
    setState(() {
      _quoteLoading = true;
      _quoteError = null;
    });
    try {
      Quote quote;
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
      // Fallback to Islamic quote
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
              // App Bar
              _buildAppBar(),
              // Tab Bar
              _buildTabBar(),
              // Tab Content
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
          // Collection Selector
          _buildCollectionSelector(),
          const SizedBox(height: 16),
          // Hadith Content
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
            // Header
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
            // Divider
            Container(height: 1, color: Colors.amber.shade700.withOpacity(0.2)),
            const SizedBox(height: 16),
            // Hadith Number
            Text(
              'الحديث رقم ${hadith.hadithNumber}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            // Hadith Text - Arabic
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
            // Hadith Text - English
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
            // Grade and Section
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
            // Actions
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Story Card
          _buildStoryCard(),
          const SizedBox(height: 16),
          // Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade700, Colors.deepOrange.shade600],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _nextStory,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shuffle, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'قصة أخرى',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
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
    final story = _currentStory;
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
            // Title & Badge
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
                          style: TextStyle(
                            color: Colors.amber.shade300,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Source
            Text(
              story.source,
              style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.purple.shade300.withOpacity(0.2)),
            const SizedBox(height: 14),
            // Story Content
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
            // Moral Lesson
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.teal.shade700.withOpacity(0.2),
                    Colors.teal.shade900.withOpacity(0.2),
                  ],
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
                        style: TextStyle(
                          color: Colors.teal.shade300,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Directionality(
                    textDirection: _showArabicStory ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      _showArabicStory ? story.moralAr : story.moralEn,
                      textAlign: _showArabicStory ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.white.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Toggle Language
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() => _showArabicStory = !_showArabicStory);
                  },
                  icon: Icon(
                    _showArabicStory ? Icons.translate : Icons.language,
                    size: 16,
                    color: Colors.purple.shade300,
                  ),
                  label: Text(
                    _showArabicStory ? 'عرض بالإنجليزية' : 'عرض بالعربية',
                    style: TextStyle(color: Colors.purple.shade300, fontSize: 12),
                  ),
                ),
              ],
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
          // Toggle Mode
          _buildModeToggle(),
          const SizedBox(height: 16),
          // Quote Card
          _quoteLoading
              ? _buildLoadingState('جاري تحميل الاقتباس...')
              : _currentQuote != null
                  ? _buildQuoteCard()
                  : _buildErrorState('فشل تحميل الاقتباس'),
          const SizedBox(height: 20),
          // Daily Wisdom
          _buildDailyWisdomSection(),
          const SizedBox(height: 20),
          // Saved Quotes
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
                      style: TextStyle(
                        color: _islamicQuoteMode ? Colors.green.shade300 : Colors.white54,
                        fontWeight: _islamicQuoteMode ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
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
                      style: TextStyle(
                        color: !_islamicQuoteMode ? Colors.blue.shade300 : Colors.white54,
                        fontWeight: !_islamicQuoteMode ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
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
          colors: [
            const Color(0xFF1A3A2A).withOpacity(0.8),
            const Color(0xFF0F2A1A).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade300.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Quote Icon
            Icon(Icons.format_quote, size: 40, color: Colors.green.shade300.withOpacity(0.3)),
            const SizedBox(height: 8),
            // Arabic Quote
            if (quote.textAr != null)
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  quote.textAr!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.6,
                    color: Colors.white,
                    fontFamily: 'sans-serif',
                  ),
                ),
              ),
            if (quote.textAr != null) const SizedBox(height: 12),
            // English Quote
            Text(
              quote.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.white.withOpacity(0.85),
                fontFamily: 'serif',
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            // Attribution
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 14, color: Colors.green.shade300),
                  const SizedBox(width: 6),
                  Text(
                    quote.attribution,
                    style: TextStyle(color: Colors.green.shade300, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.content_copy, 'نسخ', () {
                  Clipboard.setData(ClipboardData(text: quote.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ الاقتباس')),
                  );
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
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Colors.green.shade300),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyWisdomSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade900.withOpacity(0.3),
            Colors.orange.shade900.withOpacity(0.2),
          ],
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
                Text(
                  'حكمة اليوم',
                  style: TextStyle(
                    color: Colors.amber.shade300,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  color: Colors.white,
                  fontFamily: 'sans-serif',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"Our Lord, give us in this world good and in the Hereafter good and protect us from the torment of the Fire."',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '— Quran 2:201',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.amber.shade300.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
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
            Text(
              'المحفوظات (${_savedQuotes.length})',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          saved.text,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              saved.attribution,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.green.shade300.withOpacity(0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
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
          Text(
            message,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
          ),
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
          Text(
            message,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadRandomHadith,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('حاول مرة أخرى'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: Colors.amber.shade300),
      ),
    );
  }
}
