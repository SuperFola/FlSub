import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:subsonic_flutter/domain/model/playlist.dart';
import 'package:subsonic_flutter/domain/model/server.dart';
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
          var playlists = List<Playlist>.empty(growable: true);
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
                json["covertArt"]));
          }
          return Right(playlists);
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
