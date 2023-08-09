import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:subsonic_flutter/domain/model/PlaylistArguments.dart';
import 'package:subsonic_flutter/domain/model/playlist.dart';
import 'package:subsonic_flutter/domain/model/server.dart';
import 'package:subsonic_flutter/domain/model/subsonic_error.dart';
import 'package:subsonic_flutter/infrastructure/repository/auth_repository.dart';
import 'package:subsonic_flutter/infrastructure/repository/music_repository.dart';
import 'package:subsonic_flutter/pages/login.dart';
import 'package:subsonic_flutter/pages/playlist.dart';
import 'package:subsonic_flutter/properties.dart';
import 'package:subsonic_flutter/widgets/LoadingDataError.dart';
import 'package:subsonic_flutter/widgets/loading_animation.dart';
import 'package:subsonic_flutter/widgets/music_player.dart';
import 'package:subsonic_flutter/widgets/subsonic_card.dart';

class MyHomePage extends StatefulWidget {
  static const String routeName = "/home";

  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum HomePopupMenuSelected { sortPlaylists, reloadPlaylists, logOut }

class _MyHomePageState extends State<MyHomePage> {
  final _musicRepository = getIt<MusicRepository>();
  final _authRepository = AuthRepository();

  fp.Either<SubsonicError, bool> _isFetchingData = const fp.Right(true);

  _MyHomePageState() {
    _refreshPlaylists();
  }

  Future<void> _refreshPlaylists() async {
    setState(() {
      _isFetchingData = const fp.Right(true);
    });

    _musicRepository.fetchPlaylists().then((value) {
      value.match((error) {
        setState(() {
          _isFetchingData = fp.Left(error);
        });
      }, (_) {
        setState(() {
          _isFetchingData = const fp.Right(false);
        });
      });
    });
  }

  Widget _buildPlaylists(List<Playlist> playlists) {
    List<Widget> children = [];
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

    children.add(const SizedBox(height: 200));

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isFetchingData = const fp.Right(true);
        });
        await _refreshPlaylists();
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              shrinkWrap: true,
              children: children,
            ),
          ),
          const MusicPlayer(),
        ],
      ),
    );
  }

  void _onFilterPlaylistsChanged(PlaylistsSort? value, StateSetter myState) {
    myState(() {
      _musicRepository.sortPlaylistsBy(value ?? PlaylistsSort.alphabetical);
    });
    setState(() {});
  }

  void _showModalFilterPlaylist(BuildContext context) {
    children(StateSetter myState) => [
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
        ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            StatefulBuilder(
              builder: (BuildContext context, StateSetter myState) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 4.0,
                  ),
                  child: ListView(
                    children: children(myState),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _onPopupMenuSelected(BuildContext context, HomePopupMenuSelected selected) {
    switch (selected) {
      case HomePopupMenuSelected.sortPlaylists:
        _showModalFilterPlaylist(context);
        break;

      case HomePopupMenuSelected.reloadPlaylists:
        _refreshPlaylists();
        break;

      case HomePopupMenuSelected.logOut:
        _authRepository.logout();
        Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(getIt<ServerData>().username),
        actions: [
          PopupMenuButton<HomePopupMenuSelected>(
            onSelected: (value) => _onPopupMenuSelected(context, value),
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem(
                value: HomePopupMenuSelected.sortPlaylists,
                child: Text("Sort playlists"),
              ),
              PopupMenuItem(
                value: HomePopupMenuSelected.reloadPlaylists,
                child: Text("Reload playlists"),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: HomePopupMenuSelected.logOut,
                child: Text("Log out"),
              ),
            ],
          ),
        ],
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
    );
  }
}
