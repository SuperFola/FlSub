import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:subsonic_flutter/domain/model/server.dart';

class BaseAPI {
  static const subsonicEndpoint = "/rest";
  static const pingRoute = "$subsonicEndpoint/ping.view";

  static const getSinglePlaylistRoute = "$subsonicEndpoint/getPlaylist.view";
  static const getPlaylistsRoute = "$subsonicEndpoint/getPlaylists.view";
  static const getCoverArtRoute = "$subsonicEndpoint/getCoverArt.view";
  static const streamRoute = "$subsonicEndpoint/stream.view";

  static const defaultParameters = {
    "v": "1.13.0",
    "c": "FlSub",
    "f": "json",
  };

  String _generateRandomString(int len) {
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }

  Uri _baseURI(ServerData data, String path, Map<String, String> params) {
    final salt = _generateRandomString(16);

    var queryParams = {
      ...defaultParameters,
      "u": data.username,
      "t": md5.convert(utf8.encode(data.password + salt)).toString(),
      "s": salt,
      ...params,
    };

    return Uri(
      scheme: 'https',
      host: data.url,
      path: path,
      queryParameters: queryParams,
    );
  }

  Uri pingUri(String host, String username, String password) {
    return _baseURI(
      ServerData(url: host, username: username, password: password),
      pingRoute,
      {},
    );
  }

  Uri getPlaylistsUri(ServerData data) {
    return _baseURI(data, getPlaylistsRoute, {});
  }

  Uri getSinglePlaylistUri(ServerData data, String id) {
    return _baseURI(
      data,
      getSinglePlaylistRoute,
      {
        "id": id,
      },
    );
  }

  Uri getStreamSongUri(ServerData data, String id) {
    return _baseURI(
      data,
      streamRoute,
      {
        "id": id,
      },
    );
  }

  Uri getCoverArtUri(ServerData data, String id, String? size) {
    return _baseURI(
      data,
      getCoverArtRoute,
      {
        "id": id,
        if (size != null) "size": size,
      },
    );
  }
}
