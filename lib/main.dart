import 'package:flutter/material.dart';

import 'app/presentation/views/number_trivia_view.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  // needed because of the async main
  WidgetsFlutterBinding.ensureInitialized();

  // initialize the injection container
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Trivia',
      theme: ThemeData(
        primaryColor: Colors.green.shade800,
        accentColor: Colors.green.shade600,
      ),
      home: const NumberTriviaView(),
    );
  }
}
