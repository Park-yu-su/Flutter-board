import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //widget의 레이아웃을 정의함
    return MaterialApp.router(
      routerConfig: router,
      title: 'Main page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
