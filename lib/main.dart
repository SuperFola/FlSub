import 'package:audio_session/audio_session.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subsonic_flutter/infrastructure/repository/music_repository.dart';
import 'package:subsonic_flutter/pages/home.dart';
import 'package:subsonic_flutter/pages/login.dart';
import 'package:subsonic_flutter/pages/playlist.dart';
import 'package:system_theme/system_theme.dart';

import 'domain/model/server.dart';
import 'properties.dart' as properties;

T? ambiguate<T>(T? value) => value;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemTheme.accentColor.load();

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
  properties.getIt.registerSingleton<MusicRepository>(MusicRepository(prefs));

  runApp(MyApp(
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
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
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          // On Android S+ devices, use the provided dynamic color scheme.
          // (Recommended) Harmonize the dynamic color scheme' built-in semantic colors.
          lightColorScheme = lightDynamic.harmonized();
          // Repeat for the dark color scheme.
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // Otherwise, use fallback schemes.
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: SystemTheme.accentColor.accent,
            secondary: SystemTheme.accentColor.light,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: SystemTheme.accentColor.accent,
            secondary: SystemTheme.accentColor.dark,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: properties.appName,
          theme: ThemeData(
            colorScheme: lightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: widget.isLoggedIn ? const MyHomePage() : const LoginPage(),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case LoginPage.routeName:
                return PageTransition(
                  child: const LoginPage(),
                  type: PageTransitionType.rightToLeft,
                  settings: settings,
                );
              case MyHomePage.routeName:
                return PageTransition(
                  child: const MyHomePage(),
                  type: PageTransitionType.rightToLeft,
                  settings: settings,
                );
              case PlaylistPage.routeName:
                return PageTransition(
                  child: const PlaylistPage(),
                  type: PageTransitionType.rightToLeft,
                  settings: settings,
                );
              default:
                return null;
            }
          },
        );
      },
    );
  }
}
