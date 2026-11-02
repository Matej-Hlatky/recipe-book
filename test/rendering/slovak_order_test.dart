import 'package:recipe_book/rendering/slovak_order.dart';
import 'package:test/test.dart';

List<String> _sorted(List<String> words) => [...words]..sort(compareSlovak);

void main() {
  group('compareSlovak', () {
    test('sorts like the Slovak alphabet, not by character code', () {
      expect(
        _sorted(['Zemiaky', 'Šošovica', 'Tekvica', 'Slivky']),
        ['Slivky', 'Šošovica', 'Tekvica', 'Zemiaky'],
      );
      expect(_sorted(['Čaj', 'Dyňa', 'Cesto']), ['Cesto', 'Čaj', 'Dyňa']);
      expect(_sorted(['Žemľa', 'Zeler']), ['Zeler', 'Žemľa']);
    });

    test('ch is one letter after h', () {
      expect(
        _sorted(['Chlieb', 'Ichtys', 'Halušky', 'Cibuľa']),
        ['Cibuľa', 'Halušky', 'Chlieb', 'Ichtys'],
      );
    });

    test('ä follows a and ô follows o', () {
      expect(_sorted(['Bžet', 'Bäk', 'Bak']), ['Bak', 'Bäk', 'Bžet']);
      expect(_sorted(['Pôst', 'Pozor', 'Pot']), ['Pot', 'Pozor', 'Pôst']);
    });

    test('other accents only break ties', () {
      expect(_sorted(['Mäso', 'Mak', 'Málo']), ['Mak', 'Málo', 'Mäso']);
      expect(_sorted(['Rýchla', 'Ryža']), ['Rýchla', 'Ryža']);
      expect(compareSlovak('Kolác', 'Koláč'), isNegative);
    });

    test('ignores letter case', () {
      expect(_sorted(['banán', 'Avokádo', 'Citrón']),
          ['Avokádo', 'banán', 'Citrón']);
    });

    test('a shorter prefix comes first', () {
      expect(_sorted(['Koláč s makom', 'Koláč']), ['Koláč', 'Koláč s makom']);
    });
  });
}
