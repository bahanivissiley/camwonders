import 'package:camwonders/debut_inscription.dart';
import 'package:camwonders/firebase_logique.dart';
import 'package:camwonders/logique.dart';
import 'package:camwonders/mainapp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';


class Connexion extends StatefulWidget{
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  bool isChecked = false;
  bool _isObscure = true;
  static const verte = Color(0xff226900);
  final GlobalKey<FormState> _formKey = GlobalKey();
  String username = '';
  String password = '';
  String? errorMessage = '';
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
          },
          icon: const Icon(LucideIcons.arrowLeft)
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(child: Text("Connexion", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 30)),)),
                    Column(
                      children: [
                        Text("👋Content de vous revoir", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 25)),),
                        Text("Vous nous avez manquez, connectez vous, et continuez l’experience", textAlign: TextAlign.center, style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15)),),
                      ],
                      ),
                    Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          Container(
                            width: width*5/6,
                            margin: const EdgeInsets.only(top: 10),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Numéro ou email",
                                border: OutlineInputBorder(borderSide: BorderSide(width: 2, color: Colors.white12)),
                                contentPadding: EdgeInsets.fromLTRB(20, 15, 10, 15),
                              ),
                
                              onChanged: (value) {
                                setState(() {
                                  username = value;
                                });
                              },
                
                              validator: (value){
                                // ignore: non_constant_identifier_names
                                var NonNullValue=value??"";
                                if(NonNullValue.isEmpty){
                                  return "le numero ou email, ne peut etre vide";
                                }
                                return null;
                              },
                            ),
                          ),
                      
                      
                          Container(
                            width: width*5/6,
                            margin: const EdgeInsets.only(top: 10),
                            child: TextFormField(
                              obscureText: _isObscure,
                              enableSuggestions: false,
                              decoration: InputDecoration(
                                labelText: "Mot de passe",
                                border: const OutlineInputBorder(borderSide: BorderSide(width: 2, color: Colors.white12)),
                                contentPadding: const EdgeInsets.fromLTRB(20, 15, 10, 15),
                                suffixIcon: IconButton(
                                icon: Icon(_isObscure ? LucideIcons.eye : LucideIcons.eyeOff),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                              ),
                              ),
                
                              onChanged: (value) {
                                setState(() {
                                  password = value;
                                });
                              },
                
                              validator: (value){
                                // ignore: non_constant_identifier_names
                                var NonNullValue=value??"";
                                if(NonNullValue.isEmpty){
                                  return "Renseignez un mot de passe";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                            
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text("mot de passe oublié ?", style: GoogleFonts.lalezar(textStyle: const TextStyle(color: verte, fontSize: 17, decoration: TextDecoration.underline)),),
                    ),
                            
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      width: width,
                      child: TextButton(
                        onPressed: () async{

                          if(_formKey.currentState!.validate()){
                            showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        height: height/3,
                                        padding: EdgeInsets.only(top:height/12),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Gif(
                                                  height: 100,
                                                  image: const AssetImage("assets/load1.gif"),
                                                  autostart: Autostart.loop,
                                                  placeholder: (context) => const Text('Loading...'),
                                              ),

                                              Text("Verificaation des informations....", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: verte))),

                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  );

                                    String usernameSansespace = username.replaceAll(' ', '');
                                    String passwordSansespace = password.replaceAll(' ', '');
                                    User? user = await AuthService().signInWithEmailAndPassword(usernameSansespace, passwordSansespace);
                                    Navigator.pop(context);
                                    if(user != null){
                                      showModal(context, height);

                                      await Future.delayed(const Duration(seconds: 2));

                                      Navigator.pop(context);
                                      Navigator.push(context, PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) => const MainApp(),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                                            return FadeTransition(opacity: animation, child: child,);
                                          }
                                        )
                                      );

                                    }else{

                                      ScaffoldMessenger.of(context).showSnackBar(
                                      
                                        SnackBar(
                                          content: Container(
                                          height: 50,
                                          width: width,
                                          decoration: BoxDecoration(
                                            color: Colors.red,borderRadius: BorderRadius.circular(10)
                                          ),
                                          child: Center(child: Text("Informations de connexions incorrects")),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        
                                        )
                                      );

                                    }


                          }


                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(verte),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(0, 9, 0, 9))
                        ),
                        child: Text("Se connecter", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 17)),),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: RichText(text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Vous n'avez pas de compte ? ",
                            style: GoogleFonts.jura(textStyle: TextStyle(fontSize: 15, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white))
                          ),
                          TextSpan(
                            text: "S'inscrire",
                            style: GoogleFonts.lalezar(textStyle: const TextStyle(color: verte, fontSize: 17)),
                            recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const Debut_Inscription(),
                              transitionsBuilder: (_,animation, __, child){
                                  return SlideTransition(
                                    position: Tween<Offset> (begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut, reverseCurve: Curves.easeInOutBack)),
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 700),
                              ));
                            }
                          )
                        ]
                      )),
                    ),

                    Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          SizedBox(
                            width: width*5/6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: width*5/6*3/5,
                                  child: TextButton(
                                    onPressed: () async {
                                      await AuthService().signInWithGoogle();
                                    //Navigator.of(context).pop();

                                  },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                      foregroundColor: MaterialStateProperty.all(Colors.black),
                                      shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                      side: MaterialStateProperty.all<BorderSide>(const BorderSide(color: verte)),
                                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(0, 15, 0, 15))
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(right: 10),
                                          height: 20,
                                          width: 20,
                                          child: Image.asset("assets/google.png"),
                                        ),
                                        Text("S'inscrire avec google", style: GoogleFonts.jura(textStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white)),)
                                      ],
                                    )
                                  ),
                                ),
                            
                            
                                SizedBox(
                                  width: width*5/6/3/2,
                                  child: TextButton(onPressed: null,
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                      foregroundColor: MaterialStateProperty.all(Colors.black),
                                      shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                      side: MaterialStateProperty.all<BorderSide>(const BorderSide(color: verte)),
                                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(0, 15, 0, 15))
                                    ),
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: Image.asset("assets/facebook.png"),
                                    )
                                  ),
                                ),
                            
                            
                                SizedBox(
                                  width: width*5/6/3/2,
                                  child: TextButton(onPressed: null,
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                      foregroundColor: MaterialStateProperty.all(Colors.black),
                                      shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                      side: MaterialStateProperty.all<BorderSide>(const BorderSide(color: verte)),
                                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(0, 15, 0, 15))
                                    ),
                                    child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: Theme.of(context).brightness == Brightness.light ? Image.asset("assets/logo-apple-dark.png") : Image.asset("assets/logo-apple-white.png"),
                                    )
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> showModal(BuildContext context, double height) {
    return showModalBottomSheet(
                                      // ignore: use_build_context_synchronously
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeIn,
                                          child: Container(
                                            height: height/3,
                                            padding: EdgeInsets.only(top:height/12),
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  Gif(
                                                      height: 100,
                                                      image: const AssetImage("assets/succes1.gif"),
                                                      autostart: Autostart.loop,
                                                      placeholder: (context) => const Text('Loading...'),
                                                  ),
                                          
                                                  Container(
                                                    margin: const EdgeInsets.only(top: 15),
                                                    child: Text("Connexion reussi", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: verte))),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    );
  }
}