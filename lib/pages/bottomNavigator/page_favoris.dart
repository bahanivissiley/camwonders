import 'package:cached_network_image/cached_network_image.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/pages/wonder_page.dart';
import 'package:camwonders/services/cachemanager.dart';
import 'package:camwonders/services/logique.dart';
import 'package:camwonders/shimmers_effect/menu_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool isLoading = true; // Indicateur de chargement

  @override
  void initState() {
    super.initState();
    _loadFavoris();
  }

  Future<void> _loadFavoris() async {
    await Future.delayed(Duration(seconds: 1)); // Simuler un temps de chargement
    favorisBox = Hive.box<Wonder>('favoris_wonder');
    setState(() {
      isLoading = false; // Les données sont chargées
    });
  }


  void supprimerFavorisWonder(int index) {
    favorisBox.deleteAt(index);
  }
  
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("MES WONDERS FAVORIS", style: GoogleFonts.lalezar(textStyle: const TextStyle(color: page_favoris.verte, fontSize: 23)),)),
      ),
      body: Container(
        child: isLoading
        ? const Center(child: CircularProgressIndicator(),)
        : ValueListenableBuilder(
          valueListenable: favorisBox.listenable(),
          builder: (context, Box<Wonder> box, _){
            if(box.values.isEmpty){
              return Center(child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.height/10,
                    child: Theme.of(context).brightness == Brightness.light ? Image.asset('assets/vide_light.png') : Image.asset('assets/vide_dark.png'),
                  ),
                  const Text("Pas de favoris")
                ],
              ));
            }

            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (BuildContext context, int index){
                final Wonder wonder = box.getAt(index)!;
                return Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: ((context) => WonderPage(wond: wonder))));
                      },
                      child: Dismissible(
                        key: Key(wonder.wonderName),
                      confirmDismiss: (DismissDirection direction) async {
                        return await showDialog<bool>(context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha:0.2),
                                          borderRadius: BorderRadius.circular(500)
                                      ),
                                      height: 80,
                                      width: 80,
                                      child: const Icon(Icons.help, size: 40, color: Colors.red,)
                                  ),
                                ],
                              ),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Suppression", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                                  Center(
                                      child: Text(
                                        "Etes vous sûr de vouloir supprimer cette element de la reservation ?",
                                        style: TextStyle(color: Colors.grey),
                                      ))
                                ],
                              ),

                              actions: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
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
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,

                                        )
                                      );
                                    },

                                  child: const Text("Supprimer")),
                                ),
                                TextButton(onPressed: () => Navigator.pop(context),
                                    child: Text("Annuler", style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),)),

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
                        margin: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: const Center(child: Icon(LucideIcons.trash, color: Colors.white,))
                      ),
                      child: favoris_widget(wond: wonder),)
                    ),

                    SizedBox(
                      height: 30,
                      width: 50,
                      child: IconButton(onPressed: () {
                        showDialog(context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha:0.2),
                                          borderRadius: BorderRadius.circular(500)
                                      ),
                                      height: 80,
                                      width: 80,
                                      child: const Icon(Icons.help, size: 40, color: Colors.red,)
                                  ),
                                ],
                              ),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Suppression", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                                  Center(
                                      child: Text(
                                        "Etes vous sûr de vouloir supprimer cette element de la reservation ?",
                                        style: TextStyle(color: Colors.grey),
                                      ))
                                ],
                              ),

                              actions: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
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
                                              duration: const Duration(seconds: 1),
                                              behavior: SnackBarBehavior.floating,
                                              backgroundColor: Colors.transparent,
                                              elevation: 0,

                                            )
                                        );
                                      },

                                      child: const Text("Supprimer")),
                                ),
                                TextButton(onPressed: () => Navigator.pop(context),
                                    child: Text("Annuler", style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),)),

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
    return Container(
      width: MediaQuery.of(context).size.width*4/5,
      margin: const EdgeInsets.only(bottom: 10, left: 10,),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha:0.5)
        )
      ),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: MediaQuery.of(context).size.width / 4,
            width: MediaQuery.of(context).size.width / 4,
            margin: const EdgeInsets.only(right: 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: CachedNetworkImage(
                cacheManager: CustomCacheManager(),
                imageUrl: wond.imagePath,
                placeholder: (context, url) => Center(child: shimmerOffre(width: MediaQuery.of(context).size.width / 4, height: MediaQuery.of(context).size.width / 4)),
                errorWidget: (context, url, error) =>
                const Center(child: Icon(Icons.error)),
                fit: BoxFit.cover,
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
    );
  }
}