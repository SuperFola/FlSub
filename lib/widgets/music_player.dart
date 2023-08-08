import 'package:flutter/material.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<StatefulWidget> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  @override
  Widget build(BuildContext context) {
    return const Positioned(
      bottom: 0,
      child: Card(
        child: Center(child: Text('Elevated Card')),
      ),
    );
  }
}