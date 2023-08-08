import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:subsonic_flutter/domain/model/PlaylistArguments.dart';
import 'package:subsonic_flutter/domain/model/song.dart';
import 'package:subsonic_flutter/domain/model/subsonic_error.dart';
import 'package:subsonic_flutter/infrastructure/repository/music_repository.dart';
import 'package:subsonic_flutter/widgets/LoadingDataError.dart';
import 'package:subsonic_flutter/widgets/loading_animation.dart';
import 'package:subsonic_flutter/widgets/music_player.dart';

class PlaylistPage extends StatefulWidget {
  static const String routeName = "/playlist";

  const PlaylistPage({super.key});

  @override
  State<StatefulWidget> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final _musicRepository = MusicRepository();
  fp.Either<SubsonicError, bool> _isFetchingData = const fp.Right(true);

  _PlaylistPageState() {
    _refreshPlaylist();
  }

  Future<void> _refreshPlaylist() async {
    // TODO
  }

  Widget _buildPlaylist(List<Song> songs) {
    return RefreshIndicator(
      onRefresh: _refreshPlaylist,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            ListView(
              shrinkWrap: true,
              children: [],  // TODO
            ),
            const MusicPlayer(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as PlaylistArguments;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(args.title),
      ),
      body: Center(
        child: _isFetchingData.match(
          (error) => LoadingDataError(error: error),
          (state) {
            if (state) {
              return const LoadingAnimation(sourceName: "playlist");
            } else {
              return _buildPlaylist([]);  // TODO
            }
          },
        ),
      ),
    );
  }
}
