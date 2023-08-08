import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subsonic_flutter/pages/home.dart';
import 'package:subsonic_flutter/pages/login.dart';
import 'package:subsonic_flutter/pages/playlist.dart';

import 'domain/model/server.dart';
import 'properties.dart' as properties;

T? ambiguate<T>(T? value) => value;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'io.lexplt.subsonic_flutter.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

  const storage = FlutterSecureStorage();

  properties.getIt.registerSingleton<ServerData>(
    ServerData(
        url: prefs.getString("server.url") ?? "",
        username: await storage.read(key: "server.username") ?? "",
        password: await storage.read(key: "server.password") ?? ""),
  );
  properties.getIt.registerSingleton<AudioPlayer>(AudioPlayer());

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState(isLoggedIn); // FIXME
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final bool isLoggedIn;

  _MyAppState(this.isLoggedIn);

  @override
  void initState() {
    super.initState();
    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    // Listen to errors during playback.
    properties.getIt<AudioPlayer>().playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        });
  }

  @override
  void dispose() {
    ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    properties.getIt<AudioPlayer>().dispose();
    super.dispose();
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
      home: isLoggedIn
          ? MyHomePage(title: properties.getIt<ServerData>().username)
          : const LoginPage(),
      routes: {
        LoginPage.routeName: (BuildContext _) => const LoginPage(),
        MyHomePage.routeName: (BuildContext _) =>
            MyHomePage(title: properties.getIt<ServerData>().username),
        PlaylistPage.routeName: (BuildContext _) => const PlaylistPage(),
      },
    );
  }
}
