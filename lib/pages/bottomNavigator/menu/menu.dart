import 'package:camwonders/auth_pages/debut_inscription.dart';
import 'package:camwonders/class/Notification.dart';
import 'package:camwonders/pages/NotificationsPage.dart';
import 'package:camwonders/firebase/firebase_logique.dart';
import 'package:camwonders/widgetGlobal.dart';
import 'package:flutter/material.dart';
import 'package:camwonders/pages/bottomNavigator/menu/vues.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Menu extends StatefulWidget{

  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  static const verte = Color(0xff226900);
  late PageController _pageController;

  int _currentPageIndex = 0;
  bool isLoading = false;
  final String _city = "CAMEROUN";

  List<Widget> pages = [
    const ListeVue(),
    const MapVue(),
  ];
  final FirebaseMessagingService _firebaseMessagingService =
  FirebaseMessagingService();


  @override
  void initState() {
    super.initState();
    _firebaseMessagingService.initialize(context);
    _pageController = PageController(initialPage: _currentPageIndex);
    loadData();
  }






  Future loadData() async{
    setState(() {isLoading = true;});
    await Future.delayed(const Duration(seconds: 1));

    if(mounted){
      setState(() {isLoading = false;});
    }
  }

  void goToNextPage() {
      setState(() {
        _currentPageIndex = 1; // Mise à jour de _currentPage
      });
      _pageController.animateToPage(
        _currentPageIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
  }


  void goToBackPage() {
      setState(() {
        _currentPageIndex = 0; // Mise à jour de _currentPage
      });
      _pageController.animateToPage(
        _currentPageIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
  }

    String truncate(String text, int taille) {
    if (text.length > taille) {
      return "${text.substring(0, taille)}..";
    }
    return text;
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: AuthService().currentUser == null ? Text("Bienvenu !", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15)),)
        : Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(truncate("Salut ${userProvider.nom}", 25), style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15)),),
            const Icon(LucideIcons.dot),
            Row(
              children: [
                const Icon(LucideIcons.mapPin, color: verte, size: 15,),
                const SizedBox(width: 3,),
                Text(truncate(_city, 10), style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15)),),
              ],
            )
          ],
        ),
        actions: [
          AuthService().currentUser == null ? GestureDetector(
            onTap: (){
               Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const Debut_Inscription(),

                transitionsBuilder: (_,animation,__,child){
                  return SlideTransition(
                    position: Tween<Offset> (begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut, reverseCurve: Curves.easeInOutBack)),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 500)
                ));

            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: verte,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Se connecter", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 10, color: Colors.white)),),
                  const Icon(LucideIcons.userPlus, size: 13, color: Colors.white,),
                ],
              ),
            ),
          ) : Container(),
          
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              final int unreadCount = notificationProvider.notifications
                  .where((notif) => !notif.isOpened)
                  .length;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.bellDot, size: 25,),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0) // Affiche le badge uniquement si non lues
                    Positioned(
                      right: 8,
                      top: 2,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),


        ],
      ),



      body: Center(
          child: menu(width),
        ),
    );
  }


  Column menu(double width) {
    return Column(
          children: [

            Container(
              padding: const EdgeInsets.only(top: 20, bottom: 5),
              //height: height/10,

              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: (){
                      goToBackPage();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: _currentPageIndex == 0 ? const Border(
                          bottom: BorderSide(
                            color: verte,
                            width: 2.0
                          )
                        ) : null
                      ),
                      child: Text("Mode liste", style: GoogleFonts.jura(textStyle: TextStyle(fontWeight: FontWeight.bold, color: _currentPageIndex == 0 ? verte : null)),),
                    ),
                  ),

                  Container(
                    width: 2,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(color: verte
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: (){
                      goToNextPage();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: _currentPageIndex == 1 ? const Border(
                          bottom: BorderSide(
                            color: verte,
                            width: 2.0
                          )
                        ) : null
                      ),
                      child: Text("Mode Map", style: GoogleFonts.jura(textStyle: TextStyle(fontWeight: FontWeight.bold, color: _currentPageIndex == 1 ? verte : null)),),
                    ),
                  )
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int pageIndex){
                  _pageController.animateToPage(
                  pageIndex,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
                },
                itemCount: pages.length,
                itemBuilder: (context, index){
                  final page = pages[index];
                  return page;
                }
              ),
            )
          ],
        );
  }
}