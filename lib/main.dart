import 'package:camwonders/class/Categorie.dart';
import 'package:camwonders/class/Notification.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/firebase/supabase_logique.dart';
import 'package:camwonders/mainapp.dart';
import 'package:camwonders/pages/welcome.dart';
import 'package:camwonders/widgetGlobal.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:event_bus/event_bus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final EventBus eventBus = EventBus();

class NotificationEvent {
  final String? title;
  final String? body;

  NotificationEvent(this.title, this.body);
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(WonderAdapter());
  Hive.registerAdapter(CategorieAdapter());


  await Hive.openBox<Wonder>('favoris_wonder');
  await Supabase.initialize(
    url: 'https://hrqjdfpyaucbqitmxlaq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhycWpkZnB5YXVjYnFpdG14bGFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk1NDI1MTAsImV4cCI6MjA1NTExODUxMH0.Lk73eWJaCfCNaKqTdITWJhGzIL9K40LRwKDhB9TQwGs',
  );


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
          backgroundColor: const WidgetStatePropertyAll(Color(0xff226900)),
          foregroundColor:
              const WidgetStatePropertyAll(Color.fromARGB(255, 255, 255, 255)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        )),
        inputDecorationTheme: const InputDecorationTheme(
          focusColor: Color(0xff226900),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor:
            WidgetStateProperty.all<Color>(const Color(0xff226900)),
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
                    const WidgetStatePropertyAll(Color(0xff226900)),
                foregroundColor:
                    const WidgetStatePropertyAll(Color.fromARGB(255, 0, 0, 0)),
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
      builder: (theme, darkTheme) => GetMaterialApp (
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
