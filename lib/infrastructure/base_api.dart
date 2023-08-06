import 'package:subsonic_flutter/domain/model/server.dart';

class BaseAPI {
  static const subsonicEndpoint = "/rest";
  static const pingRoute = "$subsonicEndpoint/ping.view";

  static const getSinglePlaylistRoute = "$subsonicEndpoint/getPlaylist.view";
  static const getPlaylistsRoute = "$subsonicEndpoint/getPlaylists.view";

  static const defaultParameters = {
    "v": "1.2.0",
    "c": "FlSub",
    "f": "json",
  };

  Uri pingUri(String host, String username, String password) {
    var queryParams = {
      ...defaultParameters,
      "u": username,
      // FIXME for testing only
      "p": password,
    };

    return Uri(
      scheme: 'https',
      host: host,
      path: pingRoute,
      queryParameters: queryParams,
    );
  }

  Uri getPlaylistsUri(ServerData data) {
    var queryParams = {
      ...defaultParameters,
      "u": data.username,
      // FIXME for testing only
      "p": data.password,
    };

    return Uri(
      scheme: 'https',
      host: data.url,
      path: getPlaylistsRoute,
      queryParameters: queryParams,
    );
  }
}
