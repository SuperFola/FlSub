import 'package:subsonic_flutter/domain/model/server.dart';

class BaseAPI {
  static const subsonicEndpoint = "/rest";
  static const pingRoute = "$subsonicEndpoint/ping.view";

  static const getSinglePlaylistRoute = "$subsonicEndpoint/getPlaylist.view";
  static const getPlaylistsRoute = "$subsonicEndpoint/getPlaylists.view";
  static const getCoverArtRoute = "$subsonicEndpoint/getCoverArt.view";

  static const defaultParameters = {
    "v": "1.2.0",
    "c": "FlSub",
    "f": "json",
  };

  Uri _baseURI(ServerData data, String path, Map<String, String> params) {
    var queryParams = {
      ...defaultParameters,
      "u": data.username,
      // FIXME for testing only
      "p": data.password,
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
