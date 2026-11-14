import 'package:number_ninja/domain/question.dart';

import 'generator.dart';
import 'templates_p1.dart';

/// Every template, in no meaningful order: each one has its own seed.
final allTemplates = <Template>[...p1Templates];

/// Hand-written questions, appended to only.
final allHandwritten = <Handwritten>[];

/// The bank for the topics whose id starts with [prefix] ('' for all).
QuestionBank buildFor(String prefix) => buildBank(
  [
    for (final t in allTemplates)
      if (t.topic.startsWith(prefix)) t,
  ],
  handwritten: [
    for (final h in allHandwritten)
      if (h.topic.startsWith(prefix)) h,
  ],
);
