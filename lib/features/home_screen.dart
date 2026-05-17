import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/shared_widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header Section ──
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Animated scorpion + mirror logo
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: CustomPaint(
                            size: const Size(100, 100),
                            painter: _ScorpionMirrorPainter(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Mirror Scription',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ترجمة بنّاءة • بناءً مستمر',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    const WatermarkText(),
                  ],
                ),
              ),
            ),

            // ── 6 Cards Grid ──
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildListDelegate([
                  _buildCard(
                    icon: Icons.translate,
                    title: 'ترجمة نصوص',
                    subtitle: 'ترجمة فورية بين 100 لغة',
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => Navigator.pushNamed(context, '/translate'),
                  ),
                  _buildCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'حوار مترجم',
                    subtitle: 'محادثة ثنائية مع ترجمة فورية',
                    color: Theme.of(context).colorScheme.tertiary,
                    onTap: () => Navigator.pushNamed(context, '/dialogue'),
                  ),
                  _buildCard(
                    icon: Icons.document_scanner,
                    title: 'مستندات وكاميرا',
                    subtitle: 'OCR + ترجمة من الصور والمستندات',
                    color: Colors.teal,
                    onTap: () => Navigator.pushNamed(context, '/document'),
                  ),
                  _buildCard(
                    icon: Icons.auto_stories,
                    title: 'أحاديث وقصص',
                    subtitle: 'مكتبة إسلامية مع ترجمة ذكية',
                    color: Colors.deepOrange,
                    onTap: () => Navigator.pushNamed(context, '/stories'),
                  ),
                  _buildCard(
                    icon: Icons.sports_esports,
                    title: 'ألعاب',
                    subtitle: 'شطرنج ثلاثي الأبعاد + مكعب روبيك',
                    color: Colors.purple,
                    onTap: () {},
                  ),
                  _buildCard(
                    icon: Icons.settings,
                    title: 'الإعدادات',
                    subtitle: 'تحكم كامل بالتطبيق',
                    color: Colors.blueGrey,
                    onTap: () {},
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
            ),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Custom Painter: Scorpion + Mirror ──
class _ScorpionMirrorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A237E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // Mirror frame (circle)
    canvas.drawCircle(center, radius, paint);

    // Mirror handle
    final handlePaint = Paint()
      ..color = const Color(0xFF1A237E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(center.dx, center.dy + radius),
      Offset(center.dx, center.dy + radius + 20),
      handlePaint,
    );

    // Scorpion silhouette inside mirror
    final scorpionPaint = Paint()
      ..color = const Color(0xFF1A237E).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Body (oval)
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 22, height: 14),
      scorpionPaint,
    );

    // Tail (curved line)
    final tailPaint = Paint()
      ..color = const Color(0xFF1A237E).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final tailPath = Path()
      ..moveTo(center.dx + 11, center.dy)
      ..quadraticBezierTo(center.dx + 18, center.dy - 12, center.dx + 8, center.dy - 18)
      ..quadraticBezierTo(center.dx + 2, center.dy - 22, center.dx - 2, center.dy - 16);
    canvas.drawPath(tailPath, tailPaint);

    // Stinger dot
    canvas.drawCircle(Offset(center.dx - 2, center.dy - 16), 2.5, scorpionPaint);

    // Claws
    final clawPath = Path()
      ..moveTo(center.dx - 11, center.dy - 2)
      ..quadraticBezierTo(center.dx - 18, center.dy - 8, center.dx - 22, center.dy - 4)
      ..moveTo(center.dx - 11, center.dy + 2)
      ..quadraticBezierTo(center.dx - 18, center.dy + 8, center.dx - 22, center.dy + 4);
    canvas.drawPath(clawPath, tailPaint);

    // Legs
    for (int i = 0; i < 4; i++) {
      final yOffset = -4 + (i * 3);
      canvas.drawLine(
        Offset(center.dx - 8, center.dy + yOffset),
        Offset(center.dx - 16, center.dy + yOffset + 4),
        tailPaint,
      );
      canvas.drawLine(
        Offset(center.dx + 8, center.dy + yOffset),
        Offset(center.dx + 16, center.dy + yOffset + 4),
        tailPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
