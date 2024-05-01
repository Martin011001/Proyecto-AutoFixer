import 'package:aplicacion_taller/config/routes/app_router.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "AutoFix",
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
