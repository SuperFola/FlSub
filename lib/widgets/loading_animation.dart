import 'package:flutter/material.dart';

class LoadingAnimation extends StatelessWidget {
  final String sourceName;

  const LoadingAnimation({super.key, required this.sourceName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Fetching $sourceName...'),
            ),
          ],
        ),
      ),
    );
  }
}