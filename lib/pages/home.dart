import 'package:flutter/material.dart';
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
          Container(
            height: 50,
            color: index % 2 == 0 ? Colors.amber : Colors.green,
            child: Text(playlists[index].name),
          )
      );
    }

    return ListView(
      shrinkWrap: true,
      children: children,
    );
  }

  Widget _buildError(SubsonicError error) {
    return Container(
      alignment: Alignment.center,
      color: Colors.blueGrey,
      child: Text(error.message),
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
        child: SingleChildScrollView(
          child: FutureBuilder<fp.Either<SubsonicError, List<Playlist>>>(
              future: _musicAPI.getPlaylists(),
              builder: (BuildContext context,
                  AsyncSnapshot<fp.Either<SubsonicError, List<Playlist>>>
                      snapshot) {
                List<Widget> children;
                if (snapshot.hasData) {
                  children = <Widget>[
                    snapshot.data!.match(_buildError, _buildPlaylists)
                  ];
                } else if (snapshot.hasError) {
                  children = <Widget>[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  ];
                } else {
                  children = const <Widget>[
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Fetching playlist...'),
                    ),
                  ];
                }
                return Column(children: children,);
              },
            )
        ),
      ),
    );
  }
}
