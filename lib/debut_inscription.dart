//import 'package:camwonders/firebase_logique.dart';
import 'package:camwonders/firebase_logique.dart';
import 'package:camwonders/suite_inscription.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:gif/gif.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';


class Debut_Inscription extends StatefulWidget{
  const Debut_Inscription({super.key});

  @override
  State<Debut_Inscription> createState() => _Debut_InscriptionState();
}

class _Debut_InscriptionState extends State<Debut_Inscription> {
  bool isChecked = false;
  final TextEditingController _phoneController = TextEditingController();
  static const verte = Color(0xff226900);
  TextEditingController password=TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  String phoneNumber = '';

  FocusNode focusNode = FocusNode();


  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    return Scaffold(
      appBar: AppBar(
      ),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            height: height,
            //padding: EdgeInsets.only(top: size.height/20),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: Column(
                    children: [
                      Center(child: Text("Inscription", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 25)),)),
          
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top:20),
                              width: width*5/6,
                              child: IntlPhoneField(
                                invalidNumberMessage: "Numéro de téléphone invalide",
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: "Numéro de téléphone",
                                  contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 20),
                                  border: OutlineInputBorder(),
                                ),
                                
                                initialCountryCode: 'CM',
                                controller: _phoneController,
                        
                                onChanged: (phone) {
                                  setState(() {
                                    phoneNumber = phone.completeNumber;
                                  });
                                },
                              ),
                            ),
                                
                          ],
                        ),
                      ),
          
          
                      Container(
                        padding: const EdgeInsets.all(5),
                        child: Text("Nous vous enverons un SMS pour confirmer votre numéro de téléphone. Des frais standards d'envoi de message de message et d'échange de données peuvent s'appliquer", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 13, height: 1.1, fontWeight: FontWeight.normal)),),
                      ),
          
                      
          
                      Container(
                        padding: EdgeInsets.only(top: height/300),
                        width: width,
                        child: TextButton(
                          onPressed: () async {
          
                            if(phoneNumber != '' && _formKey.currentState!.validate()){
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
          
                                          Container(
                                            child: Text("Le message est entrain d'etre envoyé"),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              );

                              print(phoneNumber);
                              print("Numero de telephone");


                              await FirebaseAuth.instance.verifyPhoneNumber(
                                phoneNumber: phoneNumber,
                                verificationCompleted: (PhoneAuthCredential credential) async {
                                  //await _auth.signInWithCredential(credential);
                                },
                                verificationFailed: (FirebaseAuthException e) {
                                },
                                codeSent: (String verificationId, int? resendToken) {
                                  Navigator.pop(context);
                                  Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => Suite_Inscription(),
                                  transitionsBuilder: (_,animation,__,child){
                                    return SlideTransition(
                                      position: Tween<Offset> (begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut, reverseCurve: Curves.easeInOutBack)),
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 700)
                                  ));
                                },
                                codeAutoRetrievalTimeout: (String verificationId) {},
                              );

                            }else{
                              final snackBar = SnackBar(
                                /// need to set following properties for best effect of awesome_snackbar_content
                                elevation: 0,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                content: AwesomeSnackbarContent(
                                  title: 'Erreur!',
                                  message:
                                      'Numero de téléphone invalide',
          
                                  /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                  contentType: ContentType.failure,
                                ),
                              );
          
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(snackBar);
                            }
          
                          },
          
          
          
          
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(verte),
                            foregroundColor: MaterialStateProperty.all(Colors.white),
                            shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(0, 9, 0, 9))
                          ),
                          child: Text("Envoyer le code", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 17)),),
                        ),
                      ),
          
          
          
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            height: 1.0,
                            width: width*4/11,
                            color: Colors.grey,
                          ),
          
                          const Text("ou"),
          
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            height: 1.0,
                            width: width*4/11,
                            color: Colors.grey,
                          ),
                        ],
                      ),
          
          
          
                      Center(
                        child: Container(
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
                                        onPressed: (){
                                          AuthService().signInWithGoogle();
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
                        ),
                      )
                    ],
                  ),
                ),
          
              ],
            ),
          ),
        ),
      ),
    
    );
  }
}