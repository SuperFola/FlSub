import 'package:flutter/material.dart';
import 'package:subsonic_flutter/domain/model/subsonic_error.dart';

class LoadingDataError extends StatelessWidget {
  final SubsonicError error;

  const LoadingDataError({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(error.message),
            ),
          ],
        ),
      ),
    );
  }
}
