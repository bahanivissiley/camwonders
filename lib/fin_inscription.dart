import 'package:camwonders/mainapp.dart';
import 'package:camwonders/policies.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';


// ignore: camel_case_types
class Fin_Inscription extends StatefulWidget{
  const Fin_Inscription({super.key});

  @override
  State<Fin_Inscription> createState() => _Fin_InscriptionState();
}

// ignore: camel_case_types
class _Fin_InscriptionState extends State<Fin_Inscription> {
  bool isChecked = false;
  Color checkcolor = Colors.black;
  bool _isObscure1 = true;
  bool _isObscure2 = true;
  bool light = true;
  static const verte = Color(0xff226900);
  TextEditingController password=TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  String password1 = '';
  String password2 = '';

  @override
  Widget build(BuildContext context){
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    return Scaffold(
      appBar: AppBar(
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: SizedBox(
          height: height,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(30, 0, 30, height/20),
                height: height,
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: height/50),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                            
                                Text("Choissisez un mot de passe", style: GoogleFonts.jura(textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),),
                            
                                Container(
                                  width: width*5/6,
                                  margin: const EdgeInsets.only(top: 10),
                                  child: TextFormField(
                                    controller: password,
                                    // ignore: non_constant_identifier_names
                                    validator: (PassCurrentValue){
                                      RegExp regex1=RegExp(r'^(?=.*?[A-Z]).{8,}$');
                                      RegExp regex2=RegExp(r'^(?=.*?[a-z]).{8,}$');
                                      RegExp regex3=RegExp(r'^(?=.*?[0-9]).{8,}$');
                                      RegExp regex4=RegExp(r'^(?=.*?[!@#\$&*~]).{8,}$');
                                      var passNonNullValue=PassCurrentValue??"";
                                      if(passNonNullValue.isEmpty){
                                        return ("Mot de passe requis");
                                      }
                                      else if(passNonNullValue.length<6){
                                        return ("Le mot de passe doit avoir plus de 6 caracteres");
                                      }
                                      else if(!regex1.hasMatch(passNonNullValue)){
                                        return ("Le mot de passe doit contenir au moins une majuscule");
                                      }
                                      else if(!regex2.hasMatch(passNonNullValue)){
                                        return ("Le mot de passe doit contenir au moins une minuscule");
                                      }
                                      else if(!regex3.hasMatch(passNonNullValue)){
                                        return ("Le mot de passe doit contenir au moins un chiffre ");
                                      }
                                      else if(!regex4.hasMatch(passNonNullValue)){
                                        return ("Le mot de passe doit contenir un caractere special");
                                      }
                                      return null;
                                    },
                                    obscureText: _isObscure1,
                                    enableSuggestions: false,
                                    decoration: InputDecoration(
                                      labelText: "Créer un mot de passe",
                                      border: const OutlineInputBorder(borderSide: BorderSide(width: 2, color: Colors.white12)),
                                      contentPadding: const EdgeInsets.fromLTRB(20, 15, 10, 15),
                                      suffixIcon: IconButton(
                                      icon: Icon(_isObscure1 ? LucideIcons.eye : LucideIcons.eyeOff, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _isObscure1 = !_isObscure1;
                                        });
                                      },
                                    ),
                                    ),
                                    onChanged: (PassCurrentValue){
                                      password1 = PassCurrentValue;
                                    },
                            
                                  ),
                                ),
                            
                            
                                Container(
                                  width: width*5/6,
                                  margin: const EdgeInsets.only(top: 10),
                                  child: TextFormField(
                                    validator: (PassCurrentValue){
                                      var passNonNullValue=PassCurrentValue??"";
                                      if(passNonNullValue.isEmpty){
                                        return "Confirmer le mot de passe";
                                      }else if(passNonNullValue != password1){
                                        return "Les deux mots de passe ne correspondent pas";
                                      }
                                      return null;
                                    },
                                    obscureText: _isObscure2,
                                    enableSuggestions: false,
                                    decoration: InputDecoration(
                                      labelText: "Confirmer le mot de passe",
                                      contentPadding: const EdgeInsets.fromLTRB(20, 15, 10, 15),
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                      icon: Icon(_isObscure2 ? LucideIcons.eye : LucideIcons.eyeOff, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _isObscure2 = !_isObscure2;
                                        });
                                      },
                                    ),
                                    ),
                                  ),
                                ),
                            
                            
                              ],
                            ),
                          ),
                        ),

                        Row(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              activeColor: verte,
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              }
                            ),

                            Expanded(
                              child: RichText(text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "J’ai lu et accepté ",
                                    style: GoogleFonts.jura(textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isChecked ? Colors.black : Colors.red))
                                  ),
                                  TextSpan(
                                    text: "termes et conditions d’utilisation",
                                    style: GoogleFonts.jura(textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: isChecked ? Colors.black : Colors.red)),
                                    recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const policies(),
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
                            )
                          ],
                        ),
                      ],
                    ),


                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: height/50),
                          width: width,
                          child: TextButton(
                            onPressed: () async {

                              if(_formKey.currentState!.validate()){

                                if(isChecked){

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

                                              Text("Inscription en cours....", style: GoogleFonts.lalezar(textStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: verte))),

                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  );

                                  await Future.delayed(const Duration(seconds: 3));
                                  
                                  Navigator.pop(context);

                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
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
                                                  margin: EdgeInsets.only(top: 15),
                                                  child: Text("Inscription reussi", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: verte))),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  );

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
                                  setState(() {
                                    checkcolor = Colors.red;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    
                                    SnackBar(
                                      content: Container(
                                      height: 50,
                                      width: width,
                                      decoration: BoxDecoration(
                                        color: Colors.red,borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Center(child: Text("Veillez cocher la case : conditions d'utilisations")),
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
                              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(0, 12, 0, 12))
                            ),
                            child: Text("S'inscrire", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 18)),),
                          ),
                        ),


                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Switch(value: light, activeColor: const Color.fromARGB(255, 13, 94, 6), onChanged: (bool value){
                              setState(() {
                                light = value;
                              });
                            }),

                            SizedBox(
                              width: width*2/3,
                              child: Text("J'accepte recevoir toutes les offres et newsletter dans ma boite mail et ou mon numero de telephone", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 10))))
                          ],
                        )
                      ],
                    )

                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}