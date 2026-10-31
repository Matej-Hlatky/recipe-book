import 'package:recipe_book/git.dart';
import 'package:test/test.dart';

void main() {
  test('gitCommitHash returns a short commit hash', () {
    expect(gitCommitHash(), matches(RegExp(r'^[0-9a-f]{7,}$')));
  });
}
