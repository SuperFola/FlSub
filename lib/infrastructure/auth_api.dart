import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subsonic_flutter/domain/model/server.dart';
import 'package:subsonic_flutter/domain/model/subsonic_error.dart';
import 'package:subsonic_flutter/properties.dart';

import 'base_api.dart';

class AuthAPI extends BaseAPI {
  Future<void> _persistLoginData(String host, String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLoggedIn", true);
    prefs.setString("server.url", host);

    const storage = FlutterSecureStorage();
    storage.write(key: "server.username", value: username);
    storage.write(key: "server.password", value: password);

    getIt<ServerData>().username = username;
    getIt<ServerData>().password = password;
    getIt<ServerData>().url = host;
  }

  Future<Either<SubsonicError, Unit>> login(String host, String username, String password) async {
    try {
      var response = await http.post(super.pingUri(host, username, password));
      if (response.statusCode == 200) {
        Map<String, dynamic> parsed = jsonDecode(response.body);

        if (parsed.containsKey("error")) {
          return Left(SubsonicError(parsed["error"]["code"], parsed["error"]["message"]));
        } else {
          await _persistLoginData(host, username, password);
          return const Right(unit);
        }
      }

      return const Left(SubsonicError.unknownError);
    } on http.ClientException catch (e) {
      return Future.value(Left(SubsonicError(-1, e.message)));
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLoggedIn", false);
  }
}
