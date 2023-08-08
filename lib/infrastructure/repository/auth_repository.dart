import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subsonic_flutter/domain/model/server.dart';
import 'package:subsonic_flutter/domain/model/subsonic_error.dart';
import 'package:subsonic_flutter/infrastructure/api/auth_api.dart';
import 'package:subsonic_flutter/properties.dart';

class AuthRepository {
  final _authAPI = AuthAPI();
  ServerData? _serverData;
  bool _isLoggedIn = false;

  ServerData? get serverData {
    if (_isLoggedIn) {
      return _serverData;
    } else {
      return null;
    }
  }

  Future<void> _persistLoginData(String host, String username,
      String password) async {
    _serverData = ServerData(url: host, username: username, password: password);
    _isLoggedIn = true;

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

  Future<Either<SubsonicError, Unit>> login(String host, String username,
      String password) async {
    var result = await _authAPI.login(host, username, password);
    result.map((_) => _persistLoginData(host, username, password));

    return result;
  }

  Future<void> logout() async {
    _isLoggedIn = false;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLoggedIn", false);
  }
}