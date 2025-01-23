import 'package:flutter/material.dart';
import 'view/home_page.dart';
import 'controller/github_controller.dart';

void main() {
  const String githubToken = 'token';
  const String repoOwner = 'sddrouet';
  const String repoName = 'examen_u2_moviles';

  final controller = GitHubController(
    token: githubToken,
    repoOwner: repoOwner,
    repoName: repoName,
  );

  runApp(MyApp(controller: controller));
}

class MyApp extends StatelessWidget {
  final GitHubController controller;

  const MyApp({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Vegetales',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.greenAccent, // Fondo verde claro
        appBarTheme: const AppBarTheme(
          color: Colors.green, // Barra de app con verde
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: HomePage(controller: controller),
    );
  }
}
