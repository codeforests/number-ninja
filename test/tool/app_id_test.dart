// FEAT-20 (D19): the BrainBubblz app id and sign-in return scheme agree
// across Gradle, the manifest, the Kotlin activities, Dart and nginx.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String read(String path) => File(path).readAsStringSync();

void main() {
  const kotlin = 'android/app/src/main/kotlin/com/brainbubblz/app';

  test('app id is com.brainbubblz.app', () {
    final gradle = read('android/app/build.gradle.kts');
    expect(gradle, contains('applicationId = "com.brainbubblz.app"'));
    expect(gradle, contains('namespace = "com.brainbubblz.app"'));
    for (final f in ['MainActivity.kt', 'SignInReturnActivity.kt']) {
      expect(read('$kotlin/$f'), startsWith('package com.brainbubblz.app\n'));
    }
    expect(
      Directory('android/app/src/main/kotlin/com/codeforests').existsSync(),
      isFalse,
    );
  });

  test('Google sign-in returns through brainbubblz://signin', () {
    expect(
      read('android/app/src/main/AndroidManifest.xml'),
      contains('<data android:scheme="brainbubblz" android:host="signin" />'),
    );
    expect(
      read('$kotlin/SignInReturnActivity.kt'),
      contains('link.scheme == "brainbubblz"'),
    );
    const channel = '"brainbubblz/sign_in"';
    expect(read('$kotlin/MainActivity.kt'), contains(channel));
    expect(read('lib/providers.dart'), contains("'brainbubblz/sign_in'"));
    final site = read('server/nginx/numberninja.conf.template');
    expect(site, contains(r'default brainbubblz;'));
    expect(site, contains(r'${SERVER_LEGACY_HOSTNAME} numberninja;'));
    expect(site, contains(r'href="$brainbubblz_app_scheme://signin/google"'));
  });
}
