import 'package:camwonders/class/classes.dart';
import 'package:camwonders/firebase_logique.dart';
import 'package:camwonders/inscription.dart';
import 'package:camwonders/logique.dart';
import 'package:camwonders/pages/menu.dart';
import 'package:camwonders/pages/profil.dart';
import 'package:camwonders/pages/wonder_page.dart';
import 'package:camwonders/pages/wondershort.dart';
import 'package:camwonders/shimmers_effect/menu_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class page_categorie extends StatefulWidget{
  final Categorie cat;
  const page_categorie({super.key, required this.cat});

  @override
  State<page_categorie> createState() => _page_categorieState();
}

class _page_categorieState extends State<page_categorie> {
  int _selectedItem = 3;
  static const verte = Color(0xff226900);
  




  @override
  void initState() {
    super.initState();
  }


  void _changePage(int index) {
      setState(() {
        _selectedItem = index;
      });
    }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final List<Wonder> listewonderscat = widget.cat.getWonders();
    final List<Widget> pages = [const Menu(), const Wondershort(), const Profil(), wondersBody(size: size, listewonderscat: listewonderscat),];
    return Scaffold(
      body: pages[_selectedItem],

      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 65,
          decoration: const BoxDecoration(
        
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.linear,
                width: 70,
                height: 50,
                padding: const EdgeInsets.all(5),
                decoration: _selectedItem == 0 ? BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : const Color.fromARGB(255, 56, 56, 56),
                ) : null,
                child: IconButton(onPressed: () => _changePage(0), icon: const Icon(LucideIcons.layoutGrid, color: verte,),)
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.linear,
                width: 70,
                height: 50,
                padding: const EdgeInsets.all(5),
                decoration: _selectedItem == 1 ? BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : const Color.fromARGB(255, 56, 56, 56),
                ) : null,
                child: IconButton(onPressed: () => _changePage(1), icon: const Icon(LucideIcons.listVideo, color: verte,),)
              ),
        
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.linear,
                width: 70,
                height: 50,
                padding: const EdgeInsets.all(5),
                decoration: _selectedItem == 2 ? BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : const Color.fromARGB(255, 56, 56, 56),
                ) : null,
                child: IconButton(onPressed: () => _changePage(2), icon: const Icon(LucideIcons.user, color: verte,),)
              )
            ],
          ),
        ),
      )
    );
  }
}

class wondersBody extends StatefulWidget {
  const wondersBody({
    super.key,
    required this.size,
    required this.listewonderscat,
  });

  final Size size;
  final List<Wonder> listewonderscat;

  @override
  State<wondersBody> createState() => _wondersBodyState();
}

class _wondersBodyState extends State<wondersBody> {
  final List<String> notifications = [
    'Notification 1',
    'Notification 2',
    'Notification 3',
    // Ajoutez d'autres notifications selon vos besoins
  ];

    bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async{
    setState(() {isLoading = true;});
    await Future.delayed(const Duration(seconds: 1));

    if(mounted){
      setState(() {isLoading = false;});
    }
  }

  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: Center(child: Text(widget.listewonderscat[1].categorie.categoryName)),
        actions: [
          AuthService().currentUser == null ? Container(
            child: GestureDetector(
              onTap: (){
                 Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_,__,___) => const Inscription(),

                  transitionsBuilder: (_,animation,__,child){
                    return SlideTransition(
                      position: Tween<Offset> (begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut, reverseCurve: Curves.easeInOutBack)),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 500)
                  ));
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                decoration: BoxDecoration(
                  color: const Color(0xff226900),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Se connecter", style: GoogleFonts.jura(textStyle: TextStyle(fontSize: 10, color: Colors.white)),),
                    Icon(LucideIcons.userPlus, size: 13, color: Colors.white,),
                  ],
                ),
              ),
            )
          ) : Container(),

          Container(
          margin: const EdgeInsets.only(right: 10),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 10, right: 8),
                child: Text(notifications.length.toString(), style: GoogleFonts.lalezar(textStyle: TextStyle(fontSize: 15)),)),
              PopupMenuButton<String>(
                icon: const Icon(LucideIcons.bell),
                itemBuilder: (BuildContext context) {
                  return notifications.map((String notification) {
                    return PopupMenuItem<String>(
                      value: notification,
                      child: Text(notification),
                    );
                  }).toList();
                },
                onSelected: (String notification) {
                  // Traitez la notification sélectionnée ici
                  showDialog(context: context, builder: (BuildContext context){
                    return AlertDialog(
                      title: Text(notification),
                      content: const Text("Contenu de la notification"),
                      actions: [
                        TextButton(
                          onPressed: (){
                          Navigator.pop(context);
                          }, child: const Text("Marquer comme lu")
                        ),
              
                        TextButton(
                          onPressed: (){
                          Navigator.pop(context);
                          }, child: const Text("Retour")
                        ),
                      ],
                    );
                  }
                  
                  );
                },
              ),
            ],
          ),
          ),
        ],
      ),












      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            //height: 100,
            width: size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: size.width*8/11,
                      padding: const EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50)
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          icon: Icon(LucideIcons.search, size: 20,),
                          hintText: "Rechercher",
                          border: InputBorder.none
                        ),

                        style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
      
                    GestureDetector(
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const FilterDialog();
                          },
                        );
                      },
                      child: Container(
                        width: size.width*3/15,
                        padding: EdgeInsets.all(size.width*1/50),
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xff226900),
                          borderRadius: BorderRadius.circular(50)
                        ),

                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(LucideIcons.slidersHorizontal, size: 17, color: Colors.white,),
                            Text("Filtrer", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      
          Expanded(
            child: LiquidPullToRefresh(
              onRefresh: _handleRefresh,
              color: _page_categorieState.verte,
              backgroundColor: Colors.white,
              height: 50,
              showChildOpacityTransition: false,
              springAnimationDurationInMilliseconds: 700,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.listewonderscat.length,
                itemBuilder: (BuildContext context, int index){
                  return GestureDetector(
                    onTap: () => Navigator.push(context, PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => wonder_page(wond: widget.listewonderscat[index]),
                      transitionDuration: const Duration(milliseconds: 500),
                      transitionsBuilder: (context, animation, secondaryAnimation, child){
                        animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                        return FadeTransition(opacity: animation, child: child,);
                      }
                      ),
                    ),
                    child: isLoading ? shimmerWonder(width: size.width,) : wonderWidget(size: size, wonderscat: widget.listewonderscat[index]),
                  );
                }
              ),
            ),
          )
        ],
      ),
    );
  }
}

















class wonderWidget extends StatefulWidget {
  const wonderWidget({
    super.key,
    required this.size, required this.wonderscat,
  });

  final Size size;
  final Wonder wonderscat;

  @override
  State<wonderWidget> createState() => _wonderWidgetState();
}

// ignore: camel_case_types
class _wonderWidgetState extends State<wonderWidget> {
  bool is_like = false;
  late Box<Wonder> favorisBox;
  

  @override
  void initState() {
    super.initState();
    favorisBox = Hive.box<Wonder>('favoris_wonder');
    bool estPresent = favorisBox.values.any((wonder_de_la_box) => wonder_de_la_box.idWonder == widget.wonderscat.idWonder);
    if(estPresent){
      is_like = true;
    }
  }

  // ignore: non_constant_identifier_names
  void SetFavorisWonder(Wonder wonder){
    favorisBox = Hive.box<Wonder>('favoris_wonder');
    favorisBox.add(wonder);
  }

  String truncate(String text){
    if(text.length > 35){
      return "${text.substring(0, 35)}...";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [FadeEffect(duration: 500.ms)],
      child: Container(
        //height: 350,
        width: widget.size.width,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.0)),
        ),
        child: Column(
          children: [
            Hero(
              tag: "imageWonder${widget.wonderscat.wonderName}",
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(widget.wonderscat.imagePath),
                        fit: BoxFit.cover,
                      )
                    ),
                  ),

                  Container(
                        height: 50,
                        width: 50,
                        margin: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        
                        ),
      
                        child: IconButton(onPressed: (){
                          setState(() {
                            if(is_like){
                              is_like = false;
                              Logique().supprimerFavorisWonder(favorisBox.length - 1);
                            }else{
                              SetFavorisWonder(widget.wonderscat);
                              is_like = true;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Container(
                                    height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.green,borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: const Center(child: Text("Element Ajouté aux Favoris !")),
                                ),
                                duration: Duration(milliseconds: 900),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                
                                )
                              );
                            }
                          });
                        },
                          icon: is_like ? Icon(Icons.favorite_outlined, color: Color.fromARGB(255, 224, 71, 60), size: 25, shadows: [
                            ],) : Icon(Icons.favorite_border_outlined, color: Colors.white, size: 25, shadows: [
                              BoxShadow(
                                offset: const Offset(3, 3),
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 7,
                              )
                            ],)
                        )
                      ),
                ],
              ),
            ),
      
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(truncate(widget.wonderscat.wonderName), style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 18))),
                      Text(widget.wonderscat.city),
                      Row(
                        children: [
                          Row(
                            children: [
                              Row(
                                children: List.generate(
                                  widget.wonderscat.note,
                                  (index) => const Icon(
                                    Icons.star,
                                    color:  Color(0xff226900),
                                    size: 15,
                                  ),
                                ),
                              ),
      
                              Row(
                                children: List.generate(
                                  5 - widget.wonderscat.note,
                                  (index) => const Icon(
                                    Icons.star_border_outlined,
                                    color:  Color(0xff226900),
                                    size: 15,
                                  ),
                                ),
                              ),
                            ]
                          ),
      
                          Container(
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            width: 2,
                            height: 20,
                            color:  const Color(0xff226900),
                          ),
      
                          const Text("24km")
                        ],
                      ),

                      Text("Personnes qui aiment ce lieu : ${widget.wonderscat.note}")
                    ],
                  ),
                
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}



class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  bool _showPaidItems = false;
  String _selectedRegion = 'Toutes les régions';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Definissez vos options de filtrages'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            title: const Text('Wonders Payants'),
            value: _showPaidItems,
            onChanged: (value) {
              setState(() {
                _showPaidItems = value!;
              });
            },
          ),
          const SizedBox(height: 16.0),
          const Text('Choisir une région :'),
          DropdownButton<String>(
            value: _selectedRegion,
            onChanged: (newValue) {
              setState(() {
                _selectedRegion = newValue!;
              });
            },
            items: <String>[
              'Toutes les régions',
              'Extreme-nord',
              'Nord',
              'Adamaoua',
              'Centre',
              'Est',
              'Ouest',
              'Sud',
              'Littoral',
              'Nord-ouest',
              'Sud-ouest',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16.0),

        ],
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
            Navigator.of(context).pop();
          },
          child: const Text('Appliquer'),
        ),
      ],
    );
  }
}