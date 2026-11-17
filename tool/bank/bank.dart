import 'package:number_ninja/domain/question.dart';

import 'generator.dart';
import 'templates_p1.dart';
import 'templates_p2.dart';
import 'templates_oly.dart';
import 'handwritten.dart';
import 'retired.dart';

/// The bank version the generator writes (FEAT-15 D2). Bump it to publish
/// a new bank; "Publish bank" refuses a version that isn't higher.
const bankVersion = 1;

/// Every template, in no meaningful order: each one has its own seed.
final allTemplates = <Template>[
  ...p1Templates,
  ...p2Templates,
  ...olyTemplates,
];

/// Hand-written questions, appended to only.
final allHandwritten = <Handwritten>[...handwritten];

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
  version: bankVersion,
  retired: {
    for (final id in retiredIds)
      if (id.startsWith(prefix)) id,
  },
);
