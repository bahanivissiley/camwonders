//import 'dart:async';
import 'package:camwonders/pages/wonder_page.dart';
import 'package:flutter/material.dart';
import 'package:camwonders/class/classes.dart';
import 'package:camwonders/donneesexemples.dart';
//import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Sttories extends StatefulWidget{
  static const verte = Color(0xff226900);
  final Wonder wond;
  const Sttories({super.key, required this.wond});

  @override
  State<Sttories> createState() => _StoriesState(wond: wond);
}

class _StoriesState extends State<Sttories> {

  _StoriesState({required this.wond});
  final Wonder wond;
  int _currentPageIndex = 0;
  final PageController _pageStorieController = PageController();



  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageStorieController.dispose();
    super.dispose();
  }

  String truncate(String text){
    if(text.length > 35){
      return "${text.substring(0, 35)}...";
    }
    return text;
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    final List<Img> listeimages = images.where((img) => img.wonder == wond).toList();
    const verte = Color(0xff226900);
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(

            onTapDown: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            final tapPosition = details.globalPosition.dx;
            if (tapPosition < screenWidth / 2) {
              // Balayage vers la gauche
              _pageStorieController.previousPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            } else {
              // Balayage vers la droite
              _pageStorieController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            }
          },
            child: PageView.builder(
              controller: _pageStorieController,
              itemCount: listeimages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPageIndex = page;
                  });
                },
              itemBuilder: (context, index){
                return Sttorie(path: listeimages[index].path, wonderName: wond.wonderName,);
              }
            ),
          ),


          SizedBox(
            height: height,
            width: width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: width,
                  margin: const EdgeInsets.only(top: 30, left: 15),
                  child: Column(
                    children: [
                      Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: width/10,
                            child: IconButton(onPressed: (){
                              Navigator.pop(context);
                            }, icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 25,)),
                          ),
      
                          SizedBox(
                            height: height / 45,
                            width: width/10*8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(listeimages.length, (index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  width: size.width / (listeimages.length * 4/3), // Ajustement en fonction du nombre total d'éléments
                                  height: height / 300,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2)
                                      )
                                    ],
                                    color: _currentPageIndex == index ? Colors.white : const Color.fromARGB(255, 231, 231, 231).withOpacity(0.4),
                                  ),
                                );
                              }),
                            ),
                          ),

                        ],
                      ),


                      Text(truncate(wond.wonderName), style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 20, color: Colors.white)),)
                    ],
                  ),
                ),


                Container(
                  height: height/12,
                  width: width,
                  color: verte.withOpacity(0.7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: (){
                          Navigator.push(context, PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => wonder_page(wond: wond,),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                              return FadeTransition(opacity: animation, child: child,);
                            },

                            )
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                          side: MaterialStateProperty.all<BorderSide>(const BorderSide(color: Colors.white, width: 2.0)),
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(60, 10, 60, 10)),
                        ),
                        child: const Text("Visiter", style: TextStyle(fontSize: 17),)),
                    ],
                  )
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}




class Sttorie extends StatelessWidget{
  final String path;
  final String wonderName;

  const Sttorie({super.key, required this.path, required this.wonderName});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    return Hero(
      tag: "imageWonder$wonderName",
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(path),
            fit: BoxFit.cover
            ),
        ),
      ),
    );
  }
}