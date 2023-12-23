import 'package:flutter/material.dart';
import 'articles.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strapi Articles',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ArticlesPage(),  // Directly use ArticlesPage
    );
  }
}
