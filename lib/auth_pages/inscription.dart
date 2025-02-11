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
    final Size size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;
    setState(() {
      widthgif = width;
      heightgif = height;
    });
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            padding: const EdgeInsets.all(50),
            margin: EdgeInsets.only(top: height/5),
            child: Image.asset("assets/load2.png"),
          ),
          Container(
            margin: const EdgeInsets.all(30),
            child: Column(
              children: [
                Center(child: Text("Decouvrez le cameroun dans toute sa splendeur", textAlign: TextAlign.center, style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 30, height: 1.3)),)),
                const SizedBox(height: 20,),
                Center(child: Text("Vous rêvez d’explorer des paysages époustouflants, de plonger dans des cultures riches ? Camwonders est là pour transformer votre expérience de voyage.", textAlign: TextAlign.center, style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 12)),)),
              ],
            ),
          )
        ],
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
                backgroundColor: WidgetStateProperty.all(verte),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(0, 12, 0, 12))
              ),
              child: Text("Inscription/Connexion", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 17)),),
            ),
          ),
      
      
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            margin: const EdgeInsets.only(bottom: 10),
            width: width,
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
                foregroundColor: WidgetStateProperty.all(verte),
                shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))),
                side: WidgetStateProperty.all<BorderSide>(const BorderSide(color: verte, width: 3.0)),
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(0, 15, 0, 15)),
              ),
              onPressed: (){
                Navigator.pushAndRemoveUntil(context, PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const MainApp(),
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