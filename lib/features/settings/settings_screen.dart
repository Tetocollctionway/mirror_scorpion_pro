import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';
import '../../services/floating_bubble_service.dart';
import '../about/about_app_screen.dart';
import '../../core/theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _isPremium = false;
  String _selectedVoice = 'voice_1_female';
  bool _bubbleEnabled = false;
  double _bubbleOpacity = 0.8;
  int _bubbleSize = 120;
  bool _bubbleAutoTranslate = true;

  final List<Map<String, String>> _voices = [
    {'id': 'voice_1_female', 'name': 'سلمى'},
    {'id': 'voice_2_male', 'name': 'سيف'},
    {'id': 'voice_3_female_warm', 'name': 'سما'},
    {'id': 'voice_4_male_deep', 'name': 'ساره'},
    {'id': 'voice_5_premium_ai', 'name': 'صوت المستخدم (نسخ)'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
      _soundEnabled = _prefs.getBool('soundEnabled') ?? true;
      _isPremium = _prefs.getBool('isPremium') ?? false;
      _selectedVoice = _prefs.getString('selectedVoice') ?? 'voice_1_female';
      _bubbleEnabled = _prefs.getBool('bubble_enabled') ?? false;
      _bubbleOpacity = _prefs.getDouble('bubble_opacity') ?? 0.8;
      _bubbleSize = _prefs.getInt('bubble_size') ?? 120;
      _bubbleAutoTranslate = _prefs.getBool('bubble_auto_translate') ?? true;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)]
          )
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Display Settings
            _buildSectionTitle('عرض التطبيق'),
              _buildSettingTile(
                'الوضع المظلم',
                'استخدم الوضع المظلم لحماية العينين',
                Provider.of<ThemeProvider>(context).isDarkMode,
                (value) {
                  Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
                },
              ),
            const SizedBox(height: 20),

            // Notification Settings
            _buildSectionTitle('الإشعارات'),
            _buildSettingTile(
              'تفعيل الإشعارات',
              'استقبل إشعارات يومية مع الرسائل الملهمة',
              _notificationsEnabled,
              (value) {
                setState(() => _notificationsEnabled = value);
                _saveSetting('notificationsEnabled', value);
              },
            ),
            _buildSettingTile(
              'الأصوات',
              'تشغيل أصوات الإشعارات والتنبيهات',
              _soundEnabled,
              (value) {
                setState(() => _soundEnabled = value);
                _saveSetting('soundEnabled', value);
              },
            ),
            const SizedBox(height: 20),

            // Voice Selection
            _buildSectionTitle('اختيار الصوت (4 أصوات + نسخ الصوت)'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedVoice,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1B2838),
                  icon: const Icon(Icons.record_voice_over, color: Colors.blue),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  items: _voices.map((voice) {
                    bool isPremiumVoice = voice['id'] == 'voice_5_premium_ai';
                    return DropdownMenuItem(
                      value: voice['id'],
                      child: Row(
                        children: [
                          Text(voice['name']!),
                          if (isPremiumVoice) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                          ]
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      if (value == 'voice_5_premium_ai' && !_isPremium) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('نسخ الصوت متاح فقط في النسخة البرو')),
                        );
                        return;
                      }
                      setState(() => _selectedVoice = value);
                      _saveSetting('selectedVoice', value);
                      // Update TTS Service
                      Provider.of<TTSService>(context, listen: false).setVoice(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Floating Bubble Settings
            _buildSectionTitle('🫧 الفقاعة العائمة (مفتاح فتح وغلق)'),
            _buildSettingTile(
              'تفعيل الفقاعة العائمة',
              'ترجمة فورية مع فقاعة عائمة فوق التطبيقات',
              _bubbleEnabled,
              (value) async {
                setState(() => _bubbleEnabled = value);
                _saveSetting('bubble_enabled', value);
                // Toggle Bubble Service
                await Provider.of<FloatingBubbleService>(context, listen: false).toggleBubble(context, value);
              },
            ),
            if (_bubbleEnabled) ...[
              const SizedBox(height: 12),
              _buildSliderTile('الشفافية', _bubbleOpacity, 0.3, 1.0, (value) {
                setState(() => _bubbleOpacity = value);
                _saveSetting('bubble_opacity', value);
                Provider.of<FloatingBubbleService>(context, listen: false).setOpacity(value);
              }),
              const SizedBox(height: 12),
              _buildSliderTile('الحجم', _bubbleSize.toDouble(), 60, 200, (value) {
                setState(() => _bubbleSize = value.toInt());
                _saveSetting('bubble_size', value.toInt());
                Provider.of<FloatingBubbleService>(context, listen: false).setSize(value.toInt());
              }),
              const SizedBox(height: 12),
              _buildSettingTile(
                'الترجمة التلقائية',
                'ترجم النصوص تلقائياً عند النسخ',
                _bubbleAutoTranslate,
                (value) {
                  setState(() => _bubbleAutoTranslate = value);
                  _saveSetting('bubble_auto_translate', value);
                  Provider.of<FloatingBubbleService>(context, listen: false).toggleAutoTranslate(value);
                },
              ),
            ],
            const SizedBox(height: 20),

            // Premium Section
            if (!_isPremium)
              _buildPremiumCard()
            else
              _buildPremiumActiveCard(),
            const SizedBox(height: 20),

            // About Section
            _buildSectionTitle('عن التطبيق'),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutAppScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'عن التطبيق والإهداء',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'نبذة عن التطبيق وكلمة إهداء',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.blue.shade300, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'ميرور سكربيون',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'حيث تُصنع البدايات',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.amber.shade300,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? Colors.blue.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? Colors.blue.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(String title, double value, double min, double max, Function(double) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                value.toStringAsFixed(2),
                style: TextStyle(color: Colors.blue.shade300, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: Colors.blue,
            inactiveColor: Colors.white.withOpacity(0.2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade600.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber.shade300, size: 24),
              const SizedBox(width: 12),
              const Text(
                'ترقية إلى النسخة البرو',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'احصل على ميزات إضافية:\n• ترجمة مستندات غير محدودة\n• نسخ الصوت المتقدم (الصوت الخامس)\n• إزالة الإعلانات\n• ترجمة التطبيقات (الفقاعة العائمة)',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, height: 1.6),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('سيتم توجيهك لصفحة الترقية قريباً')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'ترقية الآن',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActiveCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700.withOpacity(0.2), Colors.teal.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade600.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified, color: Colors.green.shade300, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'النسخة البرو مفعلة',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'شكراً لدعمك للتطبيق!',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
