import 'package:recipe_book/rendering/typography.dart';
import 'package:test/test.dart';

const nbsp = ' ';

void main() {
  group('bindShortWords', () {
    test('binds one-letter words to the next word', () {
      expect(
        bindShortWords('Piecť v rúre a podávať s cukrom.'),
        'Piecť v${nbsp}rúre a${nbsp}podávať s${nbsp}cukrom.',
      );
    });

    test('binds short prepositions', () {
      expect(
        bindShortWords('Dať do chladničky na noc, potom zo misy.'),
        'Dať do${nbsp}chladničky na${nbsp}noc, potom zo${nbsp}misy.',
      );
    });

    test('binds capitalised words at the start', () {
      expect(bindShortWords('V miske zmiešať.'), 'V${nbsp}miske zmiešať.');
      expect(bindShortWords('Do misy dať.'), 'Do${nbsp}misy dať.');
    });

    test('binds consecutive short words', () {
      expect(bindShortWords('a v meste'), 'a${nbsp}v${nbsp}meste');
    });

    test('binds after an opening bracket or quote', () {
      expect(bindShortWords('(s cukrom)'), '(s${nbsp}cukrom)');
      expect(bindShortWords('„k mäsu“'), '„k${nbsp}mäsu“');
    });

    test('leaves short words inside longer words alone', () {
      expect(bindShortWords('Bábovka sa pečie.'), 'Bábovka sa pečie.');
      expect(bindShortWords('pomaly do'), 'pomaly do');
    });

    test('leaves other two-letter words alone', () {
      expect(bindShortWords('je to ok'), 'je to ok');
    });
  });
}
