import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SeekBar extends StatefulWidget {
  final AudioPlayer player;
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    Key? key,
    required this.player,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
  }) : super(key: key);

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
      secondaryActiveTrackColor: Colors.blue.shade300,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: StreamBuilder<SequenceState?>(
            stream: widget.player.sequenceStateStream,
            builder: (context, snapshot) => IconButton(
              icon: Icon(
                Icons.skip_previous_outlined,
                color: widget.player.hasPrevious ? Colors.white : Colors.white38,
              ),
              onPressed:
                  widget.player.hasPrevious ? widget.player.seekToPrevious : null,
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Stack(
            children: [
              SliderTheme(
                data: _sliderThemeData,
                child: Slider(
                  min: 0.0,
                  max: widget.duration.inMilliseconds.toDouble(),
                  value: min(
                      _dragValue ?? widget.position.inMilliseconds.toDouble(),
                      widget.duration.inMilliseconds.toDouble()),
                  secondaryTrackValue: min(widget.bufferedPosition.inMilliseconds.toDouble(),
                      widget.duration.inMilliseconds.toDouble()),
                  onChanged: (value) {
                    setState(() {
                      _dragValue = value;
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!(Duration(milliseconds: value.round()));
                    }
                  },
                  onChangeEnd: (value) {
                    if (widget.onChangeEnd != null) {
                      widget.onChangeEnd!(Duration(milliseconds: value.round()));
                    }
                    _dragValue = null;
                  },
                ),
              ),
              Positioned(
                right: 16.0,
                bottom: 0.0,
                child: Text(
                    RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                            .firstMatch("$_remaining")
                            ?.group(1) ??
                        '$_remaining',
                    style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: StreamBuilder<SequenceState?>(
            stream: widget.player.sequenceStateStream,
            builder: (context, snapshot) => IconButton(
              icon: Icon(
                Icons.skip_next_outlined,
                color: widget.player.hasNext ? Colors.white : Colors.white38,
              ),
              onPressed: widget.player.hasNext ? widget.player.seekToNext : null,
            ),
          ),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}
