import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:subsonic_flutter/domain/model/playlist_arguments.dart';
import 'package:subsonic_flutter/domain/model/song.dart';
import 'package:subsonic_flutter/domain/model/subsonic_error.dart';
import 'package:subsonic_flutter/infrastructure/repository/music_repository.dart';
import 'package:subsonic_flutter/infrastructure/time_utils.dart';
import 'package:subsonic_flutter/properties.dart';
import 'package:subsonic_flutter/widgets/loading_animation.dart';
import 'package:subsonic_flutter/widgets/loading_data_error.dart';
import 'package:subsonic_flutter/widgets/music_player.dart';
import 'package:subsonic_flutter/widgets/subsonic_card.dart';

class PlaylistPage extends StatefulWidget {
  static const String routeName = "/playlist";

  const PlaylistPage({super.key});

  @override
  State<StatefulWidget> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final _musicRepository = getIt<MusicRepository>();
  fp.Either<SubsonicError, bool> _isFetchingData = const fp.Right(false);

  Future<void> _refreshPlaylist(String id) async {
    setState(() {
      _isFetchingData = const fp.Right(true);
    });

    _musicRepository.fetchSinglePlaylist(id).then((value) {
      value.match((error) {
        _isFetchingData = fp.Left(error);
        setState(() {});
      }, (_) {
        _isFetchingData = const fp.Right(false);
        setState(() {});
      });
    });
  }

  Widget _buildPlaylist(String playlistId, List<Song> songs) {
    List<Widget> children = [];

    for (int index = 0; index < songs.length; index++) {
      final coverArtIdOrPlaylistId = songs[index].coverArtId ?? playlistId;

      children.add(SubsonicCard(
        title: songs[index].title,
        imageUrl: _musicRepository.getCoverArtUrlFor(
          coverArtIdOrPlaylistId,
          null,
        ),
        cacheKey: coverArtIdOrPlaylistId,
        content: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(songs[index].album),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(formattedDurationWithHours(songs[index].durationSeconds)),
            ],
          ),
        ],
        onTap: () => _musicRepository.playSong(songs[index]),
        isThreeLines: true,
      ));
    }

    children.add(Container(height: 200));

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isFetchingData = const fp.Right(true);
        });
        await _refreshPlaylist(playlistId);
      },
      child: Stack(
        children: [
          ListView(
            shrinkWrap: true,
            children: children,
          ),
          const MusicPlayer(),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(String playlistId) {
    List<Widget> actions = [];

    if (_musicRepository.hasBookmark(playlistId)) {
      final bookmark = _musicRepository.getBookmark(playlistId);

      actions.add(
        IconButton(
          onPressed: () => _musicRepository.playPlaylistStartingFrom(playlistId, bookmark!.songId, bookmark.songPositionSeconds),
          tooltip: "Resume listening to bookmark",
          icon: const Icon(Icons.play_lesson_outlined),
        ),
      );
    }

    actions.add(
      IconButton(
        onPressed: () => _musicRepository.playPlaylist(playlistId),
        tooltip: "Start listening",
        icon: const Icon(Icons.playlist_play),
      ),
    );

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as PlaylistArguments;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(args.playlist.name),
        actions: _buildActionButtons(args.playlist.id),
      ),
      body: Center(
        child: _isFetchingData.match(
          (error) => LoadingDataError(error: error),
          (state) {
            if (state) {
              return const LoadingAnimation(sourceName: "playlist");
            } else {
              return _buildPlaylist(
                args.playlist.id,
                _musicRepository.playlist(args.playlist.id),
              );
            }
          },
        ),
      ),
    );
  }
}
