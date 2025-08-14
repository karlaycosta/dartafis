import 'dart:typed_data';
import 'package:crypto/crypto.dart';

@pragma('vm:prefer-inline')
class BooleanMatrix {
  final int width;
  final int height;
  final Uint8List _data;
  final int _totalSize;

  BooleanMatrix({required this.width, required this.height, List<bool>? cells})
    : _totalSize = width * height,
      _data = Uint8List(width * height) {
    if (cells != null) {
      final length = cells.length;
      for (int i = 0; i < length; i++) {
        _data[i] = cells[i] ? 1 : 0;
      }
    }
  }

  // Construtor otimizado para cópia de dados
  BooleanMatrix.fromData(this.width, this.height, Uint8List data)
    : _totalSize = width * height,
      _data = data;

  // Construtor para inicialização com valor específico
  BooleanMatrix.filled(this.width, this.height, bool value)
    : _totalSize = width * height,
      _data = Uint8List(width * height) {
    if (value) {
      _data.fillRange(0, _totalSize, 1);
    }
  }

  // Getter para acesso direto aos dados (para otimizações)
  Uint8List get data => _data;

  // Getter para compatibilidade com código existente (use com parcimônia)
  List<bool> get cells => List.generate(_totalSize, (i) => _data[i] != 0);

  @pragma('vm:prefer-inline')
  void set(int x, int y, bool value) {
    _data[y * width + x] = value ? 1 : 0;
  }

  @pragma('vm:prefer-inline')
  void setUnsafe(int x, int y, bool value) {
    _data[y * width + x] = value ? 1 : 0;
  }

  @pragma('vm:prefer-inline')
  void setByIndex(int index, bool value) {
    _data[index] = value ? 1 : 0;
  }

  @pragma('vm:prefer-inline')
  bool get(int x, int y) => _data[y * width + x] != 0;

  @pragma('vm:prefer-inline')
  bool getUnsafe(int x, int y) => _data[y * width + x] != 0;

  @pragma('vm:prefer-inline')
  bool getByIndex(int index) => _data[index] != 0;

  @pragma('vm:prefer-inline')
  bool getF(int x, int y, bool fallback) {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return fallback;
    }
    return _data[y * width + x] != 0;
  }

  @pragma('vm:prefer-inline')
  int getIndex(int x, int y) => y * width + x;

  @pragma('vm:align-loops')
  void invert() {
    for (int i = 0; i < _totalSize; i++) {
      _data[i] = _data[i] != 0 ? 0 : 1;
    }
  }

  @pragma('vm:align-loops')
  void merge(BooleanMatrix other) {
    if (other.width != width || other.height != height) {
      throw ArgumentError('O tamanho da matriz não confere!');
    }
    final otherData = other._data;
    for (int i = 0; i < _totalSize; i++) {
      _data[i] = (_data[i] != 0 || otherData[i] != 0) ? 1 : 0;
    }
  }

  @pragma('vm:align-loops')
  void mergeOr(BooleanMatrix other) {
    if (other.width != width || other.height != height) {
      throw ArgumentError('O tamanho da matriz não confere!');
    }
    final otherData = other._data;
    for (int i = 0; i < _totalSize; i++) {
      _data[i] |= otherData[i];
    }
  }

  @pragma('vm:align-loops')
  void mergeAnd(BooleanMatrix other) {
    if (other.width != width || other.height != height) {
      throw ArgumentError('O tamanho da matriz não confere!');
    }
    final otherData = other._data;
    for (int i = 0; i < _totalSize; i++) {
      _data[i] &= otherData[i];
    }
  }

  @pragma('vm:align-loops')
  void mergeXor(BooleanMatrix other) {
    if (other.width != width || other.height != height) {
      throw ArgumentError('O tamanho da matriz não confere!');
    }
    final otherData = other._data;
    for (int i = 0; i < _totalSize; i++) {
      _data[i] ^= otherData[i];
    }
  }

  @pragma('vm:align-loops')
  void clear() {
    for (int i = 0; i < _totalSize; i++) {
      _data[i] = 0;
    }
  }

  @pragma('vm:align-loops')
  void fill(bool value) {
    final byteValue = value ? 1 : 0;
    for (int i = 0; i < _totalSize; i++) {
      _data[i] = byteValue;
    }
  }

  // Método otimizado para cópia
  BooleanMatrix copy() {
    final newData = Uint8List.fromList(_data);
    return BooleanMatrix.fromData(width, height, newData);
  }

  // Método otimizado para contagem de valores true
  @pragma('vm:align-loops')
  int countTrue() {
    int count = 0;
    for (int i = 0; i < _totalSize; i++) {
      if (_data[i] != 0) count++;
    }
    return count;
  }

  // Método otimizado para contagem de valores false
  @pragma('vm:align-loops')
  int countFalse() {
    int count = 0;
    for (int i = 0; i < _totalSize; i++) {
      if (_data[i] == 0) count++;
    }
    return count;
  }

  // Método para verificar se todas as células são false
  @pragma('vm:align-loops')
  bool isEmpty() {
    for (int i = 0; i < _totalSize; i++) {
      if (_data[i] != 0) return false;
    }
    return true;
  }

  // Método para verificar se todas as células são true
  @pragma('vm:align-loops')
  bool isFull() {
    for (int i = 0; i < _totalSize; i++) {
      if (_data[i] == 0) return false;
    }
    return true;
  }

  // Método otimizado para hash usando bytes diretamente
  String hash() {
    return md5.convert(_data).toString().toUpperCase();
  }

  // Método alternativo de hash usando buffer string (mais lento)
  String hashString() {
    final buffer = StringBuffer();
    for (int i = 0; i < _totalSize; i++) {
      buffer.write(_data[i]);
    }
    return buffer.toString();
  }

  @override
  String toString() => hash();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BooleanMatrix) return false;
    if (width != other.width || height != other.height) return false;

    for (int i = 0; i < _totalSize; i++) {
      if (_data[i] != other._data[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(width, height, hash());
}

// import 'dart:convert';
// import 'package:crypto/crypto.dart';

// class BooleanMatrix {
//   final int width;
//   final int height;
//   final List<bool> cells;

//   BooleanMatrix({required this.width, required this.height, List<bool>? cells})
//     : cells = cells ?? List.filled(width * height, false);

//   void set(int x, int y, bool value) => cells[y * width + x] = value;

//   void invert() {
//     final length = cells.length;
//     for (var i = 0; i < length; i++) {
//       // TODO: Testar essa melhoria de desempenho;
//       // cells[i];
//       cells[i] = !cells[i];
//     }
//   }

//   void merge(BooleanMatrix other) {
//     if (other.width != width || other.height != height) {
//       throw ArgumentError('O tamanho da matriz não confere!');
//     }
//     final length = cells.length;
//     for (var i = 0; i < length; i++) {
//       // TODO: Testar essa melhoria de desempenho;
//       // cells[i];
//       cells[i] |= other.cells[i];
//     }
//   }

//   bool getF(int x, int y, bool fallback) {
//     if (x < 0 || y < 0 || x >= width || y >= height) {
//       return fallback;
//     }
//     return cells[y * width + x];
//   }

//   bool get(int x, int y) => cells[y * width + x];

//   String hash() {
//     final count = cells.length;
//     final buffer = StringBuffer();
//     for (var i = 0; i < count; i++) {
//       buffer.write(cells[i] ? 1 : 0);
//     }
//     return buffer.toString();
//   }

//   @override
//   String toString() =>
//       md5.convert(utf8.encode(hash())).toString().toUpperCase();
// }
