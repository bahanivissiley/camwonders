import 'package:camwonders/class/Categorie.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/firebase/firebase_logique.dart';
import 'package:camwonders/mainapp.dart';
import 'package:camwonders/pages/welcome.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:google_fonts/google_fonts.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(WonderAdapter());
  Hive.registerAdapter(CategorieAdapter());
  await Firebase.initializeApp();
  await Hive.openBox<Wonder>('favoris_wonder');
  runApp(const MyApp());
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
        colorScheme: ColorScheme.light(
          surface: Colors.white,
          primary: Colors.personnalgreen,
          secondary: Colors.personnalgreen
        ),
        bannerTheme: MaterialBannerThemeData(backgroundColor: Colors.white),
        bottomAppBarTheme: const BottomAppBarTheme(color: Color(0xffffffff), elevation: 5),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
          backgroundColor:
              const MaterialStatePropertyAll(Colors.personnalgreen),
          foregroundColor: const MaterialStatePropertyAll(
              Color.fromARGB(255, 255, 255, 255)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        )),
        inputDecorationTheme: const InputDecorationTheme(
          focusColor: Colors.personnalgreen,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor:
                MaterialStateProperty.all<Color>(Colors.personnalgreen),
          ),
        ),
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
            background: Color(0xff222222),
            primary: Colors.personnalgreen,
            secondary: Colors.personnalgreen
        ),
        appBarTheme: AppBarTheme(color: Color.fromARGB(31, 2, 10, 0)),
        bottomAppBarTheme:
            const BottomAppBarTheme(color: Color.fromARGB(31, 2, 10, 0)),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                backgroundColor:
                    const MaterialStatePropertyAll(Color(0xff226900)),
                foregroundColor: const MaterialStatePropertyAll(
                    Color.fromARGB(255, 0, 0, 0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6))))),
        inputDecorationTheme:
            const InputDecorationTheme(focusColor: Colors.personnalgreen),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor:
                MaterialStateProperty.all<Color>(Colors.personnalgreen),
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
