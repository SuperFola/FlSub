import 'package:http/http.dart' as http;

class ServerData {
  static String? url;
  static String? username;
  static String? password;

  static bool isDefined() {
    return url != null && username != null && password != null;
  }
}