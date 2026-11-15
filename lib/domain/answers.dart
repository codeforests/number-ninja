import 'question.dart';

/// Whether [given] answers [q] correctly. [given] is the option text (mcq),
/// the typed text (number) or the dropped items in slot order (drag).
bool isCorrect(Question q, Object given) {
  switch (q.format) {
    case QuestionFormat.mcq:
      return given is String && given == q.answer;
    case QuestionFormat.number:
      if (given is! String) return false;
      final a = num.tryParse((q.answer as String).trim());
      final g = num.tryParse(given.trim());
      return a != null && g != null && (a - g).abs() < 1e-9;
    case QuestionFormat.drag:
      if (given is! List) return false;
      final expected = q.answer as List<String>;
      if (given.length != expected.length) return false;
      for (var k = 0; k < expected.length; k++) {
        if (given[k] != expected[k]) return false;
      }
      return true;
  }
}
