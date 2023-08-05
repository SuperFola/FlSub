import 'package:subsonic_flutter/domain/model/server.dart';

class BaseAPI {
  static const subsonicEndpoint = "/rest";
  static const pingRoute = "$subsonicEndpoint/ping.view";

  static const defaultParameters = {
    "v": "1.2.0",
    "c": "FlSub",
    "f": "json",
  };

  static const errorCodes = {
    "0": "Generic error",
    "10": "Required parameter is missing",
    "20": "Incompatible Subsonic REST protocol version. Client must upgrade",
    "30": "Incompatible Subsonic REST protocol version. Server must upgrade",
    "40": "Wrong username or password",
    "41": "Token authentication not supported for LDAP users",
    "50": "User is not authorized for the given operation",
    "60":
        "The trial period for the Subsonic server is over. Please upgrade to Subsonic Premium",
    "70": "Requested data was not found"
  };

  Uri ping() {
    var queryParams = {
      ...defaultParameters,
      "u": ServerData.username as String,
      // FIXME for testing only
      "p": ServerData.password as String,
    };

    return Uri(
      scheme: 'https',
      host: ServerData.url,
      path: pingRoute,
      queryParameters: queryParams,
    );
  }
}
