/// Enhanced Rubik's Cube with 3D-like visualization
import 'dart:math';

class RubiksCube {
  // Cube faces: 0=Front, 1=Back, 2=Left, 3=Right, 4=Top, 5=Bottom
  late List<List<List<String>>> cube;
  List<String> moveHistory = [];
  
  RubiksCube() {
    initializeCube();
  }
  
  void initializeCube() {
    const colors = ['🟥', '🟧', '🟨', '🟩', '🟦', '🟪'];
    cube = List.generate(6, (face) => 
      List.generate(3, (_) => List.generate(3, (_) => colors[face]))
    );
  }
  
  /// Rotate a face clockwise
  void rotateFaceClockwise(int face) {
    final temp = List<List<String>>.from(cube[face]);
    
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        cube[face][i][j] = temp[2 - j][i];
      }
    }
    
    _rotateAdjacentFaces(face);
  }
  
  /// Rotate a face counter-clockwise
  void rotateFaceCounterClockwise(int face) {
    final temp = List<List<String>>.from(cube[face]);
    
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        cube[face][i][j] = temp[j][2 - i];
      }
    }
    
    _rotateAdjacentFaces(face);
  }
  
  void _rotateAdjacentFaces(int face) {
    // Simplified adjacent face rotation logic
    // In a full implementation, this would handle all 6 faces
    switch (face) {
      case 0: // Front
        _rotateFrontAdjacent();
        break;
      case 1: // Back
        _rotateBackAdjacent();
        break;
      case 2: // Left
        _rotateLeftAdjacent();
        break;
      case 3: // Right
        _rotateRightAdjacent();
        break;
      case 4: // Top
        _rotateTopAdjacent();
        break;
      case 5: // Bottom
        _rotateBottomAdjacent();
        break;
    }
  }
  
  void _rotateFrontAdjacent() {
    final temp = <String>[];
    for (int i = 0; i < 3; i++) temp.add(cube[4][2][i]);
    
    for (int i = 0; i < 3; i++) cube[4][2][i] = cube[2][2 - i][2];
    for (int i = 0; i < 3; i++) cube[2][2 - i][2] = cube[5][0][2 - i];
    for (int i = 0; i < 3; i++) cube[5][0][2 - i] = cube[3][i][0];
    for (int i = 0; i < 3; i++) cube[3][i][0] = temp[i];
  }
  
  void _rotateBackAdjacent() {
    final temp = <String>[];
    for (int i = 0; i < 3; i++) temp.add(cube[4][0][2 - i]);
    
    for (int i = 0; i < 3; i++) cube[4][0][2 - i] = cube[3][2 - i][2];
    for (int i = 0; i < 3; i++) cube[3][2 - i][2] = cube[5][2][i];
    for (int i = 0; i < 3; i++) cube[5][2][i] = cube[2][i][0];
    for (int i = 0; i < 3; i++) cube[2][i][0] = temp[i];
  }
  
  void _rotateLeftAdjacent() {
    final temp = <String>[];
    for (int i = 0; i < 3; i++) temp.add(cube[4][i][0]);
    
    for (int i = 0; i < 3; i++) cube[4][i][0] = cube[1][2 - i][2];
    for (int i = 0; i < 3; i++) cube[1][2 - i][2] = cube[5][i][0];
    for (int i = 0; i < 3; i++) cube[5][i][0] = cube[0][i][0];
    for (int i = 0; i < 3; i++) cube[0][i][0] = temp[i];
  }
  
  void _rotateRightAdjacent() {
    final temp = <String>[];
    for (int i = 0; i < 3; i++) temp.add(cube[4][i][2]);
    
    for (int i = 0; i < 3; i++) cube[4][i][2] = cube[0][i][2];
    for (int i = 0; i < 3; i++) cube[0][i][2] = cube[5][i][2];
    for (int i = 0; i < 3; i++) cube[5][i][2] = cube[1][2 - i][0];
    for (int i = 0; i < 3; i++) cube[1][2 - i][0] = temp[i];
  }
  
  void _rotateTopAdjacent() {
    final temp = <String>[];
    for (int i = 0; i < 3; i++) temp.add(cube[0][0][i]);
    
    for (int i = 0; i < 3; i++) cube[0][0][i] = cube[3][0][i];
    for (int i = 0; i < 3; i++) cube[3][0][i] = cube[1][0][i];
    for (int i = 0; i < 3; i++) cube[1][0][i] = cube[2][0][i];
    for (int i = 0; i < 3; i++) cube[2][0][i] = temp[i];
  }
  
  void _rotateBottomAdjacent() {
    final temp = <String>[];
    for (int i = 0; i < 3; i++) temp.add(cube[0][2][i]);
    
    for (int i = 0; i < 3; i++) cube[0][2][i] = cube[2][2][i];
    for (int i = 0; i < 3; i++) cube[2][2][i] = cube[1][2][i];
    for (int i = 0; i < 3; i++) cube[1][2][i] = cube[3][2][i];
    for (int i = 0; i < 3; i++) cube[3][2][i] = temp[i];
  }
  
  /// Scramble the cube
  void scramble() {
    final random = Random();
    const moves = [
      'R', 'R\'', 'L', 'L\'', 'U', 'U\'', 'D', 'D\'', 'F', 'F\'', 'B', 'B\''
    ];
    
    for (int i = 0; i < 20; i++) {
      final move = moves[random.nextInt(moves.length)];
      executeMove(move);
    }
  }
  
  /// Execute a move notation
  void executeMove(String move) {
    if (move.isEmpty) return;
    
    final face = move[0];
    final prime = move.length > 1 && move[1] == '\'';
    
    int faceIndex = -1;
    switch (face) {
      case 'R': faceIndex = 3; break;
      case 'L': faceIndex = 2; break;
      case 'U': faceIndex = 4; break;
      case 'D': faceIndex = 5; break;
      case 'F': faceIndex = 0; break;
      case 'B': faceIndex = 1; break;
    }
    
    if (faceIndex != -1) {
      if (prime) {
        rotateFaceCounterClockwise(faceIndex);
      } else {
        rotateFaceClockwise(faceIndex);
      }
      moveHistory.add(move);
    }
  }
  
  /// Check if the cube is solved
  bool isSolved() {
    for (int face = 0; face < 6; face++) {
      final firstColor = cube[face][0][0];
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (cube[face][i][j] != firstColor) return false;
        }
      }
    }
    return true;
  }
  
  /// Reset the cube
  void reset() {
    initializeCube();
    moveHistory.clear();
  }
  
  /// Undo the last move
  void undo() {
    if (moveHistory.isNotEmpty) {
      moveHistory.removeLast();
      reset();
      for (final move in moveHistory) {
        executeMove(move);
      }
    }
  }
}
