import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/data/question_bank_loader.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/ui/visuals/figure_visual.dart';
import 'package:number_ninja/ui/visuals/icons.dart';
import 'package:number_ninja/ui/visuals/question_visual.dart';

/// Sample data per kind, incl. the extremes in the shipped bank.
const samples = <String, List<Map<String, dynamic>>>{
  'clock': [
    {'kind': 'clock', 'h': 7, 'm': 0},
    {'kind': 'clock', 'h': 12, 'm': 55},
  ],
  'coins': [
    {
      'kind': 'coins',
      'cents': [100, 50, 20, 10, 5, 5],
    },
    {
      'kind': 'coins',
      'cents': [10],
    },
  ],
  'fraction': [
    {'kind': 'fraction', 'parts': 2, 'shaded': 1},
    {'kind': 'fraction', 'parts': 12, 'shaded': 7},
  ],
  'ruler': [
    {'kind': 'ruler', 'cm': 1},
    {'kind': 'ruler', 'cm': 15},
  ],
  'shapes': [
    {
      'kind': 'shapes',
      'items': [
        {'shape': 'circle', 'color': 'red'},
        {'shape': 'square', 'color': 'blue'},
        {'shape': 'triangle', 'color': 'yellow'},
        {'shape': 'rectangle', 'color': 'green'},
        {'shape': 'semicircle', 'color': 'red'},
        {'shape': 'quarter circle', 'color': 'blue'},
        {'shape': 'circle', 'color': 'red'},
        {'shape': 'square', 'color': 'blue'},
        {'shape': 'triangle', 'color': 'yellow'},
        {'shape': 'rectangle', 'color': 'green'},
        {'shape': 'semicircle', 'color': 'red'},
        {'shape': 'quarter circle', 'color': 'blue'},
      ],
    },
  ],
  'figure': [
    {'kind': 'figure', 'name': 'triangle-split-3'},
    {'kind': 'figure', 'name': 'square-diagonals'},
    {'kind': 'figure', 'name': 'grid-2x2'},
    {'kind': 'figure', 'name': 'grid-3x3'},
    {'kind': 'figure', 'name': 'grid-2x3'},
  ],
  'groups': [
    {'kind': 'groups', 'groups': 2, 'each': 5, 'icon': 'flower'},
    {'kind': 'groups', 'groups': 9, 'each': 10, 'icon': 'crayon'},
    {'kind': 'groups', 'groups': 3, 'each': 1, 'icon': 'apple'},
  ],
  'pictureGraph': [
    {
      'kind': 'pictureGraph',
      'title': 'Favourite sport',
      'rows': [
        {'label': 'swimming', 'count': 5},
        {'label': 'running', 'count': 1},
        {'label': 'badminton', 'count': 7},
      ],
      'scale': 1,
      'icon': 'child',
    },
    {
      'kind': 'pictureGraph',
      'title': 'Books read',
      'rows': [
        {'label': 'basketballs', 'count': 90},
        {'label': 'b', 'count': 10},
        {'label': 'c', 'count': 0},
        {'label': 'd', 'count': 40},
      ],
      'scale': 10,
      'icon': 'child',
    },
  ],
  'barModel': [
    {
      'kind': 'barModel',
      'bars': [
        {'label': 'Jun Wei', 'units': 6, 'unitValue': 25},
        {'label': 'Ben', 'units': 1, 'unitValue': 25},
      ],
    },
    {
      'kind': 'barModel',
      'bars': [
        {'label': 'Daniel', 'units': 1, 'known': 16},
        {'label': 'Siti', 'units': 1},
      ],
      'total': 40,
    },
  ],
};

void main() {
  for (final MapEntry(key: kind, value: list) in samples.entries) {
    for (final size in const [Size(600, 360), Size(240, 160)]) {
      testWidgets('$kind renders in a ${size.width}×${size.height} box', (
        tester,
      ) async {
        for (final v in list) {
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: SizedBox.fromSize(size: size, child: QuestionVisual(v)),
              ),
            ),
          );
          expect(tester.takeException(), isNull, reason: '$v');
          final box = tester.getSize(find.byType(QuestionVisual));
          expect(box.width, lessThanOrEqualTo(size.width));
          expect(box.height, lessThanOrEqualTo(size.height));
        }
      });
    }
  }

  test('every sampled kind is handled', () {
    expect(visualKinds, containsAll(samples.keys));
  });

  test('every visual kind and icon in the shipped bank is handled', () {
    final bank = QuestionBank.fromJson(
      jsonDecode(File(bankAsset).readAsStringSync()) as Map<String, dynamic>,
    );
    final kinds = {
      for (final q in bank.questions)
        if (q.visual != null) q.visual!['kind'] as String,
    };
    final icons = {
      for (final q in bank.questions)
        if (q.visual?['icon'] case final String i) i,
    };
    final figures = {
      for (final q in bank.questions)
        if (q.visual?['kind'] == 'figure') q.visual!['name'] as String,
    };
    expect(kinds, hasLength(9));
    expect(visualKinds, containsAll(kinds));
    expect(visualIcons.keys, containsAll(icons));
    expect(FigureVisual.names, containsAll(figures));
  });
}
