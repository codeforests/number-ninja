import 'dart:math';

/// A new random id: 32 lowercase hex chars (128 random bits), the same shape
/// as the v7 migration's `lower(hex(randomblob(16)))` (FEAT-14). The app
/// passes `Random.secure()`.
String newId(Random random) {
  final b = StringBuffer();
  for (var i = 0; i < 16; i++) {
    b.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return b.toString();
}
