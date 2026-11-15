import 'generator.dart';

/// Hand-written Olympiad questions. Ids come from the position within each
/// topic (`oly.logic.hw.001`, ...), so only ever append to this list; never
/// reorder or delete (BNK-05). Figures are drawn by FEAT-03 from
/// `figure {name}`; the names are listed in README.md.
final handwritten = <Handwritten>[
  // oly.logic
  Handwritten(
    'oly.logic',
    2,
    (r) => Draft.number(
      'I am a 2-digit number. My tens digit is 3 more than my ones digit. '
      'My two digits add up to 9. What number am I?',
      63,
      explanation:
          'Try pairs that add up to 9: 6 and 3 differ by 3. '
          'The tens digit is the bigger one, so the number is 63.',
    ),
  ),
  Handwritten(
    'oly.logic',
    1,
    (r) => Draft.mcq(
      r,
      'Mei, Ravi and Siti each have one pet: a cat, a dog or a fish. '
          'Mei does not have the cat or the dog. Ravi does not have the cat. '
          'Who has the cat?',
      'Siti',
      ['Mei', 'Ravi'],
      explanation:
          'Mei has neither the cat nor the dog, so Mei has the fish. Ravi does '
          'not have the cat, so Ravi has the dog. Siti has the cat.',
    ),
  ),
  Handwritten(
    'oly.logic',
    3,
    (r) => Draft.number(
      'A frog is at the bottom of a well 10 m deep. Each day it climbs up '
      '3 m, and each night it slips back 2 m. On which day does it reach '
      'the top?',
      8,
      explanation:
          'Each day and night it goes up 1 m. After 7 days and nights it is at '
          '7 m. On day 8 it climbs 3 m to reach 10 m, so it does not slip back.',
    ),
  ),
  Handwritten(
    'oly.logic',
    1,
    (r) => Draft.mcq(
      r,
      'Today is Monday. What day of the week will it be 10 days from today?',
      'Thursday',
      ['Wednesday', 'Friday', 'Tuesday'],
      explanation:
          '7 days from Monday is Monday again. 3 more days is Thursday.',
    ),
  ),
  Handwritten(
    'oly.logic',
    2,
    (r) => Draft.number(
      'I think of a number. I add 5, then double the answer. I get 24. '
      'What number did I think of?',
      7,
      check: '24/2-5',
      explanation: 'Work backwards: half of 24 is 12, and 12 − 5 = 7.',
    ),
  ),
  Handwritten(
    'oly.logic',
    2,
    (r) => Draft.number(
      'Mei eats half of a box of cookies. Ravi eats 3 cookies. '
      '2 cookies are left. How many cookies were in the box at first?',
      10,
      check: '(3+2)*2',
      explanation:
          'After Mei ate, 3 + 2 = 5 cookies were left. That is half the box, '
          'so the box had 5 × 2 = 10.',
    ),
  ),
  Handwritten(
    'oly.logic',
    2,
    (r) => Draft.mcq(
      r,
      'In a race, Siti finished ahead of Jun Wei. Aisha finished behind '
          'Jun Wei. Ben finished ahead of Siti. Who came third?',
      'Jun Wei',
      ['Ben', 'Siti', 'Aisha'],
      explanation:
          'The order is Ben, Siti, Jun Wei, Aisha. Jun Wei came third.',
    ),
  ),
  Handwritten(
    'oly.logic',
    3,
    (r) => Draft.number(
      'There are 31 children in a class. There are 5 more boys than girls. '
      'How many girls are there?',
      13,
      check: '(31-5)/2',
      explanation:
          'Take away the 5 extra boys: 31 − 5 = 26. Then there are as many boys '
          'as girls: 26 ÷ 2 = 13 girls.',
    ),
  ),
  Handwritten(
    'oly.logic',
    3,
    (r) => Draft.number(
      'A spider has 8 legs and a beetle has 6 legs. 3 spiders and some '
      'beetles have 48 legs in all. How many beetles are there?',
      4,
      check: '(48-3*8)/6',
      explanation:
          'The spiders have 3 × 8 = 24 legs. 48 − 24 = 24 legs are beetle '
          'legs: 24 ÷ 6 = 4 beetles.',
    ),
  ),
  Handwritten(
    'oly.logic',
    1,
    (r) => Draft.mcq(
      r,
      'Which number does not belong: 12, 18, 24, 27, 30?',
      27,
      [18, 24, 30],
      explanation: '27 is the only odd number. The others are all even.',
    ),
  ),
  Handwritten(
    'oly.logic',
    2,
    (r) => Draft.number(
      'Mei is 6th in a line counting from the front, and 4th counting from '
      'the back. How many children are in the line?',
      9,
      check: '6+4-1',
      explanation:
          '6 + 4 = 10 counts Mei twice, so there are 10 − 1 = 9 children.',
    ),
  ),
  Handwritten(
    'oly.logic',
    1,
    (r) => Draft.number(
      'A ribbon is cut into 5 pieces. How many cuts are made?',
      4,
      check: '5-1',
      explanation:
          'The first cut makes 2 pieces. Each cut adds 1 piece: 4 cuts.',
    ),
  ),
  Handwritten(
    'oly.logic',
    3,
    (r) => Draft.number(
      'There are 10 trees in a row. Each tree is 2 m from the next one. '
      'How far is the first tree from the last tree, in m?',
      18,
      check: '(10-1)*2',
      explanation: '10 trees have 9 gaps between them: 9 × 2 = 18 m.',
    ),
  ),
  Handwritten(
    'oly.logic',
    3,
    (r) => Draft.number(
      'Ravi has 6 coins. Some are 5¢ coins and the rest are 10¢ coins. '
      'They are worth 45¢ in all. How many 10¢ coins does he have?',
      3,
      check: '(45-6*5)/5',
      explanation:
          'If all 6 were 5¢ coins, he would have 30¢. He has 15¢ more. Each '
          '10¢ coin adds 5¢, so there are 15 ÷ 5 = 3 of them.',
    ),
  ),
  Handwritten(
    'oly.logic',
    2,
    (r) => Draft.mcq(
      r,
      'Jun Wei is older than Ben. Ben is older than Daniel. Daniel is older '
          'than Ahmad. Who is the second youngest?',
      'Daniel',
      ['Jun Wei', 'Ben', 'Ahmad'],
      explanation:
          'From youngest to oldest: Ahmad, Daniel, Ben, Jun Wei. '
          'The second youngest is Daniel.',
    ),
  ),

  // oly.counting
  Handwritten(
    'oly.counting',
    2,
    (r) => Draft.number(
      'How many triangles can you see in the picture?',
      6,
      visual: {'kind': 'figure', 'name': 'triangle-split-3'},
      check: '3+2+1',
      explanation:
          'There are 3 small triangles, 2 made of two small ones, and 1 big '
          'one: 3 + 2 + 1 = 6.',
    ),
  ),
  Handwritten(
    'oly.counting',
    2,
    (r) => Draft.number(
      'How many triangles can you see in the picture?',
      8,
      visual: {'kind': 'figure', 'name': 'square-diagonals'},
      check: '4+4',
      explanation:
          'There are 4 small triangles, and 4 big ones that are each half of '
          'the square: 4 + 4 = 8.',
    ),
  ),
  Handwritten(
    'oly.counting',
    1,
    (r) => Draft.number(
      'How many squares can you see in the picture?',
      5,
      visual: {'kind': 'figure', 'name': 'grid-2x2'},
      check: '4+1',
      explanation: '4 small squares and 1 big square: 5.',
    ),
  ),
  Handwritten(
    'oly.counting',
    3,
    (r) => Draft.number(
      'How many squares can you see in the picture?',
      14,
      visual: {'kind': 'figure', 'name': 'grid-3x3'},
      check: '9+4+1',
      explanation:
          '9 small squares, 4 squares of 2 by 2, and 1 big square: '
          '9 + 4 + 1 = 14.',
    ),
  ),
  Handwritten(
    'oly.counting',
    3,
    (r) => Draft.number(
      'How many rectangles can you see in the picture? '
      '(Squares count as rectangles too.)',
      18,
      visual: {'kind': 'figure', 'name': 'grid-2x3'},
      check: '3*6',
      explanation:
          'Each row alone has 6 rectangles, and so does the 2-row strip: '
          '6 + 6 + 6 = 18.',
    ),
  ),
  Handwritten(
    'oly.counting',
    3,
    (r) => Draft.number(
      'How many numbers from 1 to 50 have the digit 3 in them?',
      14,
      check: '4+10',
      explanation:
          '3, 13, 23 and 43 have a 3 in the ones place (4 numbers), and 30 to '
          '39 have a 3 in the tens place (10 numbers). 4 + 10 = 14.',
    ),
  ),
  Handwritten(
    'oly.counting',
    2,
    (r) => Draft.number(
      'You write the numbers from 1 to 20. How many times do you write the '
      'digit 1?',
      12,
      check: '1+10+1',
      explanation:
          '1 has one 1. 10 to 19 each have a 1 in the tens place (10), and 11 '
          'has another in the ones place. 1 + 10 + 1 = 12.',
    ),
  ),
  Handwritten(
    'oly.counting',
    1,
    (r) => Draft.number(
      'Mei, Ravi and Siti stand in a line for a photo. In how many different '
      'orders can they stand?',
      6,
      check: '3*2*1',
      explanation:
          '3 children can be first, then 2 can be second, then 1 is last: '
          '3 × 2 × 1 = 6.',
    ),
  ),
  Handwritten(
    'oly.counting',
    1,
    (r) => Draft.number(
      'How many different ways can you make 20¢ using only 5¢ and 10¢ coins?',
      3,
      explanation:
          'Two 10¢ coins; one 10¢ and two 5¢ coins; or four 5¢ coins: 3 ways.',
    ),
  ),
  Handwritten(
    'oly.counting',
    2,
    (r) => Draft.number(
      'There are 4 dots, and no 3 of them are on one straight line. How many '
      'straight lines can you draw, each joining 2 of the dots?',
      6,
      check: '4*3/2',
      explanation:
          'Each dot joins to 3 others: 4 × 3 = 12. Each line is counted twice, '
          'so 12 ÷ 2 = 6.',
    ),
  ),
  Handwritten(
    'oly.counting',
    1,
    (r) => Draft.number(
      'How many even numbers are there from 11 to 31?',
      10,
      check: '(30-12)/2+1',
      explanation: 'They are 12, 14, 16, ..., 30. Count them: 10.',
    ),
  ),
  Handwritten(
    'oly.counting',
    3,
    (r) => Draft.number(
      'How many 3-digit numbers have digits that add up to 3?',
      6,
      explanation: 'They are 102, 111, 120, 201, 210 and 300: 6 numbers.',
    ),
  ),
  Handwritten(
    'oly.counting',
    2,
    (r) => Draft.number(
      '2 class monitors are chosen from 5 children. How many different pairs '
      'of monitors are possible?',
      10,
      check: '5*4/2',
      explanation:
          'Each child can pair with 4 others: 5 × 4 = 20. Each pair is counted '
          'twice, so 20 ÷ 2 = 10.',
    ),
  ),
  Handwritten(
    'oly.counting',
    2,
    (r) => Draft.number(
      'A clock chimes once at 1 o\'clock, twice at 2 o\'clock, and so on. '
      'How many times does it chime from 1 o\'clock to 6 o\'clock?',
      21,
      check: '1+2+3+4+5+6',
      explanation: '1 + 2 + 3 + 4 + 5 + 6 = 21.',
    ),
  ),
  Handwritten(
    'oly.counting',
    1,
    (r) => Draft.number(
      'How many numbers from 1 to 30 can be divided by 3 exactly?',
      10,
      check: '30/3',
      explanation: 'They are 3, 6, 9, ..., 30: 30 ÷ 3 = 10 numbers.',
    ),
  ),
];
