import 'package:test/test.dart';
import 'package:dartafis/src/primitives/boolean_matrix.dart';

void main() {
  group('BooleanMatrix - Testes de Construção', () {
    test('deve criar uma matriz com dimensões especificadas', () {
      final matrix = BooleanMatrix(width: 5, height: 3);

      expect(matrix.width, equals(5));
      expect(matrix.height, equals(3));
      expect(matrix.cells.length, equals(15));
    });

    test('deve inicializar todos os valores como false por padrão', () {
      final matrix = BooleanMatrix(width: 3, height: 2);

      for (int y = 0; y < matrix.height; y++) {
        for (int x = 0; x < matrix.width; x++) {
          expect(matrix.get(x, y), isFalse);
        }
      }
    });

    test('deve aceitar valores iniciais customizados', () {
      final valoresIniciais = [true, false, true, false];
      final matrix = BooleanMatrix(width: 2, height: 2, cells: valoresIniciais);

      expect(matrix.get(0, 0), isTrue);
      expect(matrix.get(1, 0), isFalse);
      expect(matrix.get(0, 1), isTrue);
      expect(matrix.get(1, 1), isFalse);
    });

    test('deve criar matriz 1x1 corretamente', () {
      final matrix = BooleanMatrix(width: 1, height: 1);

      expect(matrix.width, equals(1));
      expect(matrix.height, equals(1));
      expect(matrix.get(0, 0), isFalse);
    });
  });

  group('BooleanMatrix - Testes de Acesso (get/set)', () {
    late BooleanMatrix matrix;

    setUp(() {
      matrix = BooleanMatrix(width: 4, height: 3);
    });

    test('deve definir e recuperar valores corretamente', () {
      matrix.set(2, 1, true);
      expect(matrix.get(2, 1), isTrue);

      matrix.set(0, 0, true);
      expect(matrix.get(0, 0), isTrue);

      matrix.set(3, 2, true);
      expect(matrix.get(3, 2), isTrue);
    });

    test('deve sobrescrever valores existentes', () {
      matrix.set(1, 1, true);
      expect(matrix.get(1, 1), isTrue);

      matrix.set(1, 1, false);
      expect(matrix.get(1, 1), isFalse);
    });

    test('deve manter valores independentes por posição', () {
      matrix.set(0, 0, true);
      matrix.set(1, 0, false);
      matrix.set(0, 1, true);
      matrix.set(1, 1, false);

      expect(matrix.get(0, 0), isTrue);
      expect(matrix.get(1, 0), isFalse);
      expect(matrix.get(0, 1), isTrue);
      expect(matrix.get(1, 1), isFalse);
    });
  });

  group('BooleanMatrix - Testes de getF (com fallback)', () {
    late BooleanMatrix matrix;

    setUp(() {
      matrix = BooleanMatrix(width: 3, height: 3);
      matrix.set(1, 1, true);
    });

    test('deve retornar valor real quando coordenadas são válidas', () {
      expect(matrix.getF(1, 1, false), isTrue);
      expect(matrix.getF(0, 0, true), isFalse);
    });

    test('deve retornar fallback para coordenadas negativas', () {
      expect(matrix.getF(-1, 0, true), isTrue);
      expect(matrix.getF(0, -1, true), isTrue);
      expect(matrix.getF(-1, -1, false), isFalse);
    });

    test('deve retornar fallback para coordenadas fora dos limites', () {
      expect(matrix.getF(3, 0, true), isTrue);
      expect(matrix.getF(0, 3, true), isTrue);
      expect(matrix.getF(3, 3, false), isFalse);
    });

    test('deve retornar fallback para coordenadas muito grandes', () {
      expect(matrix.getF(100, 100, true), isTrue);
      expect(matrix.getF(100, 100, false), isFalse);
    });
  });

  group('BooleanMatrix - Testes de Inversão', () {
    test('deve inverter todos os valores da matriz', () {
      final matrix = BooleanMatrix(width: 2, height: 2);
      matrix.set(0, 0, true);
      matrix.set(1, 1, true);

      matrix.invert();

      expect(matrix.get(0, 0), isFalse);
      expect(matrix.get(1, 0), isTrue);
      expect(matrix.get(0, 1), isTrue);
      expect(matrix.get(1, 1), isFalse);
    });

    test('deve inverter matriz completamente false', () {
      final matrix = BooleanMatrix(width: 3, height: 3);

      matrix.invert();

      for (int y = 0; y < matrix.height; y++) {
        for (int x = 0; x < matrix.width; x++) {
          expect(matrix.get(x, y), isTrue);
        }
      }
    });

    test('deve inverter matriz completamente true', () {
      final matrix = BooleanMatrix(width: 2, height: 2);

      // Definir todos como true
      for (int y = 0; y < matrix.height; y++) {
        for (int x = 0; x < matrix.width; x++) {
          matrix.set(x, y, true);
        }
      }

      matrix.invert();

      for (int y = 0; y < matrix.height; y++) {
        for (int x = 0; x < matrix.width; x++) {
          expect(matrix.get(x, y), isFalse);
        }
      }
    });

    test('deve permitir múltiplas inversões', () {
      final matrix = BooleanMatrix(width: 2, height: 2);
      matrix.set(0, 0, true);
      matrix.set(1, 1, true);

      final estadoOriginal = [
        matrix.get(0, 0),
        matrix.get(1, 0),
        matrix.get(0, 1),
        matrix.get(1, 1),
      ];

      matrix.invert();
      matrix.invert();

      expect(matrix.get(0, 0), equals(estadoOriginal[0]));
      expect(matrix.get(1, 0), equals(estadoOriginal[1]));
      expect(matrix.get(0, 1), equals(estadoOriginal[2]));
      expect(matrix.get(1, 1), equals(estadoOriginal[3]));
    });
  });

  group('BooleanMatrix - Testes de Merge', () {
    test('deve fazer merge corretamente com operação OR', () {
      final matrix1 = BooleanMatrix(width: 2, height: 2);
      final matrix2 = BooleanMatrix(width: 2, height: 2);

      matrix1.set(0, 0, true);
      matrix1.set(1, 1, true);

      matrix2.set(0, 1, true);
      matrix2.set(1, 0, true);

      matrix1.merge(matrix2);

      expect(matrix1.get(0, 0), isTrue); // true OR false = true
      expect(matrix1.get(1, 0), isTrue); // false OR true = true
      expect(matrix1.get(0, 1), isTrue); // false OR true = true
      expect(matrix1.get(1, 1), isTrue); // true OR false = true
    });

    test('deve manter valores true após merge', () {
      final matrix1 = BooleanMatrix(width: 2, height: 2);
      final matrix2 = BooleanMatrix(width: 2, height: 2);

      matrix1.set(0, 0, true);
      matrix1.set(1, 1, true);

      matrix2.set(0, 0, true);
      matrix2.set(1, 1, false);

      matrix1.merge(matrix2);

      expect(matrix1.get(0, 0), isTrue); // true OR true = true
      expect(matrix1.get(1, 1), isTrue); // true OR false = true
    });

    test('deve lançar exceção para dimensões incompatíveis', () {
      final matrix1 = BooleanMatrix(width: 2, height: 2);
      final matrix2 = BooleanMatrix(width: 3, height: 2);

      expect(() => matrix1.merge(matrix2), throwsArgumentError);
    });

    test('deve lançar exceção para alturas incompatíveis', () {
      final matrix1 = BooleanMatrix(width: 2, height: 2);
      final matrix2 = BooleanMatrix(width: 2, height: 3);

      expect(() => matrix1.merge(matrix2), throwsArgumentError);
    });

    test('deve permitir merge com matriz vazia', () {
      final matrix1 = BooleanMatrix(width: 2, height: 2);
      final matrix2 = BooleanMatrix(width: 2, height: 2);

      matrix1.set(0, 0, true);
      matrix1.set(1, 1, true);

      matrix1.merge(matrix2);

      expect(matrix1.get(0, 0), isTrue);
      expect(matrix1.get(1, 0), isFalse);
      expect(matrix1.get(0, 1), isFalse);
      expect(matrix1.get(1, 1), isTrue);
    });
  });

  group('BooleanMatrix - Testes de Hash', () {
    test('deve gerar hash consistente para a mesma matriz', () {
      final matrix = BooleanMatrix(width: 2, height: 2);
      matrix.set(0, 0, true);
      matrix.set(1, 1, true);

      final hash1 = matrix.hash();
      final hash2 = matrix.hash();

      expect(hash1, equals(hash2));
    });

    test('deve gerar hashes diferentes para matrizes diferentes', () {
      final matrix1 = BooleanMatrix(width: 2, height: 2);
      final matrix2 = BooleanMatrix(width: 2, height: 2);

      matrix1.set(0, 0, true);
      matrix2.set(1, 1, true);

      expect(matrix1.hash(), isNot(equals(matrix2.hash())));
    });

    test('deve gerar hash correto para matriz vazia', () {
      final matrix = BooleanMatrix(width: 2, height: 2);
      const expectedHash = '0000';

      expect(matrix.hash(), equals(expectedHash));
    });

    test('deve gerar hash correto para matriz cheia', () {
      final matrix = BooleanMatrix(width: 2, height: 2);
      matrix.set(0, 0, true);
      matrix.set(1, 0, true);
      matrix.set(0, 1, true);
      matrix.set(1, 1, true);

      const expectedHash = '1111';

      expect(matrix.hash(), equals(expectedHash));
    });

    test('deve gerar hash em ordem correta (linha por linha)', () {
      final matrix = BooleanMatrix(width: 3, height: 2);
      matrix.set(0, 0, true);
      matrix.set(2, 0, true);
      matrix.set(1, 1, true);

      const expectedHash = '101010';

      expect(matrix.hash(), equals(expectedHash));
    });
  });

  group('BooleanMatrix - Testes de toString', () {
    test('deve retornar string MD5 válida', () {
      final matrix = BooleanMatrix(width: 2, height: 2);
      matrix.set(0, 0, true);

      final result = matrix.toString();

      expect(result, hasLength(32));
      expect(result, matches(RegExp(r'^[A-F0-9]{32}$')));
    });

    test('deve retornar strings diferentes para matrizes diferentes', () {
      final matrix1 = BooleanMatrix(width: 2, height: 2);
      final matrix2 = BooleanMatrix(width: 2, height: 2);

      matrix1.set(0, 0, true);
      matrix2.set(1, 1, true);

      expect(matrix1.toString(), isNot(equals(matrix2.toString())));
    });

    test('deve retornar string consistente para a mesma matriz', () {
      final matrix = BooleanMatrix(width: 2, height: 2);
      matrix.set(0, 0, true);
      matrix.set(1, 1, true);

      final result1 = matrix.toString();
      final result2 = matrix.toString();

      expect(result1, equals(result2));
    });
  });

  group('BooleanMatrix - Testes de Casos Extremos', () {
    test('deve lidar com matriz 1x1', () {
      final matrix = BooleanMatrix(width: 1, height: 1);

      expect(matrix.get(0, 0), isFalse);
      matrix.set(0, 0, true);
      expect(matrix.get(0, 0), isTrue);

      matrix.invert();
      expect(matrix.get(0, 0), isFalse);
    });

    test('deve lidar com matriz larga (1xN)', () {
      final matrix = BooleanMatrix(width: 10, height: 1);

      for (int x = 0; x < 10; x++) {
        matrix.set(x, 0, x % 2 == 0);
      }

      expect(matrix.get(0, 0), isTrue);
      expect(matrix.get(1, 0), isFalse);
      expect(matrix.get(8, 0), isTrue);
      expect(matrix.get(9, 0), isFalse);
    });

    test('deve lidar com matriz alta (Nx1)', () {
      final matrix = BooleanMatrix(width: 1, height: 10);

      for (int y = 0; y < 10; y++) {
        matrix.set(0, y, y % 2 == 0);
      }

      expect(matrix.get(0, 0), isTrue);
      expect(matrix.get(0, 1), isFalse);
      expect(matrix.get(0, 8), isTrue);
      expect(matrix.get(0, 9), isFalse);
    });

    test('deve lidar com matriz grande', () {
      final matrix = BooleanMatrix(width: 100, height: 100);

      // Definir padrão diagonal
      for (int i = 0; i < 100; i++) {
        matrix.set(i, i, true);
      }

      // Verificar diagonal
      for (int i = 0; i < 100; i++) {
        expect(matrix.get(i, i), isTrue);
      }

      // Verificar não-diagonal
      expect(matrix.get(0, 1), isFalse);
      expect(matrix.get(1, 0), isFalse);
    });
  });

  group('BooleanMatrix - Testes de Performance', () {
    test('deve executar operações rapidamente em matriz grande', () {
      final stopwatch = Stopwatch()..start();

      final matrix = BooleanMatrix(width: 1000, height: 1000);

      // Preencher matriz
      for (int y = 0; y < 1000; y++) {
        for (int x = 0; x < 1000; x++) {
          matrix.set(x, y, (x + y) % 2 == 0);
        }
      }

      // Inverter
      matrix.invert();

      // Verificar alguns valores
      expect(matrix.get(0, 0), isFalse);
      expect(matrix.get(1, 0), isTrue);

      stopwatch.stop();

      // Deve executar em menos de 5 segundos
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });
  });

  group('BooleanMatrix - Testes de Integridade', () {
    test('deve manter consistência após múltiplas operações', () {
      final matrix = BooleanMatrix(width: 5, height: 5);

      // Definir padrão inicial
      matrix.set(0, 0, true);
      matrix.set(2, 2, true);
      matrix.set(4, 4, true);

      // Criar matriz para merge
      final other = BooleanMatrix(width: 5, height: 5);
      other.set(1, 1, true);
      other.set(3, 3, true);

      // Fazer merge
      matrix.merge(other);

      // Verificar resultado
      expect(matrix.get(0, 0), isTrue);
      expect(matrix.get(1, 1), isTrue);
      expect(matrix.get(2, 2), isTrue);
      expect(matrix.get(3, 3), isTrue);
      expect(matrix.get(4, 4), isTrue);

      // Inverter
      matrix.invert();

      // Verificar inversão
      expect(matrix.get(0, 0), isFalse);
      expect(matrix.get(1, 1), isFalse);
      expect(matrix.get(2, 2), isFalse);
      expect(matrix.get(3, 3), isFalse);
      expect(matrix.get(4, 4), isFalse);
      expect(matrix.get(0, 1), isTrue);
      expect(matrix.get(1, 0), isTrue);
    });
  });
}
