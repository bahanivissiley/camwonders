import 'dart:async';

import 'package:camwonders/auth_pages/inscription.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CarouselPage {
  final String title;
  final String content;

  CarouselPage({required this.title, required this.content});
}

class Welcome extends StatefulWidget{
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final List<CarouselPage> pages = [
    CarouselPage(
      title: 'Decouvrir le cameroun',
      content: "Passerelle virtuelle qui ouvre les portes du Cameroun à ses utilisateurs, leur offrant une expérience de découverte unique et immersive",
    ),
    CarouselPage(
      title: 'Diversité des Lieux ',
      content: 'Des destinations touristiques célèbres aux coins cachés moins connus, Notre plateforme offre une diversité inégalée.',
    ),
    CarouselPage(
      title: 'Authenticité unique',
      content: "Camwonders se distingue par sa mise en avant d'aspects culturels et naturels authentique",
    ),
  ];

  final List<String> pathList1 = <String> ['assets/img1.jpg', 'assets/img2.jpg', 'assets/img3.jpg', 'assets/img4.jpg', 'assets/img13.jpg', 'assets/img12.jpg'];
  final List<String> pathList2 = <String> ['assets/img12.jpg', 'assets/img9.jpg', 'assets/img8.jpg', 'assets/img5.jpg', 'assets/img13.jpg', 'assets/img17.jpg'];
  final List<String> pathList3 = <String> ['assets/img11.jpg', 'assets/img10.jpg', 'assets/img7.jpg', 'assets/img6.jpg', 'assets/img15.jpg', 'assets/img16.jpg'];

  late PageController _pageController;
  static const verte = Color(0xff226900);

  int _currentPageIndex = 0;
  ScrollController _scrollController = ScrollController();
  Timer? _timer;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
     _timer = Timer.periodic(Duration(milliseconds: 800), (Timer timer) {
      if (_scrollController.hasClients) {
        _scrollOffset += 50.0; // Défilement de 100 pixels à chaque fois
        if (_scrollOffset >= _scrollController.position.maxScrollExtent) {
          _scrollOffset = 0.0;
        }
        _scrollController.animateTo(
          _scrollOffset,
          duration: Duration(milliseconds: 1100),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void goToNextPage() {
    if (_currentPageIndex < pages.length - 1) {
      setState(() {
        _currentPageIndex++;
        _currentPageIndex = _currentPageIndex; // Mise à jour de _currentPage
      });
      _pageController.animateToPage(
        _currentPageIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      Navigator.push(context, PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const Inscription(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
          return FadeTransition(opacity: animation, child: child,);
        }
        )
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final halfHeight = size.height/2;
    final width = size.width;
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              height: halfHeight,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),

              child: Row(
                children: [
                  SizedBox(
                    width: width/3,
                    child: ListView.builder(
                      //controller: _scrollController,
                      itemCount: pathList1.length,
                      itemBuilder: (BuildContext context, int index){
                        return FisrtCareeWonder(path: pathList1[index]);
                      }
                    ),
                  ),

                  SizedBox(
                    width: width/3,
                    child: ListView.builder(
                      //controller: _scrollController,
                      itemCount: pathList2.length,
                      itemBuilder: (BuildContext context, int index){
                        return FisrtCareeWonder(path: pathList2[index]);
                      }
                    ),
                  ),

                  SizedBox(
                    width: width/3,
                    child: ListView.builder(
                      //controller: _scrollController,
                      itemCount: pathList3.length,
                      itemBuilder: (BuildContext context, int index){
                        return FisrtCareeWonder(path: pathList3[index]);
                      }
                    ),
                  )
                ],
              ),
            ),

            SizedBox(
              height: halfHeight*2/3,
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPageIndex = page;
                  });
                },
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: EdgeInsets.all(halfHeight/12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          page.title,
                          style: GoogleFonts.lalezar(
                            textStyle: const TextStyle(
                              fontSize: 28.3,
                              color: verte,
                            )
                          ),
                        ),
                        Text(
                          page.content,
                          style: GoogleFonts.jura(
                            textStyle: const TextStyle(
                              fontSize: 16.0,
                            )
                          ),
                        ),
                        const SizedBox(height: 10.0),
                      ],
                    ),
                  );
                },
              ),
            ),

            Column(
              children: [
                SizedBox(
                  height: halfHeight/45,
                  width: size.width/6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(pages.length, (index) {
                      return Container(
                        width: size.width/30,
                        height: halfHeight/45,
                        //margin: EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPageIndex == index ? verte : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ),
                Container(
                  height: halfHeight/3 - halfHeight/45,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(onPressed: (){
                        Navigator.push(context, PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const Inscription(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                            return FadeTransition(opacity: animation, child: child,);
                          }
                          )
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                        foregroundColor: MaterialStateProperty.all(verte),
                        shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))),
                        side: MaterialStateProperty.all<BorderSide>(const BorderSide(color: verte, width: 3.0)),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(50, 15, 50, 15)),
                      ),
                      child: const Text("Passer", style: TextStyle(fontSize: 17),)),
                      ElevatedButton(onPressed: goToNextPage, style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(50, 15, 50, 15)), child: const Text("Suivant", style: TextStyle(fontSize: 17),),),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}


class FisrtCareeWonder extends StatelessWidget{
  const FisrtCareeWonder({super.key, required this.path});
  final String path;


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.all(5),
      height: size.height/6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        image: DecorationImage(
          image: AssetImage(path),
          fit: BoxFit.cover
          ),
      ),
    );
  }
}