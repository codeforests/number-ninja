/// Draws the BrainBubblz launcher icon: orange and dark bubbles on deep
/// indigo (colours from `AppColors`). Deterministic, so
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

/// The bubbles on a transparent [size] canvas; [scale] shrinks them into
/// the adaptive icon's safe zone.
img.Image _bubbles(int size, double scale, {required bool background}) {
  final im = img.Image(width: size, height: size, numChannels: 4);
  img.fill(im, color: background ? _c(_ninja) : _c(_ninja, 0));
  final cx = size ~/ 2;
  int u(double f) => (f * size * scale).round();
  int at(double f) => cx + u(f);
  void bubble(double x, double y, double r, (int, int, int) fill) {
    img.fillCircle(im, x: at(x), y: at(y), radius: u(r), color: _c(_paper));
    img.fillCircle(
      im,
      x: at(x),
      y: at(y),
      radius: u(r * 0.86),
      color: _c(fill),
    );
    // Shine: a small paper highlight towards the top left.
    img.fillCircle(
      im,
      x: at(x - r * 0.38),
      y: at(y - r * 0.38),
      radius: u(r * 0.16),
      color: _c(_paper),
    );
  }

  // One big orange bubble with two smaller ones floating up beside it.
  bubble(-0.06, 0.08, 0.26, _sun);
  bubble(0.22, -0.18, 0.12, _ink);
  bubble(0.27, 0.12, 0.07, _sun);
  return im;
}

/// `icon.png` (full icon, indigo background) and `icon_fg.png` (adaptive
/// foreground, transparent, bubbles in the safe zone), both 1024 px.
Map<String, Uint8List> buildIcons() => {
  'icon': img.encodePng(_bubbles(1024, 1, background: true)),
  'icon_fg': img.encodePng(_bubbles(1024, 0.85, background: false)),
};
