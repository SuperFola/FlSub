import 'package:subsonic_flutter/domain/model/server.dart';

class BaseAPI {
  static const subsonicEndpoint = "/rest";
  static const pingRoute = "$subsonicEndpoint/ping.view";

  static const defaultParameters = {
    "v": "1.2.0",
    "c": "FlSub",
    "f": "json",
  };

  Uri ping(String host, String username, String password) {
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
}
