import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/bank_store.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/round_repository.dart';
import 'package:number_ninja/data/sound_player.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/domain/quiz.dart';
import 'package:number_ninja/domain/topic_lock.dart';
import 'package:number_ninja/domain/topics.dart';
import 'package:number_ninja/features/quiz/quiz_controller.dart';
import 'package:number_ninja/features/quiz/quiz_screen.dart';
import 'package:number_ninja/features/screen_time/screen_time_controller.dart';
import 'package:number_ninja/providers.dart';

/// Topics of the fake bank, one format each.
const mcqTopic = 'p2.fractions';
const numberTopic = 'p2.money';
const dragTopic = 'p2.place';

/// 12 level-1 questions per format, with visuals on some.
QuestionBank fakeBank() => QuestionBank(
  version: 1,
  questions: [
    for (var i = 0; i < 12; i++) ...[
      Question(
        id: '$mcqTopic.t.${i + 1}',
        topic: mcqTopic,
        level: 1,
        format: QuestionFormat.mcq,
        prompt: 'Which is bigger? ($i)',
        options: const ['1/3', '1/5', '1/8', 'Equal'],
        answer: '1/3',
        explanation: 'Thirds are bigger pieces than fifths.',
        visual: const {'kind': 'fraction', 'parts': 3, 'shaded': 1},
      ),
      Question(
        id: '$numberTopic.t.${i + 1}',
        topic: numberTopic,
        level: 1,
        format: QuestionFormat.number,
        prompt: 'How much money is there in dollars? ($i)',
        answer: '3.60',
        explanation: r'$1 + $1 + $1 + 50¢ + 10¢ = $3.60',
        visual: const {
          'kind': 'coins',
          'cents': [100, 100, 100, 50, 10],
        },
      ),
      Question(
        id: '$dragTopic.t.${i + 1}',
        topic: dragTopic,
        level: 1,
        format: QuestionFormat.drag,
        prompt: 'Put the numbers in order, smallest first. ($i)',
        drag: const DragSpec(items: ['300', '103', '130', '31'], slots: 3),
        answer: const ['103', '130', '300'],
        explanation: '103 < 130 < 300',
      ),
    ],
  ],
);

/// Counts repository calls (AC-8).
class CountingRepository extends RoundRepository {
  CountingRepository(super.db, {required super.clock});

  int calls = 0;

  /// When set, saveAttempt waits for it before writing (AC-3).
  Completer<void>? gate;

  @override
  Future<int> startRound(
    String topicId,
    int level, {
    String kind = roundKindNormal,
  }) {
    calls++;
    return super.startRound(topicId, level, kind: kind);
  }

  @override
  Future<void> saveAttempt(int roundId, AnswerResult r) async {
    calls++;
    await gate?.future;
    return super.saveAttempt(roundId, r);
  }

  @override
  Future<void> finishRound(
    int roundId, {
    required int score,
    required int durationMs,
    required int stars,
  }) {
    calls++;
    return super.finishRound(
      roundId,
      score: score,
      durationMs: durationMs,
      stars: stars,
    );
  }

  @override
  Future<Set<String>> recentCorrectIds(String topicId, {int rounds = 3}) {
    calls++;
    return super.recentCorrectIds(topicId, rounds: rounds);
  }
}

/// An app with a PIN set, an in-memory database, a fake clock and a seeded
/// round order, on a 1280 × 800 dp landscape tablet by default.
/// Records sound effects instead of playing them (PRC-11, FEAT-09).
class RecordingSoundPlayer implements SoundPlayer {
  final played = <SoundEffect>[];
  bool fail = false;

  @override
  Future<void> play(SoundEffect effect) async {
    if (fail) throw StateError('no audio');
    played.add(effect);
  }
}

class QuizHarness {
  QuizHarness({QuestionBank? bank}) : bank = bank ?? fakeBank() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    repo = CountingRepository(db, clock: clock);
  }

  final QuestionBank bank;
  late final AppDatabase db;
  late final CountingRepository repo;
  DateTime now = DateTime(2027, 1, 5, 9);

  /// Where downloaded banks go (FEAT-15); a test that downloads sets a temp
  /// dir.
  Directory banksDir = Directory('${Directory.systemTemp.path}/nn-no-banks');
  DateTime clock() => now;

  void tick(Duration d) => now = now.add(d);

  /// Foreground time for the screen-time clock; it only moves when a test
  /// moves it, so other tests never lock (FEAT-05).
  Duration elapsed = Duration.zero;

  /// Moves both the clock and the elapsed source on by [d].
  void run(Duration d) {
    tick(d);
    elapsed += d;
  }

  final sounds = RecordingSoundPlayer();

  /// False (default): every topic is open, so tests reach any topic
  /// without seeding passes. True: the real FEAT-17 lock rules.
  bool lockTopics = false;

  /// True: [bankProvider] comes from the bank store (bundled = [bank]),
  /// as in the app, so a download can replace it (FEAT-15).
  bool useBankStore = false;

  /// FEAT-25: the app starts on SCR-17 ([AppSession.choosingChild]) and
  /// with child [startChild]. Rounds still go through [repo] (child 1).
  bool choosingChild = false;
  int startChild = 1;

  /// The app session; null = setup finished, child from [choosingChild]
  /// (FEAT-26 setup tests pass their own).
  AppSession? session;

  /// FEAT-30 (PD-12): whether the family has Plus at launch. True keeps the
  /// tests from before Plus as they were; free-tier tests set false.
  bool plus = true;

  /// FEAT-36: true leaves `plusProvider` to the real Plus cache (a test
  /// that redeems a code and checks Plus features open); [plus] is ignored.
  bool realPlus = false;

  /// Turns Plus on or off in a running app.
  void setPlus(WidgetTester tester, bool on) =>
      container(tester).read(_plusSwitch.notifier).set(on);

  /// More overrides for one test, added after the defaults.
  List<Override> more = [];

  List<Override> get overrides => [
    databaseProvider.overrideWithValue(db),
    clockProvider.overrideWithValue(clock),
    if (!useBankStore) bankProvider.overrideWith((ref) => bank),
    // FEAT-15: the bundled bank is [bank]; no downloads (no file IO).
    bankStoreProvider.overrideWithValue(
      BankStore(db, bundle: MemoryBankBundle(bank), dir: () async => banksDir),
    ),
    roundRepositoryProvider.overrideWithValue(repo),
    quizRandomProvider.overrideWith((ref) => Random(42)),
    elapsedProvider.overrideWithValue(() => elapsed),
    soundPlayerProvider.overrideWithValue(sounds),
    appSessionProvider.overrideWithValue(
      session ?? AppSession(clock: clock, choosingChild: choosingChild),
    ),
    startChildProvider.overrideWithValue(startChild),
    _plusSwitch.overrideWith(() => _PlusSwitch(plus)),
    if (!realPlus) plusProvider.overrideWith((ref) => ref.watch(_plusSwitch)),
    if (!lockTopics)
      topicLocksProvider.overrideWith(
        (ref) async => {
          for (final t in topics) t.id: const TopicOpen(OpenReason.first),
        },
      ),
    ...more,
  ];

  Future<void> pumpApp(
    WidgetTester tester, {
    String? location,
    Size size = const Size(2560, 1600),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const NumberNinjaApp()),
    );
    await tester.pumpAndSettle();
    if (location != null) {
      container(tester).read(routerProvider).go(location);
      await tester.pumpAndSettle();
    }
  }

  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(NumberNinjaApp)));

  RoundState round(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(QuizScreen)))
          .read(quizControllerProvider);

  Question current(WidgetTester tester) => round(tester).quiz!.current;

  /// Taps [key], scrolling it into view first: with the test font (Ahem,
  /// wider than Roboto) a long answer area can need its scroll view.
  Future<void> tap(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.tap(find.byKey(Key(key)));
    await tester.pump();
  }

  /// Answers the current question on screen, right or wrong, and leaves
  /// the feedback showing.
  Future<void> answer(WidgetTester tester, {required bool right}) async {
    final q = current(tester);
    switch (q.format) {
      case QuestionFormat.mcq:
        final i = q.options!.indexOf(q.answer as String);
        await tap(tester, 'option-${right ? i : (i + 1) % q.options!.length}');
      case QuestionFormat.number:
        final text = right ? q.answer as String : '9';
        for (final c in text.split('')) {
          await tap(tester, 'key-${c == '.' ? 'dot' : c}');
        }
        await tap(tester, 'check');
      case QuestionFormat.drag:
        final want = q.answer as List<String>;
        final order = right ? want : want.reversed.toList();
        final used = <int>{};
        for (final item in order) {
          var i = -1;
          do {
            i = q.drag!.items.indexOf(item, i + 1);
          } while (used.contains(i));
          used.add(i);
          await tap(tester, 'chip-$i');
        }
        await tap(tester, 'check');
    }
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('next')));
    await tester.pumpAndSettle();
  }
}

/// An asset bundle that serves [bank] as the bundled bank (FEAT-15).
class MemoryBankBundle extends CachingAssetBundle {
  MemoryBankBundle(QuestionBank bank) : text = jsonEncode(bank.toJson());
  final String text;

  @override
  Future<String> loadString(String key, {bool cache = true}) async => text;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(text)));
}

final _plusSwitch = NotifierProvider<_PlusSwitch, bool>(
  () => _PlusSwitch(true),
);

class _PlusSwitch extends Notifier<bool> {
  _PlusSwitch(this._start);
  final bool _start;

  @override
  bool build() => _start;

  void set(bool on) => state = on;
}
