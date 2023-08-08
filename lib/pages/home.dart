import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:subsonic_flutter/domain/model/PlaylistArguments.dart';
import 'package:subsonic_flutter/domain/model/playlist.dart';
import 'package:subsonic_flutter/domain/model/subsonic_error.dart';
import 'package:subsonic_flutter/infrastructure/repository/music_repository.dart';
import 'package:subsonic_flutter/pages/playlist.dart';
import 'package:subsonic_flutter/widgets/LoadingDataError.dart';
import 'package:subsonic_flutter/widgets/loading_animation.dart';
import 'package:subsonic_flutter/widgets/music_player.dart';
import 'package:subsonic_flutter/widgets/subsonic_card.dart';

class MyHomePage extends StatefulWidget {
  static const String routeName = "/home";
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _musicRepository = MusicRepository();
  fp.Either<SubsonicError, bool> _isFetchingData = const fp.Right(true);

  _MyHomePageState() {
    _refreshPlaylists();
  }

  Future<void> _refreshPlaylists() async {
    _musicRepository.fetchPlaylists().then((value) {
      value.match((error) {
        _isFetchingData = fp.Left(error);
        setState(() {});
      }, (_) {
        _isFetchingData = const fp.Right(false);
        setState(() {});
      });
    });
  }

  Widget _buildPlaylists(List<Playlist> playlists) {
    var children = List<Widget>.empty(growable: true);
    for (int index = 0; index < playlists.length; index++) {
      children.add(SubsonicCard(
        title: playlists[index].name,
        imageUrl: _musicRepository.getCoverArtUrlFor(playlists[index].id, null),
        content: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(playlists[index].songCount.toString()),
              const Icon(Icons.my_library_music_outlined),
              Text(playlists[index].formattedDuration),
              const Icon(Icons.timer_outlined),
            ],
          ),
        ],
        onTap: () => Navigator.of(context).pushNamed(PlaylistPage.routeName,
            arguments: PlaylistArguments(playlists[index])),
      ));
    }

    children.add(Container(height: 200));

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isFetchingData = const fp.Right(true);
        });
        await _refreshPlaylists();
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        // FIXME: this adds weird blank spaces at the top and bottom that crops the content
        child: Stack(
          children: [
            ListView(
              shrinkWrap: true,
              children: children,
            ),
            const MusicPlayer(),
          ],
        ),
      ),
    );
  }

  void _onFilterPlaylistsChanged(PlaylistsSort? value, StateSetter myState) {
    myState(() {
      _musicRepository.sortPlaylistsBy(value ?? PlaylistsSort.alphabetical);
    });
    setState(() {});
  }

  void _showModelFilterPlaylist(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter myState) {
            return SizedBox(
              height: 200,
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Alphabetical'),
                    leading: Radio<PlaylistsSort>(
                      value: PlaylistsSort.alphabetical,
                      groupValue: _musicRepository.playlistSort,
                      onChanged: (PlaylistsSort? value) =>
                          _onFilterPlaylistsChanged(value, myState),
                    ),
                  ),
                  ListTile(
                    title: const Text('Reversed alphabetical'),
                    leading: Radio<PlaylistsSort>(
                      value: PlaylistsSort.reverseAlphabetical,
                      groupValue: _musicRepository.playlistSort,
                      onChanged: (PlaylistsSort? value) =>
                          _onFilterPlaylistsChanged(value, myState),
                    ),
                  ),
                  ListTile(
                    title: const Text('Ascending duration'),
                    leading: Radio<PlaylistsSort>(
                      value: PlaylistsSort.duration,
                      groupValue: _musicRepository.playlistSort,
                      onChanged: (PlaylistsSort? value) =>
                          _onFilterPlaylistsChanged(value, myState),
                    ),
                  ),
                  ListTile(
                    title: const Text('Descending duration'),
                    leading: Radio<PlaylistsSort>(
                      value: PlaylistsSort.descendingDuration,
                      groupValue: _musicRepository.playlistSort,
                      onChanged: (PlaylistsSort? value) =>
                          _onFilterPlaylistsChanged(value, myState),
                    ),
                  ),
                  ListTile(
                    title: const Text('Ascending songs count'),
                    leading: Radio<PlaylistsSort>(
                      value: PlaylistsSort.songsCount,
                      groupValue: _musicRepository.playlistSort,
                      onChanged: (PlaylistsSort? value) =>
                          _onFilterPlaylistsChanged(value, myState),
                    ),
                  ),
                  ListTile(
                    title: const Text('Descending songs count'),
                    leading: Radio<PlaylistsSort>(
                      value: PlaylistsSort.descendingSongsCount,
                      groupValue: _musicRepository.playlistSort,
                      onChanged: (PlaylistsSort? value) =>
                          _onFilterPlaylistsChanged(value, myState),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _isFetchingData.match(
          (error) => LoadingDataError(error: error),
          (state) {
            if (state) {
              return const LoadingAnimation(sourceName: "playlists");
            } else {
              return _buildPlaylists(_musicRepository.playlists);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showModelFilterPlaylist(context),
        tooltip: "Sort",
        child: const Icon(Icons.sort),
      ),
    );
  }
}
