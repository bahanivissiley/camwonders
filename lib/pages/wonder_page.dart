import 'dart:io';

import 'package:camwonders/class/classes.dart';
import 'package:camwonders/donneesexemples.dart';
import 'package:camwonders/logique.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';

class wonder_page extends StatefulWidget{
  final Wonder wond;
  const wonder_page({super.key, required this.wond});

  @override
  State<wonder_page> createState() => _wonder_pageState(wond: wond);
}

class _wonder_pageState extends State<wonder_page> {
  int _currentPageIndex = 0;
  bool is_map = false;
  bool is_voir = false;
  final Wonder wond;
  final verte = const Color(0xff226900);

  final PageController _pageStorieController = PageController();

  _wonder_pageState({required this.wond});

  bool is_like = false;
  bool isKeyboardVisible = false;
  late Box<Wonder> favorisBox;


  @override
  void initState() {
    super.initState();
    favorisBox = Hive.box<Wonder>('favoris_wonders');
    bool estPresent = favorisBox.values.any((wonder_de_la_box) => wonder_de_la_box.idWonder == wond.idWonder);
    if(estPresent){
      is_like = true;
    }

    KeyboardVisibilityController().onChange.listen((bool visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
    });
  }

  @override
  void dispose() {
    _pageStorieController.dispose();
    super.dispose();
  }

  void SetFavorisWonder(Wonder wonder){
    favorisBox = Hive.box<Wonder>('favoris_wonders');
    favorisBox.add(wonder);
  }

  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = selectedImage;
    });

    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Text("Images selectionnees"),
        content: Image.file(File(_image!.path)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              showDialog(context: context,
              builder: (BuildContext context){
                return AlertDialog(
                  title: Text("Success"),
                  content: Container(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Gif(
                              height: 100,
                              image: const AssetImage("assets/succes1.gif"),
                              autostart: Autostart.loop,
                              placeholder: (context) => const Text('Loading...'),
                          ),

                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: Text("Images proposes avec succes", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                          )
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    Center(
                      child: ElevatedButton(onPressed: (){
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }, child: Text("Continuer")),
                    )
                  ],
                );
              });

            },

          child: Text("Soumettre"))
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final List<Img> listeimages = images.where((img) => img.wonder == widget.wond).toList();
    final List<AvantagesInconvenient> avantages = avIncs.where((aov) => aov.avantage == true && aov.wonder == wond).toList();
    final List<AvantagesInconvenient> inconvenients = avIncs.where((aov) => aov.avantage == false && aov.wonder == wond).toList();
    return Scaffold(
      appBar: AppBar(
        primary: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 30),
            width: size.width/5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: (){
                    setState(() {
                      if(is_like){
                        is_like = false;
                        Logique().supprimerFavorisWonder(favorisBox.length - 1);
                      }else{
                        SetFavorisWonder(wond);
                        is_like = true;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Container(
                              height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xff226900),borderRadius: BorderRadius.circular(10)
                            ),
                            child: const Center(child: Text("Element Ajouté aux Favoris !")),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          
                          )
                        );
                      }
                    });
                  },
                icon: is_like ? Icon(Icons.favorite, color: Colors.red,) : const Icon(Icons.favorite_border_rounded),),
                const Icon(Icons.share)
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
        padding: EdgeInsets.only(left: size.width/16, right: size.width/16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            is_map ? mapsWonder(size) : imagesWonder(size, listeimages),

            ligneAcces_btnCarte(size.width),

            Text(wond.wonderName, style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 24,)),),

            Row(
              children: [
                Text(wond.city, style: GoogleFonts.jura(),),
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  width: 1,
                  height: 10,
                  color: const Color(0xff226900),
                ),

                Text("24km", style: GoogleFonts.jura(textStyle: const TextStyle(fontWeight: FontWeight.bold)),),
              ],
            ),

            Container(
              margin:   const EdgeInsets.only(top: 10, bottom: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wond.description, maxLines: is_voir ? 1000 : 4, style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15,))),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        if (is_voir){
                          is_voir = false;
                        }else{
                          is_voir = true;
                        }
                      });
                    },

                    child: Text(is_voir ? "Voir moins" : "Voir plus", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 16, decoration: TextDecoration.underline       )),),
                  )
                ],
              )
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text("Avantages", style: GoogleFonts.lalezar(textStyle: TextStyle(fontSize: 18, color: verte)),),
              Container(
                padding: EdgeInsets.only(left: size.width/20, bottom: 20),

                child: Column(
                  children: List.generate(avantages.length, (index) =>
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(LucideIcons.checkCircle, color: verte, size: 17,)
                            ),
                            Text(avantages[index].content, style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                        ],
                      ),
                    )
                  )
                )
              )
            ],),


            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text("Inconvenients", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 18, color: Colors.red)),),
              Container(
                padding: EdgeInsets.only(left: size.width/20, bottom: 20),

                child: Column(
                  children: List.generate(inconvenients.length, (index) =>
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(LucideIcons.ban, color: verte, size: 17,)
                            ),
                            Text(inconvenients[index].content, style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                        ],
                      ),
                    )
                  )
                )
              )
            ],),

            Container(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text("Méteo", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 20,)),),
                  ),

                  Container(
                    width: size.width,
                    padding: EdgeInsets.fromLTRB(size.width/15, size.width/25, size.width/15, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text("Aujourd'hui", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 12,)),),
                            Icon(LucideIcons.cloud, size: 50, color: verte,),
                            Text("24°", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 18,)),),
                          ],
                        ),


                        Column(
                          children: [
                            Text("Demain", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 12,)),),
                            Icon(LucideIcons.sunMoon, size: 50, color: verte,),
                            Text("24°", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 18,)),),
                          ],
                        ),


                        Column(
                          children: [
                            Text("11/24", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 12,)),),
                            Icon(LucideIcons.cloudMoon, size: 50, color: verte,),
                            Text("24°", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 18,)),),
                          ],
                        ),

                        Column(
                          children: [
                            Text("12/24", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 12,)),),
                            Icon(LucideIcons.cloudRain, size: 50, color: verte,),
                            Text("24°", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 18,)),),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),


            Container(
              margin: EdgeInsets.all(size.width/100),
              child: Column(
                children: [
                  Text("Contribuer", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 20)),),

                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(onPressed: () => _showReviewDialog(context),
                      child: Text("Laisser un avis", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),),
                      ),

                      ElevatedButton(onPressed: (){
                        showDialog(context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            title: Text("Choisissez une methode"),
                            actions: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    onPressed: _pickImage,
                                    child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.image, size: 20,), Text("Gallerie", style: GoogleFonts.jura(),)],)
                                  ),
                                  ElevatedButton(
                                    onPressed: null,
                                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.camera, size: 20,), Text("Appareil photo", style: GoogleFonts.jura(),)],)
                                  ),
                                ]
                              )
                            ],
                          );
                        }
                        );
                      },
                      child: Text("Proposer des photos", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),),
                      ),
                    ],
                  ),
                ),
                ],
              ),
            ),

            Column(
              children: [
                CommentWidget(size: size),
                CommentWidget(size: size),
              ],
            ),

            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 15),
                child: TextButton(onPressed: (){
                          null;
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                          foregroundColor: MaterialStateProperty.all(verte),
                          shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                          side: MaterialStateProperty.all<BorderSide>(BorderSide(color: verte, width: 1.0)),
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.fromLTRB(size.width/4, 7, size.width/4, 7)),
                        ),
                        child: const Text("Charger plus d'avis", style: TextStyle(fontSize: 10),)),
              ),
            ),

            Text("Similaires", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 20,)),),

            const SimilairesList(),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: GestureDetector(
                  onTap: (){
                    showDialog(context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        content: Container(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Signalez une erreur sur ce lieu :",
                                style: TextStyle(fontSize: 18.0),
                              ),
                              const SizedBox(height: 16.0),
                              const TextField(
                                decoration: InputDecoration(
                                  hintText: "Votre avis...",
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16.0),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  // Logique pour enregistrer l'avis
                                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                                },
                                child: const Text("Envoyer"),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    );
                  },
                  child: Text("Signalez une erreur", style: GoogleFonts.jura(textStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)))
                  )
              ),
            )

          ],
        ),
        ),
      ),

      bottomNavigationBar: Container(
        width: size.width,
        padding: const EdgeInsets.all(10),
        child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: size.width/3,
                  child: Expanded(child: Text("Ouvert : ${wond.horaire}", style: GoogleFonts.lalezar(textStyle: TextStyle(fontSize: 15, color: verte)),))),
                ElevatedButton(
                  onPressed: (){
                    showDialog(context: context,
                    builder: (BuildContext context){
                      return const AlertDialog(
                        title: Icon(LucideIcons.cog, size: 50,),
                        content: Text("Fonctionnalites en developpement"),
                      );
                    }
                    );
                  },
                  child: Text("Reserver", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 14, color: Colors.white)),),
                ),

                ElevatedButton(
                  onPressed: (){
                    showDialog(context: context,
                    builder: (BuildContext context){
                      return const AlertDialog(
                        title: Icon(LucideIcons.cog, size: 50,),
                        content: Text("Fonctionnalites en developpement"),
                      );
                    }
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(LucideIcons.map),
                      Text("  Itineraire", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 14, color: Colors.white)),),
                    ],
                  )
                )
              ],
            ),
      ),
    );
  }

  Container ligneAcces_btnCarte(double width) {
    return Container(
            padding: EdgeInsets.all(width/50),
            margin: const EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: (){
                    showDialog(context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Center(child: Text("Modalités")),
                        content: Container(
                          height: 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Icon(LucideIcons.banknote, size: 60,),
                              Text(wond.free ? "Gratuit" : "${wond.price} Fcfa", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 25)),)
                            ],
                          ),
                        ),
                      );
                    }
                    );
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff226900),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(255, 148, 148, 148),
                                blurRadius: 2,
                                offset: Offset(0, 3)
                              )
                            ]
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Text("Accès", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 16, color: Colors.white)),),
                        ),
                  
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(255, 160, 160, 160),
                                blurRadius: 2,
                                offset: Offset(0, 3)
                              )
                            ]
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Text(wond.free ? "Gratuit" : "Payant", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 16, color: Color(0xff226900))),),
                        )
                      ],
                    ),
                  ),
                ),

                Container(
                  width: 2,
                  height: 30,
                  color: const Color(0xff226900),
                ),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                    if(is_map){
                      is_map = false;
                    }else{
                      is_map = true;
                    }
                  });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(LucideIcons.map, color: Colors.white,),
                      Text(is_map ? "  Images" : "  Carte", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 16, color: Colors.white)),),
                    ],
                  ),
                ),

              ],
            ),
          );
  }

  Container mapsWonder(Size size){
    return Container(
      height: 350,
      width: size.width,
      child: const Text("carte localisation lieu"),
    );
  }



  Container imagesWonder(Size size, List<Img> listeimages) {
    return Container(
            height: 350,
            width: size.width,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageStorieController,
                  itemCount: listeimages.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPageIndex = page;
                      });
                    },
                  itemBuilder: (context, index){
                    return photoWonder(path: listeimages[index].path, wonderName: wond.wonderName,);
                  }
                ),
      
      
      
                Container(
                  width: size.width/50*(listeimages.length+2),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(listeimages.length, (index) {
                      return Container(
                        width: size.width/50,
                        height: size.height/65,
                        //margin: EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPageIndex == index ? const Color(0xff226900) : const Color.fromARGB(255, 255, 255, 255),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(255, 86, 86, 86),
                              offset: Offset(0, 2),
                              blurRadius: 3
                            )
                          ]
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
  }

  
  
  void _showReviewDialog(BuildContext context) {
    showModalBottomSheet(
      
      context: context,
      //isScrollControlled: true,
      
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            //mainAxisSize: isKeyboardVisible ? MainAxisSize.max : MainAxisSize.min,
            children: [
              const Text(
                "Donnez votre avis sur ce lieu :",
                style: TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 16.0),
              const TextField(
                decoration: InputDecoration(
                  hintText: "Votre avis...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Logique pour enregistrer l'avis
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
                child: const Text("Envoyer"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CommentWidget extends StatelessWidget {
  const CommentWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: 115,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).brightness == Brightness.light ?Colors.white : Colors.black.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 5,
            offset: Offset(0, 1)
          )
        ]
      ),
    
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                margin: const EdgeInsets.only(right: 5),
      
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(20)
                ),
              ),
      
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Martine manga", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 12)),),
                  const Row(
                    children: [
                      Icon(LucideIcons.star, size: 11,),
                      Icon(LucideIcons.star, size: 11,),
                      Icon(LucideIcons.star, size: 11,),
                      Icon(LucideIcons.star, size: 11,),
                    ],
                  )
                ],
              )
            ],
          ),
      
          Text("C'est un lieu absolument magnifique, l'air pure, toutast pure, tout est parrfait... Voir plus", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 12)),)
        ],
      ),
    );
  }
}






class photoWonder extends StatelessWidget{
  final String path;
  final String wonderName;

  const photoWonder({super.key, required this.path, required this.wonderName});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    return Hero(
      tag: "imageWonder$wonderName",
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage(path),
            fit: BoxFit.cover
            ),
        ),
      ),
    );
  }
}





class SimilairesList extends StatefulWidget {
  const SimilairesList({
    super.key
  });

  static const verte = Color(0xff226900);

  @override
  State<SimilairesList> createState() => _SimilairesListState();
}

class _SimilairesListState extends State<SimilairesList> {
  final ScrollController _controller = ScrollController();
  final double _height = 150.0;
  final double _width = 140.0;

  @override
void initState() {
  super.initState();
  // Assurez-vous que le widget est construit avant d'appeler _animateToIndex
}


 // Largeur de chaque élément dans la liste
  void _animateToIndex(int index) {
    double offset = index * _width;
    if (_controller.hasClients) {
      offset = offset - (_controller.position.viewportDimension - _width) / 2;
      _controller.animateTo(
        offset,
        duration: const Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _height,
          child: ListView.builder(
            controller: _controller,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: wonders.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => wonder_page(wond: wonders[index])));
                },
                child: Storie(wond: wonders[index]),
              );
            }),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // N'oubliez pas de libérer le contrôleur lorsque vous n'en avez plus besoin
    super.dispose();
  }
}


class Storie extends StatelessWidget{
  static const verte = Color(0xff226900);
  final Wonder wond;

  const Storie({super.key, required this.wond});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [

        Container(
          width: 140,
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            image: DecorationImage(
              image: AssetImage(wond.imagePath),
              fit: BoxFit.cover
              ),
          )
        ),

        Expanded(
          child: Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            height: height/12,
            width: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: verte.withOpacity(0.8),
            ),
          
            child: Column(
              children: [
                Text("${wond.wonderName}...", maxLines: 1, style: GoogleFonts.lalezar(textStyle: const TextStyle(color: Colors.white)),),
                //Text(wond.city, style: GoogleFonts.jura(textStyle: const TextStyle(color: Colors.white)),),
              ],
            )
          ),
        ),
      ],
    );
  }
}