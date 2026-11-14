import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const NumberNinjaApp());
}

class NumberNinjaApp extends StatelessWidget {
  const NumberNinjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Number Ninja',
      home: Scaffold(body: Center(child: Text('Number Ninja'))),
    );
  }
}
