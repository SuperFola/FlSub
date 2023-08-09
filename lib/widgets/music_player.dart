import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'package:subsonic_flutter/domain/model/position_data.dart';
import 'package:subsonic_flutter/infrastructure/repository/music_repository.dart';
import 'package:subsonic_flutter/properties.dart';
import 'package:subsonic_flutter/widgets/music_player/seek_bar.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<StatefulWidget> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  AudioPlayer get _player => getIt<AudioPlayer>();

  MusicRepository get _musicRepository => getIt<MusicRepository>();

  Widget _buildPlayButton() {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        const iconSize = 24.0;

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return FloatingActionButton(
            onPressed: () {},
            elevation: 0,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return FloatingActionButton(
            elevation: 0,
            onPressed: _player.play,
            child: const Icon(Icons.play_arrow_outlined, size: iconSize),
          );
        } else if (processingState != ProcessingState.completed) {
          return FloatingActionButton(
            onPressed: () {
              // try and make a bookmark before stopping
              _musicRepository.makeBookmarkForCurrentAudioSource();
              _player.pause();
            },
            elevation: 0,
            child: const Icon(Icons.pause, size: iconSize),
          );
        } else {
          return FloatingActionButton(
            elevation: 0,
            onPressed: () => _player.seek(
              Duration.zero,
              index: _player.effectiveIndices!.first,
            ),
            child: const Icon(Icons.replay),
          );
        }
      },
    );
  }

  Widget _buildLoopButton() {
    return StreamBuilder<LoopMode>(
      stream: _player.loopModeStream,
      builder: (context, snapshot) {
        final loopMode = snapshot.data ?? LoopMode.off;
        var icons = [
          const Icon(Icons.repeat, color: Colors.white54),
          Icon(Icons.repeat, color: Theme.of(context).colorScheme.primary),
          Icon(Icons.repeat_one, color: Theme.of(context).colorScheme.primary),
        ];
        const cycleModes = [
          LoopMode.off,
          LoopMode.all,
          LoopMode.one,
        ];
        final index = cycleModes.indexOf(loopMode);
        return IconButton(
          icon: icons[index],
          onPressed: () {
            _player.setLoopMode(cycleModes[
                (cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
          },
        );
      },
    );
  }

  Widget _buildRandomButton() {
    return StreamBuilder<bool>(
      stream: _player.shuffleModeEnabledStream,
      builder: (context, snapshot) {
        final shuffleModeEnabled = snapshot.data ?? false;
        return IconButton(
          icon: shuffleModeEnabled
              ? Icon(Icons.shuffle,
                  color: Theme.of(context).colorScheme.primary)
              : const Icon(Icons.shuffle, color: Colors.white54),
          onPressed: () async {
            final enable = !shuffleModeEnabled;
            if (enable) {
              await _player.shuffle();
            }
            await _player.setShuffleModeEnabled(enable);
          },
        );
      },
    );
  }

  Widget _buildControls(BuildContext context) {
    return StreamBuilder<SequenceState?>(
      stream: _player.sequenceStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state?.sequence.isEmpty ?? true) {
          return const SizedBox();
        }
        final metadata = state!.currentSource!.tag as MediaItem;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: CachedNetworkImageProvider(metadata.artUri.toString()),
              fit: BoxFit.cover,
            ),
          ),
          child: Card(
            color: Colors.transparent,
            shadowColor: Colors.grey,
            elevation: 0.1,
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              metadata.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              metadata.album ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _buildLoopButton(),
                          _buildRandomButton(),
                          _buildPlayButton(),
                        ],
                      ),
                    ],
                  ),
                  StreamBuilder<PositionData>(
                    stream: _positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      return SeekBar(
                        player: _player,
                        duration: positionData?.duration ?? Duration.zero,
                        position: positionData?.position ?? Duration.zero,
                        bufferedPosition:
                            positionData?.bufferedPosition ?? Duration.zero,
                        onChangeEnd: (newPosition) {
                          _player.seek(newPosition);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildControls(context),
        ),
      ),
    );
  }
}
