import 'package:fpdart/fpdart.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subsonic_flutter/domain/model/bookmark.dart';
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
  Map<String, Bookmark> _bookmarks = {};

  MusicRepository(SharedPreferences prefs) {
    String? playlistsData = prefs.getString("playlists");

    if (playlistsData != null) {
      _playlists = Playlist.decode(playlistsData);

      for (final playlist in _playlists) {
        String? songsData = prefs.getString("playlists.${playlist.id}");

        if (songsData != null) {
          _playlistsSongs[playlist.id] = Song.decode(songsData);
        }

        String? bookmarkData =
            prefs.getString("playlists.bookmarks.${playlist.id}");

        if (bookmarkData != null) {
          _bookmarks[playlist.id] = Bookmark.decode(bookmarkData).first;
        }
      }
    }
  }

  List<Playlist> get playlists => _sortedPlaylists;

  PlaylistsSort get playlistSort => _playlistSort;

  List<Bookmark> get bookmarks => _bookmarks.values.toList();

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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("playlists", Playlist.encode(_playlists));

    for (var playlist in _playlists) {
      fetchSinglePlaylist(playlist.id);
    }

    return playlists;
  }

  Future<Either<SubsonicError, List<Song>>> fetchSinglePlaylist(
      String id) async {
    final data = getIt<ServerData>();
    final songs = await _musicAPI.getSinglePlaylist(data, id);

    songs.map((data) {
      _playlistsSongs[id] = data;
    });

    if (_playlistsSongs.containsKey(id)) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("playlists.$id", Song.encode(_playlistsSongs[id]!));
    }

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

  Future<void> deleteBookmark(String attachedPlaylistId) async {
    if (_bookmarks.containsKey(attachedPlaylistId)) {
      _bookmarks.remove(attachedPlaylistId);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("playlists.bookmarks.$attachedPlaylistId");
    }
  }

  void _saveBookmark(Bookmark bookmark) async {
    _bookmarks[bookmark.playlistId] = bookmark;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
      "playlists.bookmarks.${bookmark.playlistId}",
      Bookmark.encode([bookmark]),
    );
  }

  void _stopAndBookmark(AudioPlayer player) {
    if (player.playing) {
      final metadata = player.sequenceState!.currentSource!.tag as MediaItem;

      if (metadata.extras!["canBeBookmarked"]) {
        final bookmark = Bookmark(
          songId: metadata.id,
          playlistId: metadata.extras!["playlistId"],
          coverArtId: metadata.extras!["coverArtId"],
          songTitle: metadata.title,
          playlistName: metadata.extras!["playlistName"],
          songPositionSeconds: player.position.inSeconds,
          songDurationSeconds: metadata.extras!["songDuration"],
        );
        _saveBookmark(bookmark);
      }

      player.stop();
    }
  }

  AudioSource _makeAudioSource(
    ServerData data,
    Song song,
    String? maybePlaylistId,
  ) {
    final playlistId = maybePlaylistId ??
        _playlistsSongs
            .filter(
              (value) => value.filter((t) => t.id == song.id).isNotEmpty,
            )
            .keys
            .first;
    final coverArtId = song.coverArtId ?? playlistId;
    final playlistName =
        _playlists.filter((t) => t.id == playlistId).first.name;

    return AudioSource.uri(
      _musicAPI.getStreamSongUri(data, song.id),
      tag: MediaItem(
        id: song.id,
        album: song.album,
        title: song.title,
        artUri: _musicAPI.getCoverArtUri(data, coverArtId, null),
        extras: {
          "playlistId": playlistId,
          "playlistName": playlistName,
          "coverArtId": coverArtId,
          "songDuration": song.durationSeconds,
          // if we have a playlist given, it can be saved and resumed
          // otherwise we were given a single song, and if it is interrupted, no need to record that
          "canBeBookmarked": maybePlaylistId != null,
        },
      ),
    );
  }

  Future<void> playSong(Song song) async {
    final data = getIt<ServerData>();
    final player = getIt<AudioPlayer>();

    _stopAndBookmark(player);

    try {
      await player.setAudioSource(_makeAudioSource(data, song, null));
      player.play();
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  Future<void> playPlaylist(String playlistId) async {
    final data = getIt<ServerData>();
    final player = getIt<AudioPlayer>();

    _stopAndBookmark(player);

    if (_playlistsSongs[playlistId] != null) {
      List<AudioSource> audiosSources = [];

      for (final song in _playlistsSongs[playlistId]!) {
        audiosSources.add(_makeAudioSource(data, song, playlistId));
      }
      var playlist = ConcatenatingAudioSource(children: audiosSources);

      try {
        await player.setAudioSource(playlist);
        player.play();
      } catch (e) {
        print("Error loading audio source: $e");
      }
    }
  }

  Future<void> playPlaylistStartingFrom(
      String playlistId, String songId, int atDurationSeconds) async {
    final data = getIt<ServerData>();
    final player = getIt<AudioPlayer>();

    _stopAndBookmark(player);

    if (_playlistsSongs[playlistId] != null) {
      List<AudioSource> audiosSources = [];

      for (final song in _playlistsSongs[playlistId]!) {
        audiosSources.add(_makeAudioSource(data, song, playlistId));
      }
      var playlist = ConcatenatingAudioSource(children: audiosSources);
      final songIndex = _playlistsSongs[playlistId]!
          .indexWhere((element) => element.id == songId);

      try {
        await player.setAudioSource(playlist);
        player.seek(
          Duration(seconds: atDurationSeconds),
          index: songIndex,
        );
        player.play();
      } catch (e) {
        print("Error loading audio source: $e");
      }
    }
  }
}
