import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final List<String> languages;
  final ValueChanged<String> onChanged;
  final IconData? icon;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.languages,
    required this.onChanged,
    this.icon,
  });

  String _getLanguageName(String code) {
    final names = {
      'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
      'de': 'Deutsch', 'it': 'Italiano', 'pt': 'Português', 'ru': 'Русский',
      'zh': '中文', 'ja': '日本語', 'ko': '한국어', 'tr': 'Türkçe',
      'ur': 'اردو', 'fa': 'فارسی', 'hi': 'हिन्दी', 'bn': 'বাংলা',
      'id': 'Bahasa Indonesia', 'ms': 'Bahasa Melayu',
    };
    return names[code] ?? code;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLanguage,
          icon: Icon(icon ?? Icons.language, size: 20),
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          items: languages.map((code) {
            return DropdownMenuItem(
              value: code,
              child: Text(_getLanguageName(code), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class SpeakerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;

  const SpeakerButton({super.key, required this.onPressed, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.volume_up),
      iconSize: size * 0.6,
      color: Theme.of(context).colorScheme.primary,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        minimumSize: Size(size, size),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class MicButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isListening;
  final double size;

  const MicButton({super.key, required this.onPressed, this.isListening = false, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isListening
              ? Colors.red.withOpacity(0.2)
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: isListening ? Colors.red : Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        child: Icon(
          isListening ? Icons.mic : Icons.mic_none,
          color: isListening ? Colors.red : Theme.of(context).colorScheme.primary,
          size: size * 0.5,
        ),
      ),
    );
  }
}

class CopyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CopyButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy),
      iconSize: 20,
      color: Theme.of(context).colorScheme.primary,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        minimumSize: const Size(40, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class ShareButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ShareButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share),
      iconSize: 20,
      color: Theme.of(context).colorScheme.primary,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        minimumSize: const Size(40, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class WatermarkText extends StatelessWidget {
  final String text;

  const WatermarkText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 130 * 3.14159 / 180,
      child: Opacity(
        opacity: 0.3,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
