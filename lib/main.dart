import 'package:camwonders/class/Categorie.dart';
import 'package:camwonders/class/Notification.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/firebase/firebase_logique.dart';
import 'package:camwonders/firebase/firebase_options.dart';
import 'package:camwonders/mainapp.dart';
import 'package:camwonders/pages/welcome.dart';
import 'package:camwonders/widgetGlobal.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:camwonders/class/Notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(WonderAdapter());
  Hive.registerAdapter(CategorieAdapter());
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    appleProvider: AppleProvider.appAttest,
  );

  await Hive.openBox<Wonder>('favoris_wonder');

  final notificationSettings = await FirebaseMessaging.instance.requestPermission(provisional: true);
  final fcmToken = await FirebaseMessaging.instance.getToken();

  FirebaseMessaging.instance.onTokenRefresh
      .listen((fcmToken) {
  })
      .onError((err) {
  });


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WondersProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        //primaryColor: Colors.red,
        colorScheme: const ColorScheme.light(
            primary: Color(0xff226900),
            secondary: Color(0xff226900)),
        bannerTheme:
            const MaterialBannerThemeData(backgroundColor: Colors.white),
        bottomAppBarTheme:
            const BottomAppBarTheme(color: Color(0xffffffff), elevation: 5),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
          backgroundColor: const MaterialStatePropertyAll(Color(0xff226900)),
          foregroundColor:
              const MaterialStatePropertyAll(Color.fromARGB(255, 255, 255, 255)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        )),
        inputDecorationTheme: const InputDecorationTheme(
          focusColor: Color(0xff226900),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor:
            MaterialStateProperty.all<Color>(const Color(0xff226900)),
          ),
        ),
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
            surface: Color(0xff222222),
            primary: Color(0xff226900),
            secondary: Color(0xff226900)),
        appBarTheme: const AppBarTheme(color: Color.fromARGB(31, 2, 10, 0)),
        bottomAppBarTheme:
            const BottomAppBarTheme(color: Color.fromARGB(31, 2, 10, 0)),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                backgroundColor:
                    const MaterialStatePropertyAll(Color(0xff226900)),
                foregroundColor:
                    const MaterialStatePropertyAll(Color.fromARGB(255, 0, 0, 0)),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6))))),
        inputDecorationTheme:
            const InputDecorationTheme(focusColor: Color(0xff226900)),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor:
                WidgetStateProperty.all<Color>(const Color(0xff226900)),
          ),
        ),
      ),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        home: AuthService().currentUser == null ? const Welcome() : MainApp(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Camwonders"),
          ElevatedButton(
              onPressed: () {
                AdaptiveTheme.of(context).toggleThemeMode();
              },
              child: const Text("Changer theme")),
        ],
      ),
    ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
