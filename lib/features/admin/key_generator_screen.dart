import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/premium_verification_service.dart';

class KeyGeneratorScreen extends StatefulWidget {
  const KeyGeneratorScreen({super.key});

  @override
  State<KeyGeneratorScreen> createState() => _KeyGeneratorScreenState();
}

class _KeyGeneratorScreenState extends State<KeyGeneratorScreen> {
  final TextEditingController _deviceIdController = TextEditingController();
  String _generatedCode = '';
  int _selectedDuration = 30; // Default 1 month

  final List<Map<String, dynamic>> _durations = [
    {'name': 'شهر واحد', 'days': 30},
    {'name': '3 شهور', 'days': 90},
    {'name': 'سنة كاملة', 'days': 365},
    {'name': 'مدى الحياة', 'days': 36500},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مولد أكواد التفعيل (PRO)', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF0D1B2A),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '1. أدخل معرف الجهاز المشفر للمستخدم:',
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _deviceIdController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'ألصق الـ ID هنا...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                '2. اختر مدة التفعيل:',
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedDuration,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1B2838),
                    style: const TextStyle(color: Colors.white),
                    items: _durations.map((d) {
                      return DropdownMenuItem<int>(
                        value: d['days'],
                        child: Text(d['name']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDuration = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_deviceIdController.text.isNotEmpty) {
                      setState(() {
                        _generatedCode = PremiumVerificationService().generateActivationCode(
                          _deviceIdController.text.trim(),
                          _selectedDuration,
                        );
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('إنشاء كود التفعيل المطور', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              if (_generatedCode.isNotEmpty) ...[
                const SizedBox(height: 40),
                const Center(child: Text('كود التفعيل جاهز للإرسال:', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      SelectableText(
                        _generatedCode,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 10),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.amber),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _generatedCode));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الكود بنجاح')));
                        },
                      )
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
