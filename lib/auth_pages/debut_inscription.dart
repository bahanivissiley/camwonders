// ignore_for_file: use_build_context_synchronously, camel_case_types
import 'dart:async';
import 'package:camwonders/auth_pages/suite_inscription.dart';
import 'package:camwonders/class/Notification.dart';
import 'package:camwonders/main.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:camwonders/firebase/supabase_logique.dart';
import 'package:camwonders/services/logique.dart';
import 'package:camwonders/mainapp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:gif/gif.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Debut_Inscription extends StatefulWidget {
  const Debut_Inscription({super.key});

  @override
  State<Debut_Inscription> createState() => _Debut_InscriptionState();
}

class _Debut_InscriptionState extends State<Debut_Inscription> {
  bool isChecked = false;
  final TextEditingController _phoneController = TextEditingController();
  static const verte = Color(0xff226900);
  final GlobalKey<FormState> _formKey = GlobalKey();
  String phoneNumber = '';
  String contenupop = "Le message est entrain d'etre envoyé";

  FocusNode focusNode = FocusNode();

  void _verifyPhoneNumber() async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Veuillez patienter...'),
              ],
            ),
          );
        },
      );

      // Envoyer un code OTP au numéro de téléphone
      final response = await Supabase.instance.client.auth.signInWithOtp(
        phone: phoneNumber,
      );

      // Fermer l'indicateur de chargement
      Navigator.pop(context);

        // Rediriger vers l'écran de vérification du code OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Suite_Inscription(
              phoneNumber: phoneNumber,
            ),
          ),
        );
    } catch (e) {
      // Fermer l'indicateur de chargement en cas d'erreur
      Navigator.pop(context);

      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Une erreur est survenue : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: height,
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Inscription/Connection",
                  style: GoogleFonts.jura(
                      textStyle: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16.0),
                Column(
                  children: [
                    Text(
                      "👋Content de vous voir",
                      style: GoogleFonts.lalezar(
                          textStyle: const TextStyle(fontSize: 25)),
                    ),
                    Text(
                      "Rejoignez nous, et vivons l’experience camerounais autrement",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jura(
                          textStyle: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        width: width * 5 / 6,
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
                  child: Text(
                    "Nous vous enverons un SMS pour confirmer votre numéro de téléphone. Des frais standards d'envoi de message de message et d'échange de données peuvent s'appliquer",
                    style: GoogleFonts.jura(
                        textStyle: const TextStyle(
                            fontSize: 11,
                            height: 1.1,
                            fontWeight: FontWeight.normal)),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: height / 300),
                  width: width,
                  child: TextButton(
                    onPressed: () async {
                      if (_phoneController.text != '' &&
                          _formKey.currentState!.validate()) {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: height / 3,
                                padding: EdgeInsets.only(top: height / 12),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Gif(
                                        height: 100,
                                        image: const AssetImage(
                                            "assets/load.gif"),
                                        autostart: Autostart.loop,
                                      ),
                                      Text(contenupop)
                                    ],
                                  ),
                                ),
                              );
                            });

                        final bool isConnected =
                            await Logique.checkInternetConnection();

                        if (isConnected) {
                          _verifyPhoneNumber();
                        } else {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Center(
                                  child: Text("Connectez vous a internet !")),
                            ),
                            duration: const Duration(milliseconds: 3000),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ));
                        }
                      } else {
                        final snackBar = const SnackBar(
                          /// need to set following properties for best effect of awesome_snackbar_content
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Erreur!',
                            message: 'Numero de téléphone invalide',

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
                        backgroundColor: WidgetStateProperty.all(verte),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        shape: WidgetStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6))),
                        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.fromLTRB(0, 9, 0, 9))),
                    child: Text(
                      "Envoyer le code",
                      style: GoogleFonts.lalezar(
                          textStyle: const TextStyle(fontSize: 17)),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      height: 1.0,
                      width: width * 4 / 11,
                      color: Colors.grey,
                    ),
                    const Text("ou"),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      height: 1.0,
                      width: width * 4 / 11,
                      color: Colors.grey,
                    ),
                  ],
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: width,
                          child: TextButton(
                              onPressed: () async {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        height: height / 3,
                                        padding:
                                            EdgeInsets.only(top: height / 12),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Gif(
                                                height: 100,
                                                image: const AssetImage(
                                                    "assets/load.gif"),
                                                autostart: Autostart.loop,
                                              ),
                                              Text(
                                                  "Connexion Google en cours...",
                                                  style: GoogleFonts.lalezar(
                                                      textStyle:
                                                          const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: verte))),
                                            ],
                                          ),
                                        ),
                                      );
                                    });

                                final bool isConnected =
                                    await Logique.checkInternetConnection();

                                if (isConnected) {
                                  final googleUser = await AuthService().signInWithGoogle();
                                  if (googleUser !=
                                      null) {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            curve: Curves.easeIn,
                                            child: Container(
                                              height: height / 3,
                                              padding: EdgeInsets.only(
                                                  top: height / 12),
                                              child: Center(
                                                child: Column(
                                                  children: [
                                                    Gif(
                                                      height: 100,
                                                      image: const AssetImage(
                                                          "assets/succes.gif"),
                                                      autostart: Autostart.loop,
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 15),
                                                      child: Text(
                                                          "Authentification reussi",
                                                          style: GoogleFonts.lalezar(
                                                              textStyle: const TextStyle(
                                                                  fontSize: 30,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      verte))),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });

                                    Camwonder().createUser(
                                        googleUser.displayName,
                                        googleUser.email,
                                        AuthService().currentUser!.id,
                                        googleUser.photoUrl, context);
                                    await Future.delayed(
                                        const Duration(seconds: 2));

                                    Navigator.pop(context);
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                const MainApp(),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              animation = CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeIn);
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            }),
                                          (Route<dynamic> route) => false);
                                  } else {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: const Center(
                                            child: Text(
                                                "Une erreur est survenue, veillez reessayer !")),
                                      ),
                                      duration:
                                          const Duration(milliseconds: 3000),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                    ));
                                  }
                                } else {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: const Center(
                                          child: Text(
                                              "Connectez vous a internet !")),
                                    ),
                                    duration:
                                        const Duration(milliseconds: 3000),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                  ));
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                  foregroundColor:
                                      WidgetStateProperty.all(Colors.black),
                                  shape:
                                      WidgetStateProperty.all<OutlinedBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                  side: WidgetStateProperty.all<BorderSide>(
                                      const BorderSide(color: verte)),
                                  padding: WidgetStateProperty.all<
                                          EdgeInsetsGeometry>(
                                      const EdgeInsets.fromLTRB(0, 15, 0, 15))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    height: 20,
                                    width: 20,
                                    child: Image.asset("assets/google.png"),
                                  ),
                                  Text(
                                    "S'inscrire avec google",
                                    style: GoogleFonts.jura(
                                        textStyle: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.black
                                                    : Colors.white)),
                                  )
                                ],
                              )),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: width,
                          child: TextButton(
                              onPressed: () async {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        height: height / 3,
                                        padding:
                                            EdgeInsets.only(top: height / 12),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Gif(
                                                height: 100,
                                                image: const AssetImage(
                                                    "assets/load.gif"),
                                                autostart: Autostart.loop,
                                              ),
                                              Text(
                                                  "Connexion à Apple en cours...",
                                                  style: GoogleFonts.lalezar(
                                                      textStyle:
                                                          const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: verte))),
                                            ],
                                          ),
                                        ),
                                      );
                                    });

                                final bool isConnected =
                                    await Logique.checkInternetConnection();

                                if (isConnected) {
                                  final appleUser = await AuthService().signInWithApple();
                                  if(appleUser != null){
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            curve: Curves.easeIn,
                                            child: Container(
                                              height: height / 3,
                                              padding: EdgeInsets.only(
                                                  top: height / 12),
                                              child: Center(
                                                child: Column(
                                                  children: [
                                                    Gif(
                                                      height: 100,
                                                      image: const AssetImage(
                                                          "assets/succes.gif"),
                                                      autostart: Autostart.loop,
                                                    ),
                                                    Container(
                                                      margin:
                                                      const EdgeInsets.only(
                                                          top: 15),
                                                      child: Text(
                                                          "Authentification reussi",
                                                          style: GoogleFonts.lalezar(
                                                              textStyle: const TextStyle(
                                                                  fontSize: 30,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  color:
                                                                  verte))),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });

                                    Camwonder().createUser(
                                        appleUser.givenName,
                                        appleUser.email,
                                        appleUser.userIdentifier!,
                                        "dd", context);
                                    await Future.delayed(
                                        const Duration(seconds: 2));

                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            const MainApp(),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              animation = CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeIn);
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            }));
                                  }
                                                                } else {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: const Center(
                                          child: Text(
                                              "Connectez vous a internet !")),
                                    ),
                                    duration:
                                        const Duration(milliseconds: 3000),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                  ));
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                  foregroundColor:
                                      WidgetStateProperty.all(Colors.black),
                                  shape:
                                      WidgetStateProperty.all<OutlinedBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                  side: WidgetStateProperty.all<BorderSide>(
                                      const BorderSide(color: verte)),
                                  padding: WidgetStateProperty.all<
                                          EdgeInsetsGeometry>(
                                      const EdgeInsets.fromLTRB(0, 15, 0, 15))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    height: 20,
                                    width: 20,
                                    child: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Image.asset(
                                            "assets/logo-apple-dark.png")
                                        : Image.asset(
                                            "assets/logo-apple-white.png"),
                                  ),
                                  Text(
                                    "S'inscrire avec Apple",
                                    style: GoogleFonts.jura(
                                        textStyle: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.black
                                                    : Colors.white)),
                                  )
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
