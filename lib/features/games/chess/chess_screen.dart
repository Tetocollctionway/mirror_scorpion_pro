import 'package:flutter/material.dart';
import 'chess_game.dart';

class ChessScreen extends StatefulWidget {
  const ChessScreen({super.key});

  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  late ChessGame game;
  
  @override
  void initState() {
    super.initState();
    game = ChessGame();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildChessBoard(),
                      const SizedBox(height: 16),
                      _buildGameInfo(),
                      const SizedBox(height: 16),
                      _buildControls(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الشطرنج الاحترافي',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Professional Chess Game',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChessBoard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            childAspectRatio: 1,
          ),
          itemCount: 64,
          itemBuilder: (context, index) {
            int row = index ~/ 8;
            int col = index % 8;
            bool isLight = (row + col) % 2 == 0;
            bool isSelected = game.selectedSquare == '$row,$col';
            bool isValidMove = game.validMoves.contains('$row,$col');
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (game.selectedSquare == null) {
                    game.selectSquare(row, col);
                  } else if (game.selectedSquare == '$row,$col') {
                    game.selectedSquare = null;
                    game.validMoves = [];
                  } else if (isValidMove) {
                    final parts = game.selectedSquare!.split(',');
                    game.movePiece(int.parse(parts[0]), int.parse(parts[1]), row, col);
                  } else {
                    game.selectSquare(row, col);
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.amber.withOpacity(0.7)
                      : isValidMove
                          ? Colors.green.withOpacity(0.5)
                          : isLight
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                ),
                child: Center(
                  child: _buildPiece(game.board[row][col]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildPiece(ChessPiece? piece) {
    if (piece == null) return const SizedBox.shrink();
    
    final pieceSymbols = {
      'pawn': '♟',
      'rook': '♜',
      'knight': '♞',
      'bishop': '♝',
      'queen': '♛',
      'king': '♚',
    };
    
    final symbol = pieceSymbols[piece.type] ?? '';
    final color = piece.color == 'white' ? Colors.white : Colors.black;
    
    return Text(
      symbol,
      style: TextStyle(
        fontSize: 32,
        color: color,
        shadows: [
          Shadow(
            color: piece.color == 'white' ? Colors.black : Colors.white,
            blurRadius: 2,
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  'الدور الحالي',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: game.isWhiteTurn ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    game.isWhiteTurn ? 'الأبيض' : 'الأسود',
                    style: TextStyle(
                      color: game.isWhiteTurn ? Colors.white : Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  'الحركات الصحيحة',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${game.validMoves.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  game.resetGame();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة تعيين'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  game.selectedSquare = null;
                  game.validMoves = [];
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('إلغاء الاختيار'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
