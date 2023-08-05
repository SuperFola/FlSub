import 'package:flutter/material.dart';
import 'package:subsonic_flutter/domain/model/server.dart';
import 'package:subsonic_flutter/domain/model/subsonic_error.dart';
import 'package:subsonic_flutter/infrastructure/auth_api.dart';
import 'package:subsonic_flutter/main.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = "/login";

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController serverUrlController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final AuthAPI _authAPI = AuthAPI();

  void _navigateToHome(String url, String username, String password) {
    ServerData.url = url;
    ServerData.username = username;
    ServerData.password = password;

    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(MyHomePage.routeName);
  }

  void _showError(BuildContext context, SubsonicError error) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("Error"),
              content: Text(error.message),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ));
  }

  void _connect() async {
    if (_formKey.currentState!.validate()) {
      try {
        String url = serverUrlController.text;
        String username = usernameController.text;
        String password = passwordController.text;

        var pingReq = await _authAPI.login(url, username, password);
        pingReq.match((l) => _showError(context, l),
            (r) => _navigateToHome(url, username, password));
      } on Exception catch (e) {
        // FIXME maybe do not show the whole error message here
        _showError(context, SubsonicError(-1, e.toString()));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill input')));
    }
  }

  @override
  void dispose() {
    serverUrlController.dispose();
    usernameController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          centerTitle: true,
          title: const Text(
            "Login to Subsonic",
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      controller: serverUrlController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Server URL"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Server URL is required';
                        }
                        return null;
                      },
                    )),
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Username"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username is required';
                        }
                        return null;
                      },
                    )),
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Password"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    )),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Center(
                      child: ElevatedButton(
                    onPressed: _connect,
                    child: const Text('Submit'),
                  )),
                ),
              ],
            ),
          ),
        ));
  }
}
