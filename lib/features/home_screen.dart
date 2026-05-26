import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/shared_widgets.dart';
import '../services/floating_bubble_service.dart';
import '../services/ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleBubble() async {
    final service = Provider.of<FloatingBubbleService>(context, listen: false);
    if (service.isStarted) {
      await service.stopBubble();
    } else {
      await service.startBubble(context);
    }
  }

  void _showAIInspiration() async {
    final inspiration = await AIService.generateInspiration(
      userMood: '', 
      context: 'Home Screen visit',
    );
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/scorpion_icon.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('ذكاء مانوس (Manus Intelligence) ✨', style: TextStyle(color: Colors.amber, fontSize: 16)),
          ],
        ),
        backgroundColor: const Color(0xFF1B2838),
        content: Text(inspiration, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('شكراً', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bubbleService = Provider.of<FloatingBubbleService>(context);
    final isBubbleActive = bubbleService.isStarted;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── Header Section ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    children: [
                      // Scorpion in Mirror reflection effect (Center Top)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Mirror reflection effect
                          Opacity(
                            opacity: 0.2,
                            child: Transform.translate(
                              offset: const Offset(0, 40),
                              child: Transform(
                                transform: Matrix4.identity()..scale(1.0, -0.6),
                                alignment: Alignment.center,
                                child: _buildScorpionLogo(),
                              ),
                            ),
                          ),
                          _buildScorpionLogo(),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'ميرور سكربيون',
                        style: TextStyle(
                          fontSize: 36, 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 2,
                          color: Color(0xFF00B0FF),
                          shadows: [
                            Shadow(color: Colors.blueAccent, blurRadius: 10),
                            Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'حيث تُصنع البدايات',
                        style: TextStyle(fontSize: 16, color: Colors.white54, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 25),
                      
                      // Floating Bubble Toggle Switch
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: isBubbleActive ? Colors.blueAccent : Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isBubbleActive ? Icons.bubble_chart : Icons.bubble_chart_outlined,
                              color: isBubbleActive ? Colors.blueAccent : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isBubbleActive ? 'الفقاعة نشطة' : 'تفعيل الفقاعة العائمة',
                              style: TextStyle(
                                color: isBubbleActive ? Colors.blueAccent : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: isBubbleActive,
                              onChanged: (_) => _toggleBubble(),
                              activeColor: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 6 Cards Grid ──
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildCard(
                      icon: Icons.translate,
                      title: 'ترجمة نصية',
                      subtitle: '100 لغة + مايك',
                      color: Colors.blueAccent,
                      onTap: () => Navigator.pushNamed(context, '/translate'),
                    ),
                    _buildCard(
                      icon: Icons.forum,
                      title: 'حوار مترجم',
                      subtitle: 'محادثة ثنائية فورية',
                      color: Colors.cyanAccent,
                      onTap: () => Navigator.pushNamed(context, '/dialogue'),
                    ),
                    _buildCard(
                      icon: Icons.document_scanner,
                      title: 'مستندات وعدسة',
                      subtitle: 'ترجمة صور وملفات',
                      color: Colors.tealAccent,
                      onTap: () => Navigator.pushNamed(context, '/document'),
                    ),
                    _buildCard(
                      icon: Icons.auto_stories,
                      title: 'قصص وإلهام',
                      subtitle: 'مكتبة ذكية متكاملة',
                      color: Colors.orangeAccent,
                      onTap: () => Navigator.pushNamed(context, '/stories'),
                    ),
                    _buildCard(
                      icon: Icons.sports_esports,
                      title: 'ألعاب 3D',
                      subtitle: 'شطرنج + روبيك',
                      color: Colors.purpleAccent,
                      onTap: () => _showGamesSelection(context),
                    ),
                    _buildCard(
                      icon: Icons.settings,
                      title: 'الإعدادات',
                      subtitle: 'تخصيص وترقية برو',
                      color: Colors.blueGrey,
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ]),
                ),
              ),
              
              // Footer
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Center(
                    child: Opacity(
                      opacity: 0.3,
                      child: Column(
                        children: [
                          const WatermarkText(text: "Mirror Scorpion"),
                          const SizedBox(height: 5),
                          Text("v1.0.0 Build Successful", style: TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showGamesSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2838),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اختر اللعبة', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.grid_view, color: Colors.purpleAccent, size: 32),
              title: const Text('مكعب روبيك 3D', style: TextStyle(color: Colors.white)),
              subtitle: const Text('جميع طرق الحل', style: TextStyle(color: Colors.white54)),
              onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/rubik'); },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.castle, color: Colors.purpleAccent, size: 32),
              title: const Text('شطرنج 3D', style: TextStyle(color: Colors.white)),
              subtitle: const Text('لعبة شطرنج ثلاثية الأبعاد', style: TextStyle(color: Colors.white54)),
              onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/chess'); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScorpionLogo() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
              image: const DecorationImage(
                image: AssetImage('assets/images/scorpion_icon.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.1), Colors.transparent],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
