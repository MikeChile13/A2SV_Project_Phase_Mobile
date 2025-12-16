import 'package:flutter/material.dart';
import 'home_page.dart';
import 'details_page.dart';
import 'search_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '4 Page App',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueGrey[900],
        colorScheme: ThemeData.dark().colorScheme.copyWith(
          primary: Colors.blueAccent,
          secondary: Colors.blueAccent,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent,
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomePage(),
        // details route is not registered because it requires a `Product` argument;
        // navigation to DetailsPage uses MaterialPageRoute with the product instance.
        '/search': (context) => const SearchPage(),
      },
    );
  }
}
