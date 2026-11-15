/// Draws the Number Ninja launcher icon: a ninja face with an orange
/// headband on deep indigo (colours from `AppColors`). Deterministic, so
/// `test/tool/icon_test.dart` can compare it with `assets/icon/`.
library;

import 'dart:typed_data';

import 'package:image/image.dart' as img;

// AppColors.ninja, AppColors.sun, AppColors.paper, AppColors.ink as RGB.
// (tool/ is plain Dart and can't import the Flutter theme.)
const _ninja = (0x2E, 0x31, 0x92);
const _sun = (0xFF, 0x8A, 0x00);
const _paper = (0xFF, 0xFB, 0xF2);
const _ink = (0x1C, 0x1C, 0x28);

img.Color _c((int, int, int) rgb, [int a = 255]) =>
    img.ColorRgba8(rgb.$1, rgb.$2, rgb.$3, a);

/// The face on a transparent [size] canvas; [scale] shrinks it into the
/// adaptive icon's safe zone.
img.Image _face(int size, double scale, {required bool background}) {
  final im = img.Image(width: size, height: size, numChannels: 4);
  img.fill(im, color: background ? _c(_ninja) : _c(_ninja, 0));
  final cx = size ~/ 2;
  int u(double f) => (f * size * scale).round();
  // Head: an ink-dark hood.
  img.fillCircle(im, x: cx, y: cx, radius: u(0.36), color: _c(_ink));
  // Eye band across the face.
  img.fillRect(
    im,
    x1: cx - u(0.30),
    y1: cx - u(0.09),
    x2: cx + u(0.30),
    y2: cx + u(0.09),
    radius: u(0.08),
    color: _c(_paper),
  );
  // Eyes, looking slightly up: determined.
  for (final dx in [-0.13, 0.13]) {
    img.fillCircle(
      im,
      x: cx + u(dx),
      y: cx - u(0.005),
      radius: u(0.045),
      color: _c(_ink),
    );
  }
  // Orange headband over the forehead, with two tails on the right.
  img.fillRect(
    im,
    x1: cx - u(0.34),
    y1: cx - u(0.21),
    x2: cx + u(0.34),
    y2: cx - u(0.14),
    radius: u(0.03),
    color: _c(_sun),
  );
  for (final (dy, len) in [(-0.20, 0.16), (-0.13, 0.12)]) {
    img.fillRect(
      im,
      x1: cx + u(0.30),
      y1: cx + u(dy),
      x2: cx + u(0.30 + len),
      y2: cx + u(dy + 0.05),
      radius: u(0.025),
      color: _c(_sun),
    );
  }
  return im;
}

/// `icon.png` (full icon, indigo background) and `icon_fg.png` (adaptive
/// foreground, transparent, face in the safe zone), both 1024 px.
Map<String, Uint8List> buildIcons() => {
  'icon': img.encodePng(_face(1024, 1, background: true)),
  'icon_fg': img.encodePng(_face(1024, 0.85, background: false)),
};
