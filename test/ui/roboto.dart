import 'dart:io';

import 'package:flutter/services.dart';

/// The SDK's bundled Roboto, so text has the widths the tablet draws
/// (the default test font, Ahem, is wider).
Directory robotoDir() {
  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      '${Platform.environment['HOME']}/sdk/flutter';
  return Directory('$root/bin/cache/artifacts/material_fonts');
}

Future<bool> loadRoboto() async {
  final dir = robotoDir();
  if (!File('${dir.path}/Roboto-Regular.ttf').existsSync()) return false;
  final roboto = FontLoader('Roboto');
  for (final w in ['Regular', 'Medium', 'Bold', 'Black']) {
    final bytes = File('${dir.path}/Roboto-$w.ttf').readAsBytesSync();
    roboto.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await roboto.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      Future.value(
        ByteData.sublistView(
          File('${dir.path}/MaterialIcons-Regular.otf').readAsBytesSync(),
        ),
      ),
    );
  await icons.load();
  return true;
}
