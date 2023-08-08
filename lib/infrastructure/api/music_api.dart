import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:subsonic_flutter/domain/model/playlist.dart';
import 'package:subsonic_flutter/domain/model/server.dart';
import 'package:subsonic_flutter/domain/model/song.dart';
import 'package:subsonic_flutter/domain/model/subsonic_error.dart';
import 'package:subsonic_flutter/infrastructure/api/base_api.dart';

class MusicAPI extends BaseAPI {
  Future<Either<SubsonicError, List<Playlist>>> getPlaylists(
      ServerData data) async {
    try {
      var response = await http.post(super.getPlaylistsUri(data));
      if (response.statusCode == 200) {
        Map<String, dynamic> parsed = jsonDecode(response.body);

        if (parsed.containsKey("error")) {
          return Left(SubsonicError(
              parsed["error"]["code"], parsed["error"]["message"]));
        } else {
          List<Playlist> playlists = [];
          for (final json in parsed["subsonic-response"]["playlists"]
              ["playlist"]) {
            playlists.add(Playlist(
              id: json["id"],
              name: json["name"],
              owner: json["owner"],
              isPublic: json["public"],
              createdAt: json["created"],
              changedAt: json["changed"],
              songCount: json["songCount"],
              durationSeconds: json["duration"],
              coverArtId: json["coverArt"],
            ));
          }
          return Right(playlists);
        }
      }

      return const Left(SubsonicError.unknownError);
    } on http.ClientException catch (e) {
      return Future.value(Left(SubsonicError(-1, e.message)));
    }
  }

  Future<Either<SubsonicError, List<Song>>> getSinglePlaylist(
      ServerData data, String id) async {
    try {
      var response = await http.post(super.getSinglePlaylistUri(data, id));
      if (response.statusCode == 200) {
        Map<String, dynamic> parsed = jsonDecode(response.body);

        if (parsed.containsKey("error")) {
          return Left(SubsonicError(
              parsed["error"]["code"], parsed["error"]["message"]));
        } else {
          List<Song> songs = [];
          for (final json in parsed["subsonic-response"]["playlist"]["entry"]) {
            songs.add(Song(
              id: json["id"],
              parentId: json["parent"],
              title: json["title"],
              type: json["type"],
              albumId: json["albumId"],
              album: json["album"],
              artistId: json["artistId"],
              artist: json["artist"],
              coverArtId: json["coverArt"],
              durationSeconds: json["duration"],
              bitRate: json["bitRate"],
              year: json["year"],
              size: json["size"],
              contentType: json["contentType"],
            ));
          }
          return Right(songs);
        }
      }

      return const Left(SubsonicError.unknownError);
    } on http.ClientException catch (e) {
      return Future.value(Left(SubsonicError(-1, e.message)));
    }
  }

  Future<Either<SubsonicError, Unit>> streamSong(
      ServerData data, String id) async {
    try {
      var response = await http.post(super.getStreamSongUri(data, id));
      if (response.statusCode == 200) {
        Map<String, dynamic> parsed = jsonDecode(response.body);

        if (parsed.containsKey("error")) {
          return Left(SubsonicError(
              parsed["error"]["code"], parsed["error"]["message"]));
        } else {
          return const Right(unit);
        }
      }

      return const Left(SubsonicError.unknownError);
    } on http.ClientException catch (e) {
      return Future.value(Left(SubsonicError(-1, e.message)));
    }
  }

  String getCoverArtUrlFor(ServerData data, String id, String? size) {
    return super.getCoverArtUri(data, id, size).toString();
  }
}
