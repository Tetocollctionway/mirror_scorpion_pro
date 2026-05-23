import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  late AnimationController _scanController;
  bool _isLensMode = true;
  String _selectedLanguage = 'العربية';
  int _selectedOptionIndex = 0; // 0: Translate, 1: Text, 2: Search...

  final List<String> _options = ['ترجمة', 'نص', 'بحث', 'واجبات', 'تسوق'];
  final List<String> _languages = ['العربية', 'English', 'Français', 'Español', 'Deutsch'];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _cameraController = CameraController(cameras[0], ResolutionPreset.high);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Full Screen Camera (Google Lens Style)
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Positioned.fill(child: CameraPreview(_cameraController!))
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // 2. Scanning Animation Line
          AnimatedBuilder(
            animation: _scanController,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height * 0.2 + (MediaQuery.of(context).size.height * 0.5 * _scanController.value),
                left: 40,
                right: 40,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: Colors.blue.withOpacity(0.8), blurRadius: 10, spreadRadius: 2),
                    ],
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.blue.withOpacity(0.8), Colors.transparent],
                    ),
                  ),
                ),
              );
            },
          ),

          // 3. Smart Detection Dots (Simulated)
          ..._buildSmartDots(),

          // 4. Top Controls (Language Selector)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(_selectedLanguage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.flash_on, color: Colors.white), onPressed: () {}),
              ],
            ),
          ),

          // 5. Bottom Options (Google Lens Style)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
              child: Column(
                children: [
                  // Capture Button
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Options Scroller
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _options.asMap().entries.map((entry) {
                        int idx = entry.key;
                        String val = entry.value;
                        bool isSelected = _selectedOptionIndex == idx;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedOptionIndex = idx),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              val,
                              style: TextStyle(
                                color: isSelected ? Colors.blueAccent : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. Transparent Signature (130 degrees)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Transform.rotate(
                  angle: 130 * 3.14 / 180,
                  child: Text(
                    'Mirror Scorpion',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.03),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSmartDots() {
    return [
      _positionDot(0.3, 0.4),
      _positionDot(0.5, 0.6),
      _positionDot(0.4, 0.3),
      _positionDot(0.6, 0.5),
    ];
  }

  Widget _positionDot(double topFactor, double leftFactor) {
    return Positioned(
      top: MediaQuery.of(context).size.height * topFactor,
      left: MediaQuery.of(context).size.width * leftFactor,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
      ),
    );
  }
}
