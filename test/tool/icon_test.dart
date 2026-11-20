import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import '../../tool/icon/draw.dart';

/// FEAT-09 AC-6: the launcher icon is ours and reproducible.
void main() {
  test('the generator reproduces assets/icon with no diff', () {
    for (final e in buildIcons().entries) {
      expect(
        File('assets/icon/${e.key}.png').readAsBytesSync(),
        e.value,
        reason: 'run dart run tool/generate_icon.dart',
      );
    }
  });

  test('Android mipmaps are the bubble icon, with an adaptive icon', () {
    const res = 'android/app/src/main/res';
    for (final d in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
      final png = img.decodePng(
        File('$res/mipmap-$d/ic_launcher.png').readAsBytesSync(),
      )!;
      // The corner is AppColors.ninja (the Flutter default is not).
      final corner = png.getPixel(1, 1);
      // Resizing may shift a channel by one or two.
      final want = [0x2E, 0x31, 0x92];
      final got = [corner.r, corner.g, corner.b];
      for (var i = 0; i < 3; i++) {
        expect((got[i] - want[i]).abs(), lessThanOrEqualTo(2), reason: d);
      }
    }
    final adaptive = File('$res/mipmap-anydpi-v26/ic_launcher.xml')
        .readAsStringSync();
    expect(adaptive, contains('adaptive-icon'));
    expect(adaptive, contains('ic_launcher_foreground'));
  });

  test('version is 2.2.0+6', () {
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('\nversion: 2.2.0+6\n'),
    );
  });
}
