import 'package:camwonders/auth_pages/debut_inscription.dart';
import 'package:camwonders/class/Notification.dart';
import 'package:camwonders/class/Utilisateur.dart';
import 'package:camwonders/pages/NotificationsPage.dart';
import 'package:camwonders/pages/test.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:camwonders/firebase/firebase_logique.dart';
import 'package:flutter/material.dart';
import 'package:camwonders/pages/bottomNavigator/menu/vues.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

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
  Utilisateur? _user;
  bool _isLoading = true;
  String? _error;
  String _city = "CAMEROUN";

  List<Widget> pages = [
    ListeVue(),
    const MapVue(),
  ];


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
    loadData();
    _fetchUserInfo();

  }




  Future<void> _fetchUserInfo() async {
    try {
      final Utilisateur user = await Camwonder().getUserInfo();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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


  Future<Position> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifiez si les services de localisation sont activés.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de localisation sont désactivés.');
    }

    // Vérifiez les permissions de localisation.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Les permissions de localisation sont refusées.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Les permissions de localisation sont refusées de manière permanente.');
    }

    // Obtenez la position actuelle de l'utilisateur.
    return await Geolocator.getCurrentPosition();
  }


  Future<String> _getAddressFromLatLng(Position position) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      final Placemark place = placemarks[0];
      return "${place.country}";
    } catch (e) {
      return "Impossible d'obtenir l'adresse.";
    }
  }


  Future<void> _getUserCity() async {
    try {
      final Position position = await _getUserLocation();
      final String city = await _getAddressFromLatLng(position);
      setState(() {
        _city = city;
      });
    } catch (e) {
      setState(() {
        _city = "Impossible d'obtenir la ville.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: AuthService().currentUser == null ? Text("Bienvenu !", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15)),)
        : Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _user != null ? Text(truncate("Salut ${_user!.nom}", 25), style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15)),) : Shimmer.fromColors(
              baseColor: Theme.of(context).brightness == Brightness.light ? const Color.fromARGB(255, 215, 215, 215) : const Color.fromARGB(255, 63, 63, 63),
              highlightColor: Theme.of(context).brightness == Brightness.light ? const Color.fromARGB(255, 240, 240, 240) : const Color.fromARGB(255, 95, 95, 95),
              child: Container(
                height: 25,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10)
                ),
              )
              ),
            Container(
              child: Icon(LucideIcons.dot),
            ),
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
          AuthService().currentUser == null ? Container(
            child: GestureDetector(
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

                 Provider.of<NotificationProvider>(context, listen: false)
                     .addNotification("Nouvelle alerte", "Vous avez reçu un message !");

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
            )
          ) : Container(),
          
          Container(
            child: Consumer<NotificationProvider>(
              builder: (context, notificationProvider, _) {
                int unreadCount = notificationProvider.notifications
                    .where((notif) => !notif.isOpened)
                    .length;

                return Stack(
                  children: [
                    IconButton(
                      icon: Icon(LucideIcons.bellDot, size: 25,),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationsPage(),
                          ),
                        );
                      },
                    ),
                    if (unreadCount > 0) // Affiche le badge uniquement si non lues
                      Positioned(
                        right: 8,
                        top: 2,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: TextStyle(
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
                      border: Border.all(width: 1.0, color: verte
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