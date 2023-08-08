import 'package:fpdart/fpdart.dart';
import 'package:subsonic_flutter/domain/model/playlist.dart';
import 'package:subsonic_flutter/domain/model/server.dart';
import 'package:subsonic_flutter/domain/model/song.dart';
import 'package:subsonic_flutter/domain/model/subsonic_error.dart';
import 'package:subsonic_flutter/infrastructure/api/music_api.dart';
import 'package:subsonic_flutter/properties.dart';

enum PlaylistsSort {
  alphabetical,
  reverseAlphabetical,
  duration,
  descendingDuration,
  songsCount,
  descendingSongsCount,
}

class MusicRepository {
  final _musicAPI = MusicAPI();

  PlaylistsSort _playlistSort = PlaylistsSort.alphabetical;
  List<Playlist> _playlists = [];
  List<Playlist> _sortedPlaylists = [];
  Map<String, List<Song>> _playlistsSongs = {};

  List<Playlist> get playlists => _sortedPlaylists;

  PlaylistsSort get playlistSort => _playlistSort;

  List<Song> playlist(String id) {
    return _playlistsSongs[id] ?? [];
  }

  Future<Either<SubsonicError, List<Playlist>>> fetchPlaylists() async {
    final data = getIt<ServerData>();
    final playlists = await _musicAPI.getPlaylists(data);

    playlists.map((data) {
      _playlists = data;
      sortPlaylistsBy(_playlistSort);
    });

    return playlists;
  }

  Future<Either<SubsonicError, List<Song>>> fetchSinglePlaylist(
      String id) async {
    final data = getIt<ServerData>();
    final songs = await _musicAPI.getSinglePlaylist(data, id);

    songs.map((data) {
      _playlistsSongs[id] = data;
    });

    return songs;
  }

  List<Playlist> sortPlaylistsBy(PlaylistsSort sort) {
    _playlistSort = sort;
    _sortedPlaylists = _playlists;

    switch (sort) {
      case PlaylistsSort.alphabetical:
        _sortedPlaylists.sort((a, b) => a.name.compareTo(b.name));
      case PlaylistsSort.reverseAlphabetical:
        _sortedPlaylists.sort((a, b) => -a.name.compareTo(b.name));
      case PlaylistsSort.duration:
        _sortedPlaylists
            .sort((a, b) => a.durationSeconds.compareTo(b.durationSeconds));
      case PlaylistsSort.descendingDuration:
        _sortedPlaylists
            .sort((a, b) => -a.durationSeconds.compareTo(b.durationSeconds));
      case PlaylistsSort.songsCount:
        _sortedPlaylists.sort((a, b) => a.songCount.compareTo(b.songCount));
      case PlaylistsSort.descendingSongsCount:
        _sortedPlaylists.sort((a, b) => -a.songCount.compareTo(b.songCount));
    }

    return _sortedPlaylists;
  }

  String getCoverArtUrlFor(String id, String? size) {
    final data = getIt<ServerData>();
    return _musicAPI.getCoverArtUrlFor(data, id, size);
  }
}
