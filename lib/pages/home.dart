import 'package:flutter/material.dart';
import 'package:subsonic_flutter/pages/login.dart';
import 'package:subsonic_flutter/domain/model/server.dart';

class MyHomePage extends StatefulWidget {
  static const String routeName = "/home";

  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(onPressed: () {

              Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
            }, child: const Text("Log out"))
          ],
        ),
      ),
    );
  }
}