import 'dart:math';
import 'package:flutter/material.dart';

class _Cubelet {
  final int x, y, z;
  final Color top, bottom, left, right, front, back;

  _Cubelet({
    required this.x,
    required this.y,
    required this.z,
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
    required this.front,
    required this.back,
  });
}

enum _Face { up, down, left, right, front, back }

class RubikCubeScreen extends StatefulWidget {
  const RubikCubeScreen({super.key});

  @override
  State<RubikCubeScreen> createState() => _RubikCubeScreenState();
}

class _RubikCubeScreenState extends State<RubikCubeScreen>
    with TickerProviderStateMixin {
  List<_Cubelet> _cubelets = [];
  double _rotX = -0.5;
  double _rotY = 0.5;
  Offset? _lastDragPos;
  _Face? _selectedFace;

  @override
  void initState() {
    super.initState();
    _initCube();
  }

  void _initCube() {
    final cubes = <_Cubelet>[];
    final Color nc = Colors.transparent;

    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        for (int z = -1; z <= 1; z++) {
          if (x == 0 && y == 0 && z == 0) continue;
          cubes.add(_Cubelet(
            x: x, y: y, z: z,
            top: y == 1 ? Colors.white : nc,
            bottom: y == -1 ? Colors.yellow : nc,
            left: x == -1 ? Colors.green : nc,
            right: x == 1 ? Colors.blue : nc,
            front: z == 1 ? Colors.red : nc,
            back: z == -1 ? Colors.orange : nc,
          ));
        }
      }
    }
    _cubelets = cubes;
  }

  void _rotateFace(_Face face, bool clockwise) {
    if (_cubelets.isEmpty) return;
    setState(() => _selectedFace = face);

    int layer;
    int axis;
    switch (face) {
      case _Face.right:  axis = 0; layer = 1; break;
      case _Face.left:   axis = 0; layer = -1; break;
      case _Face.up:     axis = 1; layer = 1; break;
      case _Face.down:   axis = 1; layer = -1; break;
      case _Face.front:  axis = 2; layer = 1; break;
      case _Face.back:   axis = 2; layer = -1; break;
    }

    _applyRotation(axis, layer, clockwise);
    setState(() => _selectedFace = null);
  }

  void _applyRotation(int axis, int layer, bool clockwise) {
    final faceCubes = <int>[];
    for (int i = 0; i < _cubelets.length; i++) {
      final c = _cubelets[i];
      final coord = axis == 0 ? c.x : (axis == 1 ? c.y : c.z);
      if (coord == layer) faceCubes.add(i);
    }

    if (faceCubes.isEmpty) return;

    final angle = clockwise ? -pi / 2 : pi / 2;
    final newCubelets = List<_Cubelet>.from(_cubelets);

    for (final i in faceCubes) {
      final c = _cubelets[i];
      int nx = c.x, ny = c.y, nz = c.z;

      if (axis == 0) {
        ny = (c.y * cos(angle) - c.z * sin(angle)).round();
        nz = (c.y * sin(angle) + c.z * cos(angle)).round();
      } else if (axis == 1) {
        nx = (c.x * cos(angle) + c.z * sin(angle)).round();
        nz = (-c.x * sin(angle) + c.z * cos(angle)).round();
      } else {
        nx = (c.x * cos(angle) - c.y * sin(angle)).round();
        ny = (c.x * sin(angle) + c.y * cos(angle)).round();
      }

      newCubelets[i] = _Cubelet(
        x: nx, y: ny, z: nz,
        top: c.top, bottom: c.bottom,
        left: c.left, right: c.right,
        front: c.front, back: c.back,
      );
    }

    _cubelets = newCubelets;
    _swapColorsForRotatedFace(axis, layer, clockwise);
  }

  void _swapColorsForRotatedFace(int axis, int layer, bool clockwise) {
    final faceIndices = <int>[];
    for (int i = 0; i < _cubelets.length; i++) {
      final c = _cubelets[i];
      final coord = axis == 0 ? c.x : (axis == 1 ? c.y : c.z);
      if (coord == layer) faceIndices.add(i);
    }

    final newCubelets = List<_Cubelet>.from(_cubelets);

    for (final i in faceIndices) {
      final c = _cubelets[i];
      Color nt = c.top, nb = c.bottom;
      Color nl = c.left, nr = c.right;
      Color nf = c.front, nbk = c.back;

      if (axis == 0) {
        if (clockwise) { nt = c.front; nf = c.bottom; nb = c.back; nbk = c.top; }
        else { nt = c.back; nbk = c.bottom; nb = c.front; nf = c.top; }
      } else if (axis == 1) {
        if (clockwise) { nf = c.right; nr = c.back; nbk = c.left; nl = c.front; }
        else { nf = c.left; nl = c.back; nbk = c.right; nr = c.front; }
      } else {
        if (clockwise) { nt = c.right; nr = c.bottom; nb = c.left; nl = c.top; }
        else { nt = c.left; nl = c.bottom; nb = c.right; nr = c.top; }
      }

      newCubelets[i] = _Cubelet(
        x: c.x, y: c.y, z: c.z,
        top: nt, bottom: nb, left: nl, right: nr, front: nf, back: nbk,
      );
    }

    _cubelets = newCubelets;
  }

  void _scramble() {
    final faces = _Face.values;
    final rng = Random();
    for (int i = 0; i < 20; i++) {
      final face = faces[rng.nextInt(faces.length)];
      final cw = rng.nextBool();
      _applyRotation(
        face == _Face.left || face == _Face.right ? 0 :
        face == _Face.up || face == _Face.down ? 1 : 2,
        face == _Face.right || face == _Face.up || face == _Face.front ? 1 : -1,
        cw,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مكعب روبيك 3D"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'بعثرة المكعب',
            onPressed: _scramble,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'إعادة الضبط',
            onPressed: () { setState(() { _initCube(); _rotX = -0.5; _rotY = 0.5; }); },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart: (d) => _lastDragPos = d.localPosition,
              onPanUpdate: (d) {
                if (_lastDragPos == null) return;
                setState(() {
                  _rotY += (d.localPosition.dx - _lastDragPos!.dx) * 0.01;
                  _rotX += (d.localPosition.dy - _lastDragPos!.dy) * 0.01;
                  _lastDragPos = d.localPosition;
                });
              },
              onPanEnd: (_) => _lastDragPos = null,
              child: CustomPaint(
                painter: _RubikPainter(
                  cubelets: _cubelets, rotX: _rotX, rotY: _rotY,
                  selectedFace: _selectedFace,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(top: BorderSide(color: Colors.grey[800]!)),
            ),
            child: Column(
              children: [
                const Text('اضغط على أزرار الوجوه لتدوير المكعب 90\u00b0',
                    style: TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
                  children: [
                    _faceBtn('U', Colors.white, () => _rotateFace(_Face.up, true)),
                    _faceBtn('D', Colors.yellow, () => _rotateFace(_Face.down, true)),
                    _faceBtn('R', Colors.blue, () => _rotateFace(_Face.right, true)),
                    _faceBtn('L', Colors.green, () => _rotateFace(_Face.left, true)),
                    _faceBtn('F', Colors.red, () => _rotateFace(_Face.front, true)),
                    _faceBtn('B', Colors.orange, () => _rotateFace(_Face.back, true)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _faceBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16))),
      ),
    );
  }
}

class _RubikPainter extends CustomPainter {
  final List<_Cubelet> cubelets;
  final double rotX, rotY;
  final _Face? selectedFace;

  _RubikPainter({required this.cubelets, required this.rotX, required this.rotY, this.selectedFace});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.shortestSide * 0.18;

    final matrix = _Matrix4.identity()
      ..setEntry(3, 2, 0.003)
      ..rotateX(rotX)
      ..rotateY(rotY);

    final polygons = <_Polygon>[];

    for (final c in cubelets) {
      final pos = _Vector4(c.x.toDouble(), c.y.toDouble(), c.z.toDouble(), 1);
      final t = matrix.transform(pos);
      final px = center.dx + (t.x / t.w) * scale;
      final py = center.dy + (t.y / t.w) * scale;
      final pz = t.z / t.w;
      final cs = scale * 0.4;
      final gap = cs * 0.08;

      final faces = [
        _facePoly(c.top, _Vector3(0,1,0), px, py, cs, gap, 'top'),
        _facePoly(c.bottom, _Vector3(0,-1,0), px, py, cs, gap, 'bottom'),
        _facePoly(c.left, _Vector3(-1,0,0), px, py, cs, gap, 'left'),
        _facePoly(c.right, _Vector3(1,0,0), px, py, cs, gap, 'right'),
        _facePoly(c.front, _Vector3(0,0,1), px, py, cs, gap, 'front'),
        _facePoly(c.back, _Vector3(0,0,-1), px, py, cs, gap, 'back'),
      ];

      for (final f in faces) {
        if (f.color == Colors.transparent) continue;
        final vn = _Vector3(0, 0, -1);
        final tn = matrix.transform3(f.normal);
        final dot = tn.x * vn.x + tn.y * vn.y + tn.z * vn.z;
        if (dot < 0) continue;
        polygons.add(_Polygon(z: pz, corners: f.corners, color: f.color));
      }
    }

    polygons.sort((a, b) => b.z.compareTo(a.z));

    for (final p in polygons) {
      final path = Path()..moveTo(p.corners[0].dx, p.corners[0].dy);
      for (int i = 1; i < p.corners.length; i++) {
        path.lineTo(p.corners[i].dx, p.corners[i].dy);
      }
      path.close();

      final brightness = (p.z + 3) / 6;
      final color = Color.fromRGBO(
        (p.color.red * brightness).round().clamp(0, 255),
        (p.color.green * brightness).round().clamp(0, 255),
        (p.color.blue * brightness).round().clamp(0, 255),
        1,
      );

      canvas.drawPath(path, Paint()..color = color);
      canvas.drawPath(path, Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0);
    }
  }

  _FacePoly _facePoly(Color c, _Vector3 n, double cx, double cy, double s, double g, String face) {
    final h = (s - g) / 2;
    List<Offset> corners;
    switch (face) {
      case 'top':    corners = [Offset(cx-h,cy-h), Offset(cx+h,cy-h), Offset(cx+h,cy-h+g), Offset(cx-h,cy-h+g)]; break;
      case 'bottom': corners = [Offset(cx-h,cy+h-g), Offset(cx+h,cy+h-g), Offset(cx+h,cy+h), Offset(cx-h,cy+h)]; break;
      case 'left':   corners = [Offset(cx-h,cy-h+g), Offset(cx-h+g,cy-h+g), Offset(cx-h+g,cy+h-g), Offset(cx-h,cy+h-g)]; break;
      case 'right':  corners = [Offset(cx+h-g,cy-h+g), Offset(cx+h,cy-h+g), Offset(cx+h,cy+h-g), Offset(cx+h-g,cy+h-g)]; break;
      case 'front':  corners = [Offset(cx-h+g,cy-h+g), Offset(cx+h-g,cy-h+g), Offset(cx+h-g,cy+h-g), Offset(cx-h+g,cy+h-g)]; break;
      case 'back':   corners = [Offset(cx-h,cy-h), Offset(cx+h,cy-h), Offset(cx+h,cy+h), Offset(cx-h,cy+h)]; break;
      default: corners = [];
    }
    return _FacePoly(color: c, normal: n, corners: corners);
  }

  @override
  bool shouldRepaint(covariant _RubikPainter oldDelegate) => true;
}

class _Vector3 {
  final double x, y, z;
  _Vector3(this.x, this.y, this.z);
}

class _Vector4 {
  final double x, y, z, w;
  _Vector4(this.x, this.y, this.z, this.w);
}

class _Matrix4 {
  final List<double> d;
  _Matrix4.identity() : d = List.generate(16, (i) => i % 5 == 0 ? 1.0 : 0.0);

  void setEntry(int r, int c, double v) { d[r * 4 + c] = v; }

  void rotateX(double a) {
    final c = cos(a), s = sin(a);
    for (int i = 0; i < 4; i++) {
      final y = d[4*i+1], z = d[4*i+2];
      d[4*i+1] = y*c - z*s; d[4*i+2] = y*s + z*c;
    }
  }

  void rotateY(double a) {
    final c = cos(a), s = sin(a);
    for (int i = 0; i < 4; i++) {
      final x = d[4*i], z = d[4*i+2];
      d[4*i] = x*c + z*s; d[4*i+2] = -x*s + z*c;
    }
  }

  _Vector4 transform(_Vector4 v) => _Vector4(
    d[0]*v.x + d[4]*v.y + d[8]*v.z + d[12]*v.w,
    d[1]*v.x + d[5]*v.y + d[9]*v.z + d[13]*v.w,
    d[2]*v.x + d[6]*v.y + d[10]*v.z + d[14]*v.w,
    d[3]*v.x + d[7]*v.y + d[11]*v.z + d[15]*v.w,
  );

  _Vector3 transform3(_Vector3 v) => _Vector3(
    d[0]*v.x + d[4]*v.y + d[8]*v.z,
    d[1]*v.x + d[5]*v.y + d[9]*v.z,
    d[2]*v.x + d[6]*v.y + d[10]*v.z,
  );
}

class _FacePoly {
  final Color color;
  final _Vector3 normal;
  final List<Offset> corners;
  _FacePoly({required this.color, required this.normal, required this.corners});
}

class _Polygon {
  final double z;
  final List<Offset> corners;
  final Color color;
  _Polygon({required this.z, required this.corners, required this.color});
}
