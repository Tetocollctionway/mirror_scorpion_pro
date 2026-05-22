import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool _darkMode = true;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String _selectedVoice = 'voice_1_female';
  bool _isPremium = false;

  final List<Map<String, String>> _voices = [
    {'id': 'voice_1_female', 'name': 'Female Voice 1', 'description': 'Clear and natural'},
    {'id': 'voice_2_male', 'name': 'Male Voice 1', 'description': 'Deep and calm'},
    {'id': 'voice_3_female', 'name': 'Female Voice 2', 'description': 'Soft and gentle'},
    {'id': 'voice_4_male', 'name': 'Male Voice 2', 'description': 'Professional'},
    {'id': 'voice_5_premium_ai', 'name': 'Premium AI Voice', 'description': 'Advanced AI synthesis', 'premium': 'true'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = _prefs.getBool('darkMode') ?? true;
      _notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
      _soundEnabled = _prefs.getBool('soundEnabled') ?? true;
      _selectedVoice = _prefs.getString('selectedVoice') ?? 'voice_1_female';
      _isPremium = _prefs.getBool('isPremium') ?? false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Display Settings
            _buildSectionTitle('Display'),
            _buildSettingsTile(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Use dark theme',
              trailing: Switch(
                value: _darkMode,
                onChanged: (value) {
                  setState(() => _darkMode = value);
                  _saveSetting('darkMode', value);
                },
              ),
            ),
            const SizedBox(height: 20),

            // Audio Settings
            _buildSectionTitle('Audio & Voice'),
            _buildSettingsTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Enable app notifications',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  _saveSetting('notificationsEnabled', value);
                },
              ),
            ),
            _buildSettingsTile(
              icon: Icons.volume_up,
              title: 'Sound Effects',
              subtitle: 'Enable sound effects',
              trailing: Switch(
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() => _soundEnabled = value);
                  _saveSetting('soundEnabled', value);
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildSectionTitle('Select Voice'),
            ..._voices.map((voice) {
              final isPremium = voice['premium'] == 'true';
              return _buildVoiceTile(
                voice['id']!,
                voice['name']!,
                voice['description']!,
                isPremium,
              );
            }).toList(),
            const SizedBox(height: 20),

            // Premium Section
            _buildSectionTitle('Premium'),
            if (!_isPremium)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upgrade to Premium',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock unlimited translations, premium voices, and advanced features',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Premium upgrade coming soon!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Upgrade Now'),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Premium Member',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          Text(
                            'Thank you for supporting Mirror Scorpion!',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // About Section
            _buildSectionTitle('About'),
            _buildSettingsTile(
              icon: Icons.info,
              title: 'Version',
              subtitle: 'Mirror Scorpion v1.0.0',
            ),
            _buildSettingsTile(
              icon: Icons.person,
              title: 'Developer',
              subtitle: 'TetoCollectionWay',
            ),
            _buildSettingsTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English / العربية',
            ),
            const SizedBox(height: 20),

            // Footer
            Center(
              child: Text(
                'Mirror Scription - Where Beginnings Are Made',
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.amber.shade300,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber.shade300),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        trailing: trailing,
      ),
    );
  }

  Widget _buildVoiceTile(String voiceId, String voiceName, String description, bool isPremium) {
    final isSelected = _selectedVoice == voiceId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.15) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue.withOpacity(0.5) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        onTap: isPremium && !_isPremium
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This voice is available in Premium version')),
                );
              }
            : () {
                setState(() => _selectedVoice = voiceId);
                _saveSetting('selectedVoice', voiceId);
              },
        leading: Radio<String>(
          value: voiceId,
          groupValue: _selectedVoice,
          onChanged: isPremium && !_isPremium
              ? null
              : (value) {
                  if (value != null) {
                    setState(() => _selectedVoice = value);
                    _saveSetting('selectedVoice', value);
                  }
                },
        ),
        title: Row(
          children: [
            Text(voiceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            if (isPremium)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.star, size: 14, color: Colors.amber),
              ),
          ],
        ),
        subtitle: Text(description, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
      ),
    );
  }
}
