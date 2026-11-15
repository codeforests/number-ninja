/// Tracks and topics (design §2). Topic ids are permanent.
enum Track { p1, p2, olympiad }

class Topic {
  const Topic(this.id, this.track, this.name);

  final String id;
  final Track track;
  final String name;
}

const topics = <Topic>[
  Topic('p1.place', Track.p1, 'Numbers to 100'),
  Topic('p1.bonds', Track.p1, 'Number bonds'),
  Topic('p1.groups', Track.p1, 'Equal groups'),
  Topic('p1.money', Track.p1, 'Money'),
  Topic('p1.time', Track.p1, 'Telling time'),
  Topic('p1.measure', Track.p1, 'Length and mass'),
  Topic('p1.shapes', Track.p1, 'Shapes and patterns'),
  Topic('p1.graphs', Track.p1, 'Picture graphs'),
  Topic('p2.place', Track.p2, 'Numbers to 1000'),
  Topic('p2.regroup', Track.p2, 'Add and subtract with regrouping'),
  Topic('p2.times', Track.p2, 'Times tables'),
  Topic('p2.divide', Track.p2, 'Division'),
  Topic('p2.fractions', Track.p2, 'Fractions'),
  Topic('p2.measure', Track.p2, 'Length, mass and volume'),
  Topic('p2.money', Track.p2, 'Money and change'),
  Topic('p2.time', Track.p2, 'Time'),
  Topic('p2.shapes', Track.p2, '2D and 3D shapes'),
  Topic('p2.graphs', Track.p2, 'Picture graphs with scales'),
  Topic('p2.words', Track.p2, 'Word problems'),
  Topic('oly.patterns', Track.olympiad, 'Patterns'),
  Topic('oly.logic', Track.olympiad, 'Logic puzzles'),
  Topic('oly.counting', Track.olympiad, 'Counting'),
  Topic('oly.models', Track.olympiad, 'Model drawing'),
];

final topicsById = {for (final t in topics) t.id: t};
