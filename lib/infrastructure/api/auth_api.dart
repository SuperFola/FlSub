import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:subsonic_flutter/domain/model/subsonic_error.dart';
import 'package:subsonic_flutter/infrastructure/api/base_api.dart';

class AuthAPI extends BaseAPI {
  Future<Either<SubsonicError, Unit>> login(
      String host, String username, String password) async {
    try {
      var response = await http.post(super.pingUri(host, username, password));
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
}
