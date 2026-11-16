/// A tiny SMTP server that keeps every message in memory (FEAT-13 tests).
/// PocketBase is started with SMTP_HOST=127.0.0.1 and SMTP_PORT=[port].
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

class Mail {
  Mail(this.to, this.raw);
  final List<String> to;
  final String raw;

  /// The message with quoted-printable soft breaks and escapes undone and
  /// base64 parts decoded, so links can be matched as plain text.
  String get text {
    final parts = <String>[raw];
    final b64 = RegExp(
      r'Content-Transfer-Encoding: base64\r?\n(?:[^\r\n]+\r?\n)*\r?\n([A-Za-z0-9+/=\r\n]+)',
    );
    for (final m in b64.allMatches(raw)) {
      try {
        parts.add(
          utf8.decode(base64.decode(m[1]!.replaceAll(RegExp(r'\s'), ''))),
        );
      } on FormatException {
        // not base64 after all
      }
    }
    return parts
        .join('\n')
        .replaceAll(RegExp(r'=\r?\n'), '')
        .replaceAllMapped(
          RegExp(r'=([0-9A-F]{2})'),
          (m) => String.fromCharCode(int.parse(m[1]!, radix: 16)),
        );
  }
}

class MailSink {
  MailSink._(this._server) {
    _server.listen(_serve);
  }

  final ServerSocket _server;
  final mails = <Mail>[];

  static Future<MailSink> start(int port) async =>
      MailSink._(await ServerSocket.bind(InternetAddress.loopbackIPv4, port));

  Future<void> close() => _server.close();

  void _serve(Socket socket) {
    final to = <String>[];
    final data = StringBuffer();
    var inData = false;
    void reply(String line) => socket.write('$line\r\n');
    reply('220 sink ESMTP');
    socket
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            if (inData) {
              if (line == '.') {
                inData = false;
                mails.add(Mail(List.of(to), data.toString()));
                to.clear();
                data.clear();
                reply('250 OK');
              } else {
                data.write(
                  '${line.startsWith('..') ? line.substring(1) : line}\r\n',
                );
              }
              return;
            }
            final cmd = line.toUpperCase();
            if (cmd.startsWith('EHLO') || cmd.startsWith('HELO')) {
              reply('250 sink');
            } else if (cmd.startsWith('RCPT TO:')) {
              to.add(line.substring(8).replaceAll(RegExp('[<> ]'), ''));
              reply('250 OK');
            } else if (cmd == 'DATA') {
              inData = true;
              reply('354 go');
            } else if (cmd == 'QUIT') {
              reply('221 bye');
              socket.close();
            } else {
              reply('250 OK');
            }
          },
          onError: (_) {},
          cancelOnError: true,
        );
  }

  /// Waits up to 10 s for a message to [email].
  Future<Mail> waitFor(String email, {int after = 0}) async {
    for (var i = 0; i < 100; i++) {
      final found = mails.skip(after).where((m) => m.to.contains(email));
      if (found.isNotEmpty) return found.last;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    throw TimeoutException('no mail to $email');
  }

  /// The token in the first `<host>/<page>?token=…` link of [mail].
  static String? linkToken(Mail mail, String host, String page) =>
      RegExp('https://${RegExp.escape(host)}/$page\\?token=([A-Za-z0-9._-]+)')
          .firstMatch(mail.text)?[1];
}
