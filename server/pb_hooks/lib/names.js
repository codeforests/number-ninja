// FEAT-31 (WE-8): topic and badge names for the weekly email, copied from
// lib/domain/topics.dart and lib/domain/badges.dart. The app test
// test/tool/server_names_test.dart fails when they differ: a new topic or
// badge updates both files. One entry per line: the test reads them.
const TOPICS = {
  "p1.place": "Numbers to 100",
  "p1.bonds": "Number bonds",
  "p1.groups": "Equal groups",
  "p1.money": "Money",
  "p1.time": "Telling time",
  "p1.measure": "Length and mass",
  "p1.shapes": "Shapes and patterns",
  "p1.graphs": "Picture graphs",
  "p2.place": "Numbers to 1000",
  "p2.regroup": "Add and subtract",
  "p2.times": "Times tables",
  "p2.divide": "Division",
  "p2.fractions": "Fractions",
  "p2.measure": "Length, mass and volume",
  "p2.money": "Money and change",
  "p2.time": "Time",
  "p2.shapes": "2D and 3D shapes",
  "p2.graphs": "Picture graphs with scales",
  "p2.words": "Word problems",
  "oly.patterns": "Patterns",
  "oly.logic": "Logic puzzles",
  "oly.counting": "Counting",
  "oly.models": "Model drawing",
};

const BADGES = {
  "first-round": "First Round",
  "perfect-10": "Perfect 10",
  "streak-3": "3-Day Streak",
  "streak-7": "7-Day Streak",
  "streak-30": "30-Day Streak",
  "questions-100": "100 Questions",
  "questions-500": "500 Questions",
  "speedy": "Speedy",
  "times-hero": "Times Table Hero",
  "division-dojo": "Division Dojo",
  "fraction-friend": "Fraction Friend",
  "money-master": "Money Master",
  "time-keeper": "Time Keeper",
  "shape-spotter": "Shape Spotter",
  "pattern-finder": "Pattern Finder",
  "puzzle-master": "Puzzle Master",
  "counting-star": "Counting Star",
  "bar-model-builder": "Bar Model Builder",
  "school-explorer": "School Explorer",
  "ninja-master": "Bubble Master",
};

module.exports = { TOPICS, BADGES };
