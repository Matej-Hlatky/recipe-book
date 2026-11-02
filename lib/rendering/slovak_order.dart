/// Letters in Slovak alphabetical order. `ch` is one letter after `h`.
const _alphabet = [
  'a', 'ä', 'b', 'c', 'č', 'd', 'e', 'f', 'g', 'h', 'ch', 'i', 'j', 'k', //
  'l', 'm', 'n', 'o', 'ô', 'p', 'q', 'r', 's', 'š', 't', 'u', 'v', 'w', //
  'x', 'y', 'z', 'ž',
];

/// Accented letters that sort as their base letter (the accent only breaks
/// ties).
const _base = {
  'á': 'a', 'ď': 'd', 'é': 'e', 'ě': 'e', 'í': 'i', 'ĺ': 'l', 'ľ': 'l', //
  'ň': 'n', 'ó': 'o', 'ö': 'o', 'ŕ': 'r', 'ř': 'r', 'ť': 't', 'ú': 'u', //
  'ů': 'u', 'ü': 'u', 'ý': 'y',
};

/// Letters come after spaces, digits and punctuation.
const _letterWeight = 0x10000;

/// One weight per letter of [text], ignoring case and tie-breaking accents.
List<int> _weights(String text) {
  final chars = text.toLowerCase().split('');
  final weights = <int>[];
  for (var i = 0; i < chars.length; i++) {
    var letter = _base[chars[i]] ?? chars[i];
    if (letter == 'c' && i + 1 < chars.length && chars[i + 1] == 'h') {
      letter = 'ch';
      i++;
    }
    final index = _alphabet.indexOf(letter);
    weights.add(index < 0 ? letter.codeUnitAt(0) : _letterWeight + index);
  }

  return weights;
}

/// Compares [a] and [b] in Slovak alphabetical order: `č` after `c`, `ch`
/// after `h`, `š` after `s` and so on, case ignored.
int compareSlovak(String a, String b) {
  final wa = _weights(a);
  final wb = _weights(b);
  for (var i = 0; i < wa.length && i < wb.length; i++) {
    if (wa[i] != wb[i]) return wa[i].compareTo(wb[i]);
  }
  if (wa.length != wb.length) return wa.length.compareTo(wb.length);

  final lower = a.toLowerCase().compareTo(b.toLowerCase());
  return lower != 0 ? lower : a.compareTo(b);
}
