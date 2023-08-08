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
              json["id"],
              json["name"],
              json["owner"],
              json["public"],
              json["created"],
              json["changed"],
              json["songCount"],
              json["duration"],
              json["covertArt"],
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
              json["id"],
              json["parent"],
              json["title"],
              json["type"],
              json["albumId"],
              json["album"],
              json["artistId"],
              json["artist"],
              json["coverArt"],
              json["duration"],
              json["bitRate"],
              json["year"],
              json["size"],
              json["contentType"],
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

  String getCoverArtUrlFor(ServerData data, String id, String? size) {
    return super.getCoverArtUri(data, id, size).toString();
  }
}
