import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:subsonic_flutter/domain/model/playlist.dart';
import 'package:subsonic_flutter/domain/model/subsonic_error.dart';
import 'package:subsonic_flutter/infrastructure/music_api.dart';

class MyHomePage extends StatefulWidget {
  static const String routeName = "/home";

  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MusicAPI _musicAPI = MusicAPI();

  Widget _buildPlaylists(List<Playlist> playlists) {
    var children = List<Widget>.empty(growable: true);
    for (int index = 0; index < playlists.length; index++) {
      children.add(
        Card(
          child: ListTile(
            leading: const FlutterLogo(size: 72.0),
            title: Text(playlists[index].name),
            subtitle: Column(
              children: <Widget>[
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
            ),
            // trailing: const Icon(Icons.star_outline),
            // isThreeLine: true,
          ),
        ),
      );
    }

    return Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          shrinkWrap: true,
          children: children,
        ));
  }

  Widget _buildSubsonicError(SubsonicError error) {
    return Container(
      alignment: Alignment.center,
      color: Colors.blueGrey,
      child: Text(error.message),
    );
  }

  Widget _buildLoadingAnimation() {
    return const SingleChildScrollView(
        child: Center(
            child: Column(children: <Widget>[
      SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(),
      ),
      Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text('Fetching playlist...'),
      ),
    ])));
  }

  Widget _buildLoadingDataError(Object? error) {
    return SingleChildScrollView(
        child: Center(
            child: Column(children: <Widget>[
      const Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 60,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text('Error: $error'),
      ),
    ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<fp.Either<SubsonicError, List<Playlist>>>(
          future: _musicAPI.getPlaylists(),
          builder: (BuildContext context,
              AsyncSnapshot<fp.Either<SubsonicError, List<Playlist>>>
                  snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!.match(_buildSubsonicError, _buildPlaylists);
            } else if (snapshot.hasError) {
              return _buildLoadingDataError(snapshot.error);
            } else {
              return _buildLoadingAnimation();
            }
          },
        ),
      ),
    );
  }
}
