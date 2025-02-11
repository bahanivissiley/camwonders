import 'package:camwonders/pages/bottomNavigator/page_favoris.dart';
import 'package:camwonders/pages/bottomNavigator/reservations.dart';
import 'package:camwonders/services/logique.dart';
import 'package:camwonders/pages/bottomNavigator/menu/menu.dart';
import 'package:camwonders/pages/bottomNavigator/profil.dart';
import 'package:camwonders/pages/bottomNavigator/wondershort.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedItem = 0;
  static const verte = Color(0xff226900);
  DateTime? lastPressed;
  final List<Widget> _pages = [
    const Menu(),
    const reservations(),
    const Wondershort(),
    const page_favoris(),
    const Profil()
  ];

  @override
  void initState() {
    super.initState();
  }

  void _changePage(int index) {
    setState(() {
      _selectedItem = index;
    });
  }

  Future<void> checkconnection() async {
    if (await Logique.checkInternetConnection()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Vous etes connecté à internet"),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Connectez-vous à internet"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        const maxDuration = Duration(seconds: 2);
        final isWarning =
            lastPressed == null || now.difference(lastPressed!) > maxDuration;

        if (isWarning) {
          lastPressed = DateTime.now();
          const snackbar = SnackBar(
            content: Text("Appuyez une deuxieme fois pour sortir"),
            duration: maxDuration,
          );

          ScaffoldMessenger.of(context).showSnackBar(snackbar);
          return false;
        }
        return true;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: _pages[_selectedItem],
          bottomNavigationBar: Container(
            padding: const EdgeInsets.only(bottom: 7, top: 7),
            decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : const Color(0xff323232),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey
                          : const Color(0xff323232),
                      offset: const Offset(0, 3),
                      blurRadius: 4)
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                        height: 35,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.linear,
                        decoration: _selectedItem == 0
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey.withValues(alpha:0.3)
                                    : const Color.fromARGB(255, 56, 56, 56),
                              )
                            : null,
                        child: IconButton(
                          onPressed: () => _changePage(0),
                          icon: Icon(
                            LucideIcons.layoutGrid,
                            size: 20,
                            color: _selectedItem == 0
                                ? verte
                                : Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey
                                    : Colors.white,
                          ),
                        )),
                    Text(
                      "Accueil",
                      style: GoogleFonts.jura(
                          textStyle: TextStyle(
                              fontSize: 10,
                              color: _selectedItem == 0 ? verte : Colors.grey,
                              fontWeight: _selectedItem == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    )
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                        height: 35,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.linear,
                        decoration: _selectedItem == 1
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey.withValues(alpha:0.3)
                                    : const Color.fromARGB(255, 56, 56, 56),
                              )
                            : null,
                        child: IconButton(
                          onPressed: () => _changePage(1),
                          icon: Icon(
                            LucideIcons.calendarClock,
                            size: 20,
                            color: _selectedItem == 1
                                ? verte
                                : Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey
                                    : Colors.white,
                          ),
                        )),
                    Text(
                      "Reservations",
                      style: GoogleFonts.jura(
                          textStyle: TextStyle(
                              fontSize: 10,
                              color: _selectedItem == 1 ? verte : Colors.grey,
                              fontWeight: _selectedItem == 1
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    )
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                        height: 35,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.linear,
                        decoration: _selectedItem == 2
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey.withValues(alpha:0.3)
                                    : const Color.fromARGB(255, 56, 56, 56),
                              )
                            : null,
                        child: IconButton(
                          onPressed: () => _changePage(2),
                          icon: Icon(
                            LucideIcons.listVideo,
                            size: 20,
                            color: _selectedItem == 2
                                ? verte
                                : Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey
                                    : Colors.white,
                          ),
                        )),
                    Text(
                      "Videos",
                      style: GoogleFonts.jura(
                          textStyle: TextStyle(
                              fontSize: 10,
                              color: _selectedItem == 2 ? verte : Colors.grey,
                              fontWeight: _selectedItem == 2
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    )
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                        height: 35,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.linear,
                        decoration: _selectedItem == 3
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey.withValues(alpha:0.3)
                                    : const Color.fromARGB(255, 56, 56, 56),
                              )
                            : null,
                        child: IconButton(
                          onPressed: () => _changePage(3),
                          icon: Icon(
                            LucideIcons.heart,
                            size: 20,
                            color: _selectedItem == 3
                                ? verte
                                : Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey
                                    : Colors.white,
                          ),
                        )),
                    Text(
                      "Favoris",
                      style: GoogleFonts.jura(
                          textStyle: TextStyle(
                              fontSize: 10,
                              color: _selectedItem == 3 ? verte : Colors.grey,
                              fontWeight: _selectedItem == 3
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    )
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                        height: 35,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.linear,
                        decoration: _selectedItem == 4
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey.withValues(alpha:0.3)
                                    : const Color.fromARGB(255, 56, 56, 56),
                              )
                            : null,
                        child: IconButton(
                          onPressed: () => _changePage(4),
                          icon: Icon(
                            LucideIcons.user,
                            size: 20,
                            color: _selectedItem == 4
                                ? verte
                                : Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey
                                    : Colors.white,
                          ),
                        )),
                    Text(
                      "Profil",
                      style: GoogleFonts.jura(
                          textStyle: TextStyle(
                              fontSize: 10,
                              color: _selectedItem == 4 ? verte : Colors.grey,
                              fontWeight: _selectedItem == 4
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
