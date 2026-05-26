# 🦂 Mirror Scorpion - ميرور سكربيون

> **حيث تُصنع البدايات** | Where Beginnings Are Made

A comprehensive Flutter application for translation, inspiration, and spiritual guidance with advanced AI capabilities.

---

## 📱 Features Overview

### 🔤 Card 1: Text Translation (ترجمة نصوص)
- **Real-time translation** between 100+ languages
- **Speech-to-text** microphone input
- **Text-to-speech** audio output
- **Share & Copy** functionality
- **Language swap** with one tap
- Powered by Google Translate API

### 💬 Card 2: Dialogue Translation (حوار مترجم)
- **Live conversation** translation
- **Bidirectional** communication
- **Microphone support** for hands-free input
- **Speaker output** for translated messages
- **Chat history** with language indicators
- Real-time message bubbles

### 📄 Card 3: Document Translation (ترجمة مستندات)
- **OCR (Optical Character Recognition)** from images
- **Image picker** from gallery
- **Text extraction** from photos
- **Document translation** with formatting
- **Copy & Share** translated documents
- Support for multiple document formats

### 📖 Card 4: Hadith, Stories & Inspiration (أحاديث وقصص والإلهام)
- **Islamic Hadith** collection with translations
- **Quranic Stories** (Prophets, Women, Animals, Humans, Nations)
- **AI-powered Inspiration** based on user mood
- **Daily Wisdom** notifications
- **Quote saving** and management
- **Text-to-speech** for all content

### 🎮 Card 5: Games (ألعاب)
- **3D Rubik's Cube** with full solving capabilities
- **Chess 3D** (coming soon)
- **Interactive gameplay** with drag controls
- **Realistic physics** and animations

### ⚙️ Card 6: Settings (الإعدادات)
- **Dark Mode** toggle
- **Voice Selection** (5 different voices including AI)
- **Notifications** control
- **Sound Effects** toggle
- **Premium Upgrade** option
- **App Information** and version details

---

## 🛠️ Technical Stack

### Frontend
- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Provider
- **UI Components**: Material Design 3

### Backend Services
- **Translation API**: Google Translate
- **Speech Recognition**: Google ML Kit
- **Text-to-Speech**: Flutter TTS
- **Image Processing**: Google ML Kit Text Recognition
- **AI Services**: Custom AI Service (OpenAI compatible)

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  http: ^1.2.1
  flutter_tts: ^4.0.2
  speech_to_text: ^7.0.0
  google_mlkit_text_recognition: ^0.13.0
  image_picker: ^1.0.0
  shared_preferences: ^2.2.0
  intl: ^0.19.0
```

---

## 📦 Installation

### Prerequisites
- Flutter SDK (3.0 or higher)
- Android SDK / iOS SDK
- Git

### Clone Repository
```bash
git clone https://github.com/dosoky2580/mirror_scorpion_translate1.git
cd mirror_scorpion_translate1
```

### Install Dependencies
```bash
flutter pub get
```

### Run Application
```bash
flutter run
```

### Build APK
```bash
flutter build apk --release
```

### Build iOS
```bash
flutter build ios --release
```

---

## 🚀 Quick Start

### 1. Text Translation
1. Open the app
2. Tap on "ترجمة نصوص" (Text Translation)
3. Select source and target languages
4. Enter text or use microphone
5. Tap "Translate"
6. Use speaker to hear translation

### 2. Dialogue Translation
1. Tap on "حوار مترجم" (Dialogue Translation)
2. Select source and target languages
3. Use microphone or type messages
4. Messages appear in chat format
5. Tap speaker icon to hear translations

### 3. Document Translation
1. Tap on "ترجمة مستندات" (Document Translation)
2. Pick image from gallery or paste text
3. OCR will extract text automatically
4. Select languages and tap "Translate"
5. View and share translated document

### 4. Hadith & Stories
1. Tap on "أحاديث وقصص" (Hadith & Stories)
2. Browse through three tabs:
   - **Hadith**: Islamic sayings
   - **Stories**: Quranic and Islamic stories
   - **Inspiration**: AI-powered motivation
3. Use speaker to hear content
4. Save favorite quotes

### 5. Games
1. Tap on "ألعاب" (Games)
2. Select Rubik's Cube
3. Drag to rotate the cube
4. Use controls to scramble/solve

### 6. Settings
1. Tap on "الإعدادات" (Settings)
2. Toggle dark mode, notifications, sound
3. Select preferred voice
4. View app information

---

## 📁 Project Structure

```
mirror_scorpion_translate1/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart            # Theme configuration
│   │   ├── constants/
│   │   │   └── app_constants.dart        # App constants
│   │   └── widgets/
│   │       └── shared_widgets.dart       # Shared UI components
│   ├── features/
│   │   ├── card1_translation/
│   │   │   └── translation_screen.dart   # Text translation
│   │   ├── card2_dialogue/
│   │   │   └── dialogue_screen.dart      # Dialogue translation
│   │   ├── card3_document/
│   │   │   └── document_screen.dart      # Document translation
│   │   ├── hadith_stories/
│   │   │   ├── hadith_stories_screen.dart
│   │   │   ├── models/
│   │   │   ├── services/
│   │   │   └── data/
│   │   ├── games/
│   │   │   └── rubik_cube/
│   │   │       └── rubik_cube_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart      # Settings & preferences
│   ├── services/
│   │   ├── ai_service.dart               # AI & inspiration
│   │   ├── database_service.dart         # Data management
│   │   ├── tts_service.dart              # Text-to-speech
│   │   └── overlay_service.dart          # Floating overlay
│   └── assets/
│       └── data/
│           ├── hadiths.json
│           ├── quran_stories.json
│           └── stories.json
├── pubspec.yaml                          # Dependencies
├── README.md                             # This file
├── TERMUX_SETUP.md                       # Termux guide
└── .gitignore
```

---

## 🔐 API Keys & Configuration

### Google Translate API
- **Endpoint**: `https://translate.googleapis.com/translate_a/single`
- **Method**: GET
- **No API key required** (uses free tier)

### OpenAI API (Optional - for Premium)
```dart
// In ai_service.dart
static const String _apiEndpoint = 'https://api.openai.com/v1/chat/completions';
```

### Environment Variables
Create `.env` file:
```
OPENAI_API_KEY=your_api_key_here
GOOGLE_TRANSLATE_API_KEY=optional
```

---

## 🎨 UI/UX Features

- **Dark Mode**: Optimized for night usage
- **Gradient Backgrounds**: Modern aesthetic
- **Smooth Animations**: Pulse effects and transitions
- **RTL Support**: Full Arabic/Urdu support
- **Responsive Design**: Adapts to all screen sizes
- **Custom Widgets**: Reusable components
- **Material Design 3**: Latest design standards

---

## 🔄 Git Workflow

### Using Termux
See [TERMUX_SETUP.md](TERMUX_SETUP.md) for detailed instructions.

### Basic Commands
```bash
# Clone repository
git clone https://github.com/dosoky2580/mirror_scorpion_translate1.git

# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "✨ Add new feature"

# Push to GitHub
git push -u origin feature/new-feature

# Create Pull Request on GitHub
```

---

## 🐛 Troubleshooting

### Issue: Translation API not responding
**Solution**: Check internet connection and try again

### Issue: Microphone not working
**Solution**: Grant microphone permission in app settings

### Issue: OCR not extracting text
**Solution**: Ensure image is clear and well-lit

### Issue: App crashes on startup
**Solution**: Run `flutter clean` and `flutter pub get`

### Issue: Build fails
**Solution**: 
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

---

## 📊 Performance Metrics

- **App Size**: ~150MB (APK)
- **Minimum SDK**: Android 21 (API 21)
- **Target SDK**: Android 34 (API 34)
- **Memory Usage**: ~200MB average
- **Translation Speed**: <2 seconds per request
- **OCR Speed**: <3 seconds per image

---

## 🔐 Security & Privacy

- **No data collection**: App doesn't store personal data
- **Encrypted communication**: HTTPS for all API calls
- **Local processing**: Images processed locally, not uploaded
- **Privacy-first**: No tracking or analytics
- **Open source**: Code available for review

---

## 📈 Future Enhancements

- [ ] Chess 3D game implementation
- [ ] Video translation support
- [ ] Offline translation mode
- [ ] Custom dictionary
- [ ] Translation history sync
- [ ] Cloud backup
- [ ] Multi-user support
- [ ] Real-time collaboration

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m '✨ Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 Commit Message Guidelines

- `✨ feat:` New feature
- `🐛 fix:` Bug fix
- `📚 docs:` Documentation
- `🎨 style:` Code style
- `♻️ refactor:` Code refactoring
- `⚡ perf:` Performance improvement
- `✅ test:` Tests
- `🔄 chore:` Maintenance

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍💻 Author

**TetoCollectionWay**
- GitHub: [@dosoky2580](https://github.com/dosoky2580)
- Email: dev@mirror-scorpion.app

---

## 🙏 Acknowledgments

- Google Translate API
- Google ML Kit
- Flutter Community
- All contributors and supporters

---

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check existing documentation
- Review troubleshooting guide

---

## 🌟 Star Us!

If you find this project helpful, please give it a star ⭐ on GitHub!

---

**Mirror Scorpion** - حيث تُصنع البدايات

*Last Updated: 2024*
*Version: 1.0.0*
