import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:camwonders/fin_inscription.dart';
//import 'package:camwonders/firebase_logique.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';


// ignore: camel_case_types
class Suite_Inscription extends StatefulWidget{
  const Suite_Inscription({super.key});

  @override
  State<Suite_Inscription> createState() => _Suite_InscriptionState();
}

// ignore: camel_case_types
class _Suite_InscriptionState extends State<Suite_Inscription> {
  static const verte = Color(0xff226900);
  TextEditingController password=TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() async {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    //final TextEditingController codeController = TextEditingController();
    String codeNumber = '123456';


    return Scaffold(

      appBar: AppBar(
        title: Center(child: Text("Confirmer numéro de téléphone", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15)),)),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Saisissez le code que vous avez reçu par SMS au 6 90 25 91 37", textAlign: TextAlign.center , style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),),
                        Container(
                          width: width/2,
                          margin: const EdgeInsets.only(top: 10),
                          child: TextFormField(
                            //controller: codeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            enableSuggestions: false,
                            decoration: const InputDecoration(
                              hintText: "------",
                              contentPadding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                              border: OutlineInputBorder(),
                            ),
                            style: TextStyle(
                              letterSpacing: width/22
                            ),
                    
                            validator: (value) {
                              // ignore: non_constant_identifier_names
                              var NonNullValue=value??"";
                              if(NonNullValue.length < 6){
                                return "Le code ne correspond pas";
                              }
                              else if(NonNullValue != codeNumber){
                                return "Le code ne correspond pas";
                              }
                    
                              return null;
                            },
                    
                    
                          ),
                        ),
                    
                        Text("Vous n'avez pas reçu de code ?", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15)),),
                        Text("Envoyer à nouveau le code", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 15, decoration: TextDecoration.underline)),)
                    
                    
                      ],
                    ),
                  ),
                ),
          
          
                Container(
                  padding: EdgeInsets.only(top: height/300),
                  width: width,
                  child: TextButton(
                    onPressed: () async {
          
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
          
                                        const Text("Validation du code...")
                                      ],
                                    ),
                                  ),
                                );
                              }
                            );
          
                            await Future.delayed(const Duration(seconds: 3));
          
                            final snackBar = SnackBar(
                                /// need to set following properties for best effect of awesome_snackbar_content
                                elevation: 0,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                content: AwesomeSnackbarContent(
                                  title: 'Success',
                                  message:
                                      'Verification du numéro reussi avec le code $codeNumber!',
          
                                  /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                  contentType: ContentType.success,
                                ),
                              );
          
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(snackBar);
          
          
          
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const Fin_Inscription(),
          
                        transitionsBuilder: (_,animation,__,child){
                          return SlideTransition(
                            position: Tween<Offset> (begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut, reverseCurve: Curves.easeInOutBack)),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 700)
          
                        ));
          
                      }
          
          
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(verte),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(0, 9, 0, 9))
                    ),
                    child: Text("Continuer", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 17)),),
                  ),
                ),
              ],
            ),
          ),
        )
      ),
      
    );
  }
}