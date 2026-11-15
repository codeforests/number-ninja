import 'dart:ui' show Size;

/// Whether a child screen puts its two halves side by side (NFR-02): only
/// when the screen is landscape and at least 600 dp wide; otherwise they
/// stack (NFR-09).
bool sideBySide(Size s) => s.width > s.height && s.width >= 600;
