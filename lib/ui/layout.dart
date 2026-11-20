import 'dart:ui' show Size;

/// Whether a child screen puts its two halves side by side (NFR-02): only
/// when the screen is landscape and at least 600 dp wide; otherwise they
/// stack (NFR-09).
bool sideBySide(Size s) => s.width > s.height && s.width >= 600;

/// Whether the screen is phone-sized (FEAT-19): its shorter side is under
/// 600 dp. Phone screens use the compact keypads and layouts so that Check
/// and the PIN keys fit without scrolling; tablets keep their layout.
bool compact(Size s) => s.shortestSide < 600;
