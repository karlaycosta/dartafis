final class Integers {
  static int sq(int value) {
    return value * value;
  }

  // TODO: Copiado do Java
  /// Retorna o número de zero bits que precedem o bit de ordem mais alta ("mais à esquerda")
  /// na representação binária de complemento de dois do valor [int] especificado. Retorna 32
  /// se o valor especificado não tiver um bit em sua representação em complemento de dois,
  /// ou seja, se for igual a zero.
  static int numberOfLeadingZeros(int i) {
    // HD, Count leading 0's
    if (i <= 0) {
      return i == 0 ? 32 : 0;
    }
    int n = 31;
    if (i >= 1 << 16) {
      n -= 16;
      i >>>= 16;
    }
    if (i >= 1 << 8) {
      n -= 8;
      i >>>= 8;
    }
    if (i >= 1 << 4) {
      n -= 4;
      i >>>= 4;
    }
    if (i >= 1 << 2) {
      n -= 2;
      i >>>= 2;
    }
    return n - (i >>> 1);
  }
}
