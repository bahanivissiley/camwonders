// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:camwonders/services/camwonders.dart';
import 'debut_inscription.dart';
import 'package:camwonders/auth_pages/fin_inscription.dart';
import 'package:camwonders/firebase/firebase_logique.dart';
import 'package:camwonders/mainapp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';

// ignore: camel_case_types
class Suite_Inscription extends StatefulWidget {
  const Suite_Inscription(
      {super.key, required this.phoneNumber, required this.verificationId});
  final phoneNumber;
  final verificationId;

  @override
  State<Suite_Inscription> createState() => _Suite_InscriptionState();
}

// ignore: camel_case_types
class _Suite_InscriptionState extends State<Suite_Inscription>
    with CodeAutoFill {
  TextEditingController password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final pinController = TextEditingController();
  bool validate = false;
  DateTime? lastPressed;

  @override
  void codeUpdated() {
    setState(() {
      pinController.text = code!;
      if (code!.length == 6) {
        verifyotp(context, code!);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    listenForCode();
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        const maxDuration = Duration(seconds: 2);
        final isWarning =
            lastPressed == null || now.difference(lastPressed!) > maxDuration;

        if (isWarning) {
          lastPressed = DateTime.now();
          const snackbar = SnackBar(
            content:
                Text("Appuyez une deuxieme fois pour annuler l'inscription"),
            duration: maxDuration,
            backgroundColor: Colors.red,
          );

          ScaffoldMessenger.of(context).showSnackBar(snackbar);
          return false;
        } else {
          Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const Debut_Inscription(),
                  transitionsBuilder: (_, animation, __, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                              begin: Offset.zero, end: const Offset(1.0, 0.0))
                          .animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                              reverseCurve: Curves.easeInOutBack)),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 700)));
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(
              child: Text(
            "Confirmer numéro de téléphone",
            style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15)),
          )),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 430,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 150,
                          margin: const EdgeInsets.all(40),
                          child: Image.asset('assets/otp.png'),
                        ),
                        Text(
                          "Saisissez le code que vous avez reçu par SMS au ${widget.phoneNumber}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jura(
                              textStyle: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                        Pinput(
                          controller: pinController,
                          length: 6,
                          focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: focusedBorderColor),
                            ),
                          ),
                          submittedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              color: fillColor,
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(color: focusedBorderColor),
                            ),
                          ),
                          errorPinTheme: defaultPinTheme.copyBorderWith(
                            border: Border.all(color: Colors.redAccent),
                          ),
                        ),
                        Text(
                          "Vous n'avez pas reçu de code ?",
                          style: GoogleFonts.jura(
                              textStyle: const TextStyle(fontSize: 13)),
                        ),
                        GestureDetector(
                            onTap: () async {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      padding:
                                          EdgeInsets.only(top: height / 12),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Gif(
                                              height: 100,
                                              image: const AssetImage(
                                                  "assets/load.gif"),
                                              autostart: Autostart.loop,
                                            ),
                                            const Text(
                                                "Le message est entrain d'etre envoyé")
                                          ],
                                        ),
                                      ),
                                    );
                                  });

                              await AuthService().signInWithPhoneNumber(
                                  widget.phoneNumber, context);
                            },
                            child: Text(
                              "Envoyer à nouveau le code",
                              style: GoogleFonts.lalezar(
                                  textStyle: const TextStyle(
                                      fontSize: 15,
                                      decoration: TextDecoration.underline)),
                            ))
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: height / 300),
                  width: width,
                  child: TextButton(
                    onPressed: () async {

                      validate = true;

                      if (validate) {
                        verifyotp(context, pinController.text);
                      } else {
                        final snackBar = const SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Erreur',
                            message: 'Entrez un code a six chiffres!',

                            contentType: ContentType.warning,
                          ),
                        );

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(snackBar);
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(const Color(0xff226900)),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        shape: WidgetStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6))),
                        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.fromLTRB(0, 9, 0, 9))),
                    child: Text(
                      "Continuer",
                      style: GoogleFonts.lalezar(
                          textStyle: const TextStyle(fontSize: 17)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void verifyotp(BuildContext context, String otpCode) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Gif(
                    height: 100,
                    image: const AssetImage("assets/load.gif"),
                    autostart: Autostart.loop,
                    placeholder: (context) => const Text('Loading...'),
                  ),
                  const Text("Validation du code...")
                ],
              ),
            ),
          );
        });

    final String otp = otpCode;
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId, smsCode: otp);
      await _auth.signInWithCredential(credential);

      if (await Camwonder().checkIfUserExists(AuthService().currentUser!.uid, context)) {
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
                child: Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Gif(
                          height: 100,
                          image: const AssetImage("assets/succes.gif"),
                          autostart: Autostart.loop,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          child: Text("Connexion reussi !",
                              style: GoogleFonts.lalezar(
                                  textStyle: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff226900)))),
                        )
                      ],
                    ),
                  ),
                ),
              );
            });

        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => const MainApp(),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0), end: Offset.zero)
                        .animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                            reverseCurve: Curves.easeInOutBack)),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 700)));
      } else {
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => Fin_Inscription(
                      identifiant: widget.phoneNumber,
                    ),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0), end: Offset.zero)
                        .animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                            reverseCurve: Curves.easeInOutBack)),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 700)));
      }
    } catch (e) {
      // Gérez les erreurs d'authentification
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Container(
          height: 50,
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(10)),
          child: const Center(child: Text("Code incorrect !")),
        ),
        duration: const Duration(milliseconds: 3000),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ));
    }
  }
}
