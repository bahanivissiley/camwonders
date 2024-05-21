
import 'package:camwonders/pages/menu.dart';
import 'package:camwonders/pages/profil.dart';
import 'package:camwonders/pages/wondershort.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
//import 'package:lucide_icons/lucide_icons.dart';

class MainApp extends StatefulWidget{
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedItem = 0;
  static const verte = Color(0xff226900);
  final List<Widget> _pages = [const Menu(), const Wondershort(), const Profil()];

  void _changePage(int index) {
    setState(() {
      _selectedItem = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _pages[_selectedItem],

      bottomNavigationBar: BottomAppBar(
        
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.linear,
              padding: const EdgeInsets.all(5),
              decoration: _selectedItem == 0 ? BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : const Color.fromARGB(255, 56, 56, 56),
              ) : null,
              child: IconButton(onPressed: () => _changePage(0), icon: const Icon(LucideIcons.layoutGrid, color: verte,),)
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.linear,
              padding: const EdgeInsets.all(5),
              decoration: _selectedItem == 1 ? BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : const Color.fromARGB(255, 56, 56, 56),
              ) : null,
              child: IconButton(onPressed: () => _changePage(1), icon: const Icon(LucideIcons.listVideo, color: verte,),)
            ),
                
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.linear,
              padding: const EdgeInsets.all(5),
              decoration: _selectedItem == 2 ? BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : const Color.fromARGB(255, 56, 56, 56),
              ) : null,
              child: IconButton(onPressed: () => _changePage(2), icon: const Icon(LucideIcons.user, color: verte,),)
            )
          ],
        ),
      )
    );
  }
}