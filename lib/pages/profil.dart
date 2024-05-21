import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:camwonders/connexion.dart';
import 'package:camwonders/firebase_logique.dart';
import 'package:camwonders/inscription.dart';
import 'package:camwonders/pages/page_favoris.dart';
import 'package:camwonders/policies.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Profil extends StatefulWidget{
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  bool light = false;
  static const verte = Color(0xff226900);
  String _selectedDevise = "FCFA";
  String _selectedlangue = "Français";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height/13),
        //height: MediaQuery.of(context).size.height-65,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(15),
                  height: MediaQuery.of(context).size.height/7,
                  width: MediaQuery.of(context).size.height/7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: Colors.grey,
                  ),
                ),
      
                Text("BAHANI VISSILEY THIERRY", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 18, color: verte)),),
      
                AuthService().currentUser == null ? GestureDetector(
                  onTap: (){
                    Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_,__,___) => const Inscription(),
                    
                  transitionsBuilder: (_,animation,__,child){
                    return SlideTransition(
                      position: Tween<Offset> (begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut, reverseCurve: Curves.easeInOutBack)),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 500)
                    
                  ));;
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Se connecter", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),),
                      const Icon(LucideIcons.userPlus, color: verte,)
                    ],
                  ),
                )
                : GestureDetector(
                  onTap: (){
                    null;
                  },
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Modifier mes informations", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),),
                          const Icon(LucideIcons.pencil, color: verte,)
                        ],
                      ),

                      Text(AuthService().currentUser!.email.toString(), style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),),
                    ],
                  )
                ),
      
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("DARKMODE", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 15)),),
                    Switch(value: light, activeColor: Colors.black, onChanged: (bool value){
                      AdaptiveTheme.of(context).toggleThemeMode();
                      setState(() {
                        light = value;
                      });
                    })
                  ],
                )
      
              ],
            ),
      
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(15.0),
                  child: ElevatedButton(
                    onPressed: ()=> Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => const page_favoris(),
                                  transitionsBuilder: (_,animation, __, child){
                                      return SlideTransition(
                                        position: Tween<Offset> (begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut, reverseCurve: Curves.easeInOutBack)),
                                        child: child,
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 700),
                                  )),
                  
                  child: Text("MES FAVORIES", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 15)),),),
                ),
                Column(
                  children: [



                    GestureDetector(
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {

                            return AlertDialog(
                              title: const Text("Changer la langue"),
                              content: DropdownButton<String>(
                                value: _selectedlangue,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedlangue = newValue!; // Mettez à jour la variable temporaire
                                  });
                                },
                                items: <String>[
                                  'Français',
                                  'English',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Annuler'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Fermez l'AlertDialog
                                  },
                                  child: const Text('Confirmer'),
                                ),
                              ],
                            );

                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.languages, color: verte,),
                                Text("Langues", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15))),
                              ],
                            ),
                            
                            Row(
                              children: [
                                Text(
                                  _selectedlangue,
                                  style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15)),
                                ),
                                const Icon(LucideIcons.chevronRight, color: verte),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
      
      
                    GestureDetector(
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) { // Créez une variable temporaire pour stocker la nouvelle valeur sélectionnée

                            return AlertDialog(
                              title: const Text("Changer la devise"),
                              content: DropdownButton<String>(
                                value: _selectedDevise,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedDevise = newValue!;
                                  });// Mettez à jour la variable temporaire
                                },
                                items: <String>[
                                  'FCFA',
                                  'Euro',
                                  'Dollar',
                                  'Dollar canadien',
                                  'Yen',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),

                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Annuler'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Fermez l'AlertDialog
                                  },
                                  child: const Text('Confirmer'),
                                ),
                              ],
                            );
                          },
                        );
                      },


                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.dollarSign, color: verte,),
                      
                                Text("Devises", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15))),
                              ],
                            ),
                            
                            Row(
                              children: [
                                Text(_selectedDevise, style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15)),),
                                IconButton(
                                  onPressed: () {
                                    null;
                                  },
                                
                                icon: const Icon(LucideIcons.chevronRight, color: verte,)
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
      
      
                    GestureDetector(
                      onTap: (){
                        showDialog(context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Demandez une assistance"),
                            content: const Text("Comment voulez-vous nous contacter pour assistance ?"),
                            actions: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(onPressed: null, child: const Text("Email")),
                                    ElevatedButton(onPressed: null, child: Text("WhatsApp")),
                                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Annuler")),
                                  ],
                                ),
                              ),
                            ],
                          );

                        }
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.helpCircle, color: verte,),
                                Text("Assistance", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15))),
                              ],
                            ),
                            
                            const Row(
                              children: [
                                IconButton(onPressed: null, icon: Icon(LucideIcons.chevronRight, color: verte,))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
      
      
                    GestureDetector(
                      onTap: () async {
                        if(AuthService().currentUser != null){
                          showDialog(context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: Center(child: Text("Deconnexion")),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.helpCircle, size: 70, color: Colors.red,),
                                  Center(child: Text("ETES VOUS SUR DE VOULOIR VOUS DECONNECTER ?", textAlign: TextAlign.center,))
                                ],
                              ),

                              actions: [
                                TextButton(
                                  onPressed: () =>  Navigator.of(context).pop(),
                                  child: const Text("Annuler")
                                ),

                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent
                                  ),
                                  onPressed: () async{
                                    await AuthService().signOut();
                                    Navigator.pushAndRemoveUntil(context,
                                      MaterialPageRoute(builder: (context) => Inscription()),
                                      (Route<dynamic> route) => false,
                                    );
                                  },
                                  child: Text("Deconnecter")
                                )
                              ],
                            );
                          }
                          );
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(child: Text("Vous n'etes pas connecté")),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green,
                            )
                            
                          );
                        }




                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Deconnexion", style: GoogleFonts.jura(textStyle: const TextStyle(color: Colors.red, fontSize: 15)))
                          ],
                        ),
                      ),
                    ),
      
      
                  ],
                )
              ],
            ),
      
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const policies()));
              },

              child: Text("Conditions d'utilisation", style: GoogleFonts.jura(textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: verte,)),),
            )
          ],
        ),
      ),
    );
  }
}