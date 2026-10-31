/// Slovak one-letter words and short prepositions that must not end a line.
const _shortWords = 'a|i|k|o|s|u|v|z|do|ku|na|od|po|so|vo|za|zo';

// A short word at the start, after whitespace (including an earlier
// no-break space) or after an opening bracket or quote, followed by a space.
final _shortWordSpace = RegExp(
  '(?<=^|[\\s(„"‚\'])($_shortWords) ',
  caseSensitive: false,
  unicode: true,
);

/// Replaces the space after short Slovak words with a no-break space
/// (U+00A0), so they move to the next line together with the next word.
///
/// The character itself is used, not `&nbsp;`: ePub readers don't always
/// know that entity.
String bindShortWords(String text) =>
    text.replaceAllMapped(_shortWordSpace, (m) => '${m[1]} ');
