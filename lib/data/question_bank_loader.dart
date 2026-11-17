import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/question.dart';

const bankAsset = 'assets/questions/bank.json';

/// Reads and parses the bundled question bank (BNK-01).
Future<QuestionBank> loadBank(AssetBundle bundle) async {
  final text = await bundle.loadString(bankAsset);
  return QuestionBank.fromJson(jsonDecode(text) as Map<String, dynamic>);
}
