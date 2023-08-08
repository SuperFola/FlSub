import 'package:fpdart/fpdart.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
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

  bool hasPlaylist(String id) {
    return _playlistsSongs.containsKey(id);
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

  Future<void> playSong(Song song) async {
    final data = getIt<ServerData>();

    if (getIt<AudioPlayer>().playing) {
      getIt<AudioPlayer>().stop();
    }

    try {
      await getIt<AudioPlayer>().setAudioSource(AudioSource.uri(
        _musicAPI.getStreamSongUri(data, song.id),
        tag: MediaItem(
          id: '0',
          album: song.album,
          title: song.title,
          artUri: _musicAPI.getCoverArtUri(data, song.safeCoverArtId, null),
        ),
      ));
      getIt<AudioPlayer>().play();
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  Future<void> playPlaylist(String playlistId) async {
    final data = getIt<ServerData>();

    if (getIt<AudioPlayer>().playing) {
      getIt<AudioPlayer>().stop();
    }

    if (_playlistsSongs[playlistId] != null) {
      List<AudioSource> audiosSources = [];

      for (var index = 0;
          index < _playlistsSongs[playlistId]!.length;
          ++index) {
        final song = _playlistsSongs[playlistId]![index];
        audiosSources.add(AudioSource.uri(
          _musicAPI.getStreamSongUri(data, song.id),
          tag: MediaItem(
            id: '$index',
            album: song.album,
            title: song.title,
            artUri: _musicAPI.getCoverArtUri(data, song.covertArtId ?? playlistId, null),
          ),
        ));
      }
      var playlist = ConcatenatingAudioSource(children: audiosSources);

      try {
        await getIt<AudioPlayer>().setAudioSource(playlist);
        getIt<AudioPlayer>().play();
      } catch (e) {
        print("Error loading audio source: $e");
      }
    }
  }
}
