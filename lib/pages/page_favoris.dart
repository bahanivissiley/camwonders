import 'package:camwonders/class/classes.dart';
import 'package:camwonders/donneesexemples.dart';
import 'package:camwonders/pages/wonder_page.dart';
import 'package:camwonders/logique.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

class page_favoris extends StatefulWidget {
  const page_favoris({super.key});
  static const verte = Color(0xff226900);

  @override
  State<page_favoris> createState() => _page_favorisState();
}

class _page_favorisState extends State<page_favoris> {
  late Box<Wonder> favorisBox;

  @override
  void initState() {
    super.initState();
    favorisBox = Hive.box<Wonder>('favoris_wonder');
  }

  void supprimerFavorisWonder(int index) {
    favorisBox.deleteAt(index);
  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("MES WONDERS FAVORIS", style: GoogleFonts.lalezar(textStyle: const TextStyle(color: page_favoris.verte, fontSize: 23)),)),
      ),
      body: Container(
        child: favorisBox == null
        ? const Center(child: CircularProgressIndicator(),)
        : ValueListenableBuilder(
          valueListenable: favorisBox.listenable(),
          builder: (context, Box<Wonder> box, _){
            if(box.values.isEmpty){
              return Center(child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: size.height/10,
                    child: Theme.of(context).brightness == Brightness.light ? Image.asset('assets/vide_light.png') : Image.asset('assets/vide_dark.png'),
                  ),
                  Text("Pas de favoris")
                ],
              ));
            }

            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (BuildContext context, int index){
                Wonder wonder = box.getAt(index)!;
                return Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: ((context) => wonder_page(wond: wonders[index]))));
                        },
                        child: Dismissible(key: Key(wonder.wonderName),
                        confirmDismiss: (DismissDirection direction) async {
                          return await showDialog<bool>(context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Center(child: Text("Suppression")),
                                content: Container(
                                  padding: EdgeInsets.all(20),
                                  height: 150,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Icon(LucideIcons.helpCircle, color: Colors.red, size: 50,),
                                      Container(
                                        child: Center(child: Text("Etes vous sur de vouloir supprimer ?", textAlign: TextAlign.center , style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),))
                                      )
                                    ],
                                  ),
                                ),
                      
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context),
                                  child: Text("Annuler", style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),)),
                      
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red
                                    ),
                                    onPressed: (){
                                      Navigator.pop(context);
                                      setState(() {
                                        Logique().supprimerFavorisWonder(index);
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Container(
                                            height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.red,borderRadius: BorderRadius.circular(10)
                                          ),
                                          child: const Center(child: Text("Element suprimé des Favoris !")),
                                        ),
                                        duration: Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        
                                        )
                                      );
                                    },
                                  
                                  child: const Text("Supprimer"))
                                ],
                              );
                            });
                        },
                        onDismissed: (direction){
                      
                          setState(() {
                                        Logique().supprimerFavorisWonder(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Container(
                                  height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.red,borderRadius: BorderRadius.circular(10)
                                ),
                                child: const Center(child: Text("Element suprimé des Favoris !")),
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              
                              )
                            );
                          
                          },
                      
                        background: Container(
                          margin: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Center(child: Text("Entrain d'etre supprimé...", style: TextStyle(color: Colors.white, fontSize: 20),))
                        ),
                        child: favoris_widget(wond: wonder),)
                      ),
                    ),

                    Container(
                      height: 30,
                      width: 50,
                      child: IconButton(onPressed: () {
                        showDialog(context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Center(child: Text("Suppression")),
                              content: Container(
                                padding: EdgeInsets.all(20),
                                height: 150,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(LucideIcons.helpCircle, color: Colors.red, size: 50,),
                                    Container(
                                      child: Center(child: Text("Etes vous sur de vouloir supprimer ?", textAlign: TextAlign.center , style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),))
                                    )
                                  ],
                                ),
                              ),

                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context),
                                child: Text("Annuler", style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),)),

                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red
                                  ),
                                  onPressed: (){
                                    Navigator.pop(context);
                                    setState(() {
                                      Logique().supprimerFavorisWonder(index);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Container(
                                          height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.red,borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: const Center(child: Text("Element suprimé des Favoris !")),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      
                                      )
                                    );
                                  },
                                
                                child: const Text("Supprimer"))
                              ],
                            );
                          });
                      }, icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20,)))
                
                  ],
                );
              }
            );
          }
        )
      ),
    );
  }
}

class favoris_widget extends StatelessWidget {
  const favoris_widget({
    super.key, required this.wond,
  });
  final Wonder wond;

  String truncate(String text){
    if(text.length > 20){
      return "${text.substring(0, 20)}...";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        //width: MediaQuery.of(context).size.width*4/5,
        margin: const EdgeInsets.only(bottom: 10, left: 10, right: 0,),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 1.0,
            color: Colors.grey.withOpacity(0.5)
          )
        ),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: MediaQuery.of(context).size.width/4,
              width: MediaQuery.of(context).size.width/4,
              margin: EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: AssetImage(wond.imagePath),
                    fit: BoxFit.cover
                  )
              ),
            ),
      
      
            Column(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(truncate(wond.wonderName), style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 18)),),
                    Text(wond.city, style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 13, color: page_favoris.verte)),),
                    SizedBox(
                      width: MediaQuery.of(context).size.width/3,
                      //height: 60,
                      child: Text(wond.description, maxLines: 2, style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 10)),)
                    )
                  ],
                ),
              ],
            ),
      
          ],
        ),
      ),
    );
  }
}