import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/main.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const NumberNinjaApp());
    expect(find.text('Number Ninja'), findsOneWidget);
  });
}
