// FEAT-31 AC-7 (WE-8): the weekly email names topics and badges from
// server/pb_hooks/lib/names.js, which must match the app's lists.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/badges.dart';
import 'package:number_ninja/domain/topics.dart';

Map<String, String> jsMap(String source, String name) {
  final block = RegExp('const $name = \\{([^}]*)\\};').firstMatch(source)![1]!;
  return {
    for (final m in RegExp(r'"([^"]+)": "([^"]+)",').allMatches(block))
      m[1]!: m[2]!,
  };
}

void main() {
  final js = File('server/pb_hooks/lib/names.js').readAsStringSync();

  test('topic names match lib/domain/topics.dart', () {
    expect(jsMap(js, 'TOPICS'), {for (final t in topics) t.id: t.name});
  });

  test('badge names match lib/domain/badges.dart', () {
    expect(jsMap(js, 'BADGES'), {for (final b in badges) b.id: b.name});
  });
}
