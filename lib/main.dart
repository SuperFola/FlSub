import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subsonic_flutter/pages/home.dart';
import 'package:subsonic_flutter/pages/login.dart';
import 'domain/model/server.dart';
import 'properties.dart' as properties;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

  const storage = FlutterSecureStorage();

  properties.getIt.registerSingleton<ServerData>(ServerData(
    url: prefs.getString("server.url") ?? "",
    username: await storage.read(key: "server.username") ?? "",
    password: await storage.read(key: "server.password") ?? ""
  ));

  runApp(MyApp(isLoggedIn: isLoggedIn,));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState(isLoggedIn);  // FIXME

}

class _MyAppState extends State<MyApp> {
  final bool isLoggedIn;

  _MyAppState(this.isLoggedIn);

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // FIXME: this doesn't work?
    //_monet = await MonetProvider.newInstance();
    // We add a listener to refresh the ui if we get new colors from the wallpaper.
    //_monet!.addListener(() => setState(() {}));

    //setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: properties.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: isLoggedIn ? MyHomePage(title: properties.getIt<ServerData>().username) : const LoginPage(),
      routes: {
        LoginPage.routeName: (BuildContext _) => const LoginPage(),
        MyHomePage.routeName: (BuildContext _) => MyHomePage(title: properties.getIt<ServerData>().username)
      },
    );
  }
}
