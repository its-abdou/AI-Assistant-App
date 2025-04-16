import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Test'),
          centerTitle: true,
        ),
        body: Center(
          child: Image.asset("assets/images/test.jpeg"),
        ),
      ),
    );
  }
}


