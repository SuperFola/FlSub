import 'dart:convert';

import 'package:http/http.dart' as http;

import 'base_api.dart';

class AuthAPI extends BaseAPI {
  Future<http.Response> login() async {
    print("making ping request!");
    http.Response response = await http.post(super.ping());

    return response;
  }
}
