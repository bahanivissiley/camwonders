import 'package:camwonders/mainapp.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'debut_inscription.dart';


class Inscription extends StatefulWidget{
  const Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  static const verte = Color(0xff226900);
  static double heightgif = 0.0;
  double widthgif = 0.0;
  double su = heightgif/27;
  TextEditingController password=TextEditingController();

    @override
  void initState() {
    super.initState();
    _animategif();
  }

  Future _animategif () async {
    for (int i = 0; i < 5000; i++) {
      if(mounted){
        setState(() {
        su = heightgif/30;
      });
      }
      await Future.delayed(const Duration(seconds: 1));
      if(mounted){
        setState(() {
        su = heightgif/35;
      });
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    setState(() {
      widthgif = width;
      heightgif = height;
    });
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: 780,
            padding: EdgeInsets.only(top: height/8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text("Camwonders", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 40, color: verte), ),),
                    Container(
                      padding: EdgeInsets.only(top: height/200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("👋Bienvenue", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 30)),),
                          SizedBox(
                            width: size.width*2/3,
                            child: Center(child: Text("Commencez par vous inscrire pour garder une trace de vos activites", textAlign: TextAlign.center, style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15)),))),
                        ],
                        )
                      ),

                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      curve: Curves.fastOutSlowIn,
                      margin: EdgeInsets.only(top:height/15),
                      padding: EdgeInsets.fromLTRB(su, 20, su, 20),
                      width: height/2-30,
                      child: Image.asset(
                            'assets/locategirl.png',
                            ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    
    bottomNavigationBar:
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            width: width,
            child: TextButton(
              onPressed: (){
                //MaterialPageRoute(builder: (context) => const Connexion())
                Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const Debut_Inscription(),
                  
                transitionsBuilder: (_,animation,__,child){
                  return SlideTransition(
                    position: Tween<Offset> (begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut, reverseCurve: Curves.easeInOutBack)),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 700)
                  
                ));
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(verte),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(0, 12, 0, 12))
              ),
              child: Text("Inscription/Connexion", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 17)),),
            ),
          ),
      
      
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            margin: EdgeInsets.only(bottom: 10),
            width: width,
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                foregroundColor: MaterialStateProperty.all(verte),
                shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))),
                side: MaterialStateProperty.all<BorderSide>(const BorderSide(color: verte, width: 3.0)),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(0, 15, 0, 15)),
              ),
              onPressed: (){
                Navigator.pushAndRemoveUntil(context, PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => MainApp(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                    return FadeTransition(opacity: animation, child: child,);
                  }
                  ),
                  (Route<dynamic> route) => false
                );
              },
              child: const Text("Commencer sans m'inscrire",),
            ),
          ),
        ],
      ),
    );
  }
}