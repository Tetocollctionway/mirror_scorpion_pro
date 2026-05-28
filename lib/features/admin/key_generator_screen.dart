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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مولد أكواد التفعيل (خاص بالمطور)', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF0D1B2A),
        child: Column(
          children: [
            const Text(
              'أدخل معرف الجهاز المشفر للمستخدم لتوليد كود تفعيل خاص به:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _deviceIdController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Device ID...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_deviceIdController.text.isNotEmpty) {
                  setState(() {
                    _generatedCode = PremiumVerificationService().generateActivationCode(_deviceIdController.text.trim());
                  });
                }
              },
              child: const Text('توليد الكود'),
            ),
            if (_generatedCode.isNotEmpty) ...[
              const SizedBox(height: 30),
              const Text('كود التفعيل الناتج:', style: TextStyle(color: Colors.amber)),
              const SizedBox(height: 10),
              SelectableText(
                _generatedCode,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.amber),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _generatedCode));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ كود التفعيل')));
                },
              )
            ]
          ],
        ),
      ),
    );
  }
}
