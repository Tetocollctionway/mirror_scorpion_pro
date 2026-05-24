/// Chess Game Engine with full game logic
class ChessGame {
  late List<List<ChessPiece?>> board;
  bool isWhiteTurn = true;
  String? selectedSquare;
  List<String> validMoves = [];
  
  ChessGame() {
    initializeBoard();
  }
  
  void initializeBoard() {
    board = List.generate(8, (_) => List.filled(8, null));
    
    // Place white pieces
    board[7][0] = ChessPiece('rook', 'white');
    board[7][1] = ChessPiece('knight', 'white');
    board[7][2] = ChessPiece('bishop', 'white');
    board[7][3] = ChessPiece('queen', 'white');
    board[7][4] = ChessPiece('king', 'white');
    board[7][5] = ChessPiece('bishop', 'white');
    board[7][6] = ChessPiece('knight', 'white');
    board[7][7] = ChessPiece('rook', 'white');
    
    for (int i = 0; i < 8; i++) {
      board[6][i] = ChessPiece('pawn', 'white');
    }
    
    // Place black pieces
    board[0][0] = ChessPiece('rook', 'black');
    board[0][1] = ChessPiece('knight', 'black');
    board[0][2] = ChessPiece('bishop', 'black');
    board[0][3] = ChessPiece('queen', 'black');
    board[0][4] = ChessPiece('king', 'black');
    board[0][5] = ChessPiece('bishop', 'black');
    board[0][6] = ChessPiece('knight', 'black');
    board[0][7] = ChessPiece('rook', 'black');
    
    for (int i = 0; i < 8; i++) {
      board[1][i] = ChessPiece('pawn', 'black');
    }
  }
  
  void selectSquare(int row, int col) {
    final piece = board[row][col];
    
    if (piece != null && piece.color == (isWhiteTurn ? 'white' : 'black')) {
      selectedSquare = '$row,$col';
      validMoves = getValidMoves(row, col);
    }
  }
  
  List<String> getValidMoves(int row, int col) {
    final piece = board[row][col];
    if (piece == null) return [];
    
    List<String> moves = [];
    
    switch (piece.type) {
      case 'pawn':
        moves = _getPawnMoves(row, col, piece.color);
        break;
      case 'rook':
        moves = _getRookMoves(row, col, piece.color);
        break;
      case 'knight':
        moves = _getKnightMoves(row, col, piece.color);
        break;
      case 'bishop':
        moves = _getBishopMoves(row, col, piece.color);
        break;
      case 'queen':
        moves = _getQueenMoves(row, col, piece.color);
        break;
      case 'king':
        moves = _getKingMoves(row, col, piece.color);
        break;
    }
    
    return moves;
  }
  
  List<String> _getPawnMoves(int row, int col, String color) {
    List<String> moves = [];
    int direction = color == 'white' ? -1 : 1;
    int startRow = color == 'white' ? 6 : 1;
    
    // Forward move
    int newRow = row + direction;
    if (newRow >= 0 && newRow < 8 && board[newRow][col] == null) {
      moves.add('$newRow,$col');
      
      // Double move from start
      if (row == startRow) {
        int doubleRow = row + 2 * direction;
        if (board[doubleRow][col] == null) {
          moves.add('$doubleRow,$col');
        }
      }
    }
    
    // Capture diagonally
    for (int dc in [-1, 1]) {
      int newCol = col + dc;
      if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
        final target = board[newRow][newCol];
        if (target != null && target.color != color) {
          moves.add('$newRow,$newCol');
        }
      }
    }
    
    return moves;
  }
  
  List<String> _getRookMoves(int row, int col, String color) {
    List<String> moves = [];
    
    for (var direction in [[-1, 0], [1, 0], [0, -1], [0, 1]]) {
      for (int i = 1; i < 8; i++) {
        int newRow = row + direction[0] * i;
        int newCol = col + direction[1] * i;
        
        if (newRow < 0 || newRow >= 8 || newCol < 0 || newCol >= 8) break;
        
        final piece = board[newRow][newCol];
        if (piece == null) {
          moves.add('$newRow,$newCol');
        } else if (piece.color != color) {
          moves.add('$newRow,$newCol');
          break;
        } else {
          break;
        }
      }
    }
    
    return moves;
  }
  
  List<String> _getKnightMoves(int row, int col, String color) {
    List<String> moves = [];
    
    for (var offset in [[-2, -1], [-2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]]) {
      int newRow = row + offset[0];
      int newCol = col + offset[1];
      
      if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
        final piece = board[newRow][newCol];
        if (piece == null || piece.color != color) {
          moves.add('$newRow,$newCol');
        }
      }
    }
    
    return moves;
  }
  
  List<String> _getBishopMoves(int row, int col, String color) {
    List<String> moves = [];
    
    for (var direction in [[-1, -1], [-1, 1], [1, -1], [1, 1]]) {
      for (int i = 1; i < 8; i++) {
        int newRow = row + direction[0] * i;
        int newCol = col + direction[1] * i;
        
        if (newRow < 0 || newRow >= 8 || newCol < 0 || newCol >= 8) break;
        
        final piece = board[newRow][newCol];
        if (piece == null) {
          moves.add('$newRow,$newCol');
        } else if (piece.color != color) {
          moves.add('$newRow,$newCol');
          break;
        } else {
          break;
        }
      }
    }
    
    return moves;
  }
  
  List<String> _getQueenMoves(int row, int col, String color) {
    return [..._getRookMoves(row, col, color), ..._getBishopMoves(row, col, color)];
  }
  
  List<String> _getKingMoves(int row, int col, String color) {
    List<String> moves = [];
    
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        
        int newRow = row + dr;
        int newCol = col + dc;
        
        if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
          final piece = board[newRow][newCol];
          if (piece == null || piece.color != color) {
            moves.add('$newRow,$newCol');
          }
        }
      }
    }
    
    return moves;
  }
  
  bool movePiece(int fromRow, int fromCol, int toRow, int toCol) {
    final piece = board[fromRow][fromCol];
    if (piece == null) return false;
    
    final moveStr = '$toRow,$toCol';
    if (!validMoves.contains(moveStr)) return false;
    
    board[toRow][toCol] = piece;
    board[fromRow][fromCol] = null;
    isWhiteTurn = !isWhiteTurn;
    selectedSquare = null;
    validMoves = [];
    
    return true;
  }
  
  void resetGame() {
    initializeBoard();
    isWhiteTurn = true;
    selectedSquare = null;
    validMoves = [];
  }
}

class ChessPiece {
  final String type; // pawn, rook, knight, bishop, queen, king
  final String color; // white, black
  
  ChessPiece(this.type, this.color);
}
