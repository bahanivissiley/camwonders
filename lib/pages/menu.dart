import 'package:camwonders/connexion.dart';
import 'package:camwonders/firebase_logique.dart';
import 'package:camwonders/inscription.dart';
import 'package:flutter/material.dart';
import 'package:camwonders/pages/vues.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Menu extends StatefulWidget{

  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final List<Widget> pages = [
    const ListeVue(),
    const MapVue(),
  ];
  final List<String> notifications = [
    'Notification 1',
    'Notification 2',
    'Notification 3',
    // Ajoutez d'autres notifications selon vos besoins
  ];
  static const verte = Color(0xff226900);
  late PageController _pageController;

  int _currentPageIndex = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("CamWonders", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 27, color: verte)),),
        actions: [
          AuthService().currentUser == null ? Container(
            child: GestureDetector(
              onTap: (){
                 Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_,__,___) => const Inscription(),

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
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                decoration: BoxDecoration(
                  color: verte,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Se connecter", style: GoogleFonts.jura(textStyle: TextStyle(fontSize: 10, color: Colors.white)),),
                    Icon(LucideIcons.userPlus, size: 13, color: Colors.white,),
                  ],
                ),
              ),
            )
          ) : Container(),


          Container(
          margin: const EdgeInsets.only(right: 10),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 10, right: 8),
                child: Text(notifications.length.toString(), style: GoogleFonts.lalezar(textStyle: TextStyle(fontSize: 15)),)),
              PopupMenuButton<String>(
                icon: const Icon(LucideIcons.bell),
                itemBuilder: (BuildContext context) {
                  return notifications.map((String notification) {
                    return PopupMenuItem<String>(
                      value: notification,
                      child: Text(notification),
                    );
                  }).toList();
                },
                onSelected: (String notification) {
                  // Traitez la notification sélectionnée ici
                  showDialog(context: context, builder: (BuildContext context){
                    return AlertDialog(
                      title: Text(notification),
                      content: const Text("Contenu de la notification"),
                      actions: [
                        TextButton(
                          onPressed: (){
                          Navigator.pop(context);
                          }, child: const Text("Marquer comme lu")
                        ),
              
                        TextButton(
                          onPressed: (){
                          Navigator.pop(context);
                          }, child: const Text("Retour")
                        ),
                      ],
                    );
                  }
                  
                  );
                },
              ),
            ],
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
            Text("Home", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),),
            Container(
              width: width*7/8,
              padding: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20)
              ),
              child: TextField(
                decoration: const InputDecoration(
                  icon: Icon(LucideIcons.search, size: 20,),
                  hintText: "Rechercher",
                  border: InputBorder.none
                ),

                style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
        
        
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