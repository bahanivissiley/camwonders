import 'package:camwonders/class/classes.dart';
import 'package:camwonders/colors.dart';
import 'package:camwonders/firebase_logique.dart';
import 'package:camwonders/mainapp.dart';
import 'package:camwonders/welcome.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:google_fonts/google_fonts.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(WonderAdapter());
  Hive.registerAdapter(CategorieAdapter());
  await Hive.openBox<Wonder>('favoris_wonder');
  await Firebase.initializeApp();
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
        colorSchemeSeed: primary,
        bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
        primaryColorLight: Colors.black12,
        elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(
          backgroundColor: const MaterialStatePropertyAll(Color(0xff226900)),
          foregroundColor: const MaterialStatePropertyAll(Color.fromARGB(255, 255, 255, 255)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6)
          )),
        ))
      ),
      dark: ThemeData(

        brightness: Brightness.dark,
        colorSchemeSeed: primary,
        bottomAppBarTheme: const BottomAppBarTheme(color: Color.fromARGB(31, 2, 10, 0)),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(
          backgroundColor: const MaterialStatePropertyAll(Color(0xff226900)),
          foregroundColor: const MaterialStatePropertyAll(Color.fromARGB(255, 0, 0, 0)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6)
          ))
        ))
      ),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        home: AuthService().currentUser == null ? const Welcome() : const MainApp(),
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
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Camwonders"),
          ElevatedButton(onPressed: () {
            AdaptiveTheme.of(context).toggleThemeMode();
          }, child: const Text("Changer theme")),
        ],
      ),) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}