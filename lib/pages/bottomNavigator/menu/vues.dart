import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camwonders/pages/AbonnementPage.dart';
import 'package:camwonders/pages/wonder_page.dart';
import 'package:camwonders/services/cachemanager.dart';
import 'package:camwonders/class/Categorie.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/services/logique.dart';
import 'package:camwonders/pages/page_categorie.dart';
import 'package:camwonders/pages/storie.dart';
import 'package:camwonders/shimmers_effect/menu_shimmer.dart';
import 'package:camwonders/widgetGlobal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

class ListeVue extends StatefulWidget {
  const ListeVue({super.key});
  static const verte = Color(0xff226900);

  @override
  State<ListeVue> createState() => _ListeVueState();
}

class _ListeVueState extends State<ListeVue> {
  bool _visible = false;
  int _currentPage = 0;
  int select_cat = 0;
  bool isLoading = false;
  final PageController _offreController = PageController();
  Timer? _timer;
  int _nombreOffres = 0;
  late final Stream<QuerySnapshot> _offres;
  late final Stream<QuerySnapshot> _wondersPopulaire;

  final List<Categorie> cats = [
    Categorie(1, "Wonders nature", 'leaf', true),
    Categorie(2, "Wonders patrimoine", 'landmark', true),
    Categorie(3, "Wonders restau", 'utensils', false),
    Categorie(4, "Wonders Hotels", 'bed', false),
  ];

  List<Wonder> wonders = [];
  Stream<QuerySnapshot>? listewonderscat;


  @override
  void initState() {
    super.initState();
    if (mounted) {
      _verifyConnection();
      _offres = FirebaseFirestore.instance.collection('offres').snapshots();
      _wondersPopulaire = FirebaseFirestore.instance
          .collection('wonders')
          .orderBy('note', descending: true)
          .limit(5)
          .snapshots();
      _getNumberOfOffers();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _visible = true;
        });
      });

      _startAutoScroll();
    }

    listewonderscat = FirebaseFirestore.instance
        .collection('wonders')
        .where('categorie', isEqualTo: cats[select_cat].categoryName)
        .limit(3)
        .snapshots();
  }

  void _loadCat(int select) {
    setState(() {
      listewonderscat = FirebaseFirestore.instance
          .collection('wonders')
          .where('categorie', isEqualTo: cats[select].categoryName)
          .limit(3)
          .snapshots();
    });
  }

  void _verifyConnection() async {
    if (await Logique.checkInternetConnection()) {
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Connectez-vous a internet"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _getNumberOfOffers() async {
    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('offres').get();
    setState(() {
      _nombreOffres = querySnapshot.docs.length;
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _nombreOffres - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _offreController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeIn,
      );
    });
  }

  void _stopAutoScroll() {
    _timer?.cancel();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _offreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;
    final userProvider = Provider.of<UserProvider>(context);
    return SingleChildScrollView(
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.gem,
                    color: ListeVue.verte,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Offres spéciales",
                    style: GoogleFonts.jura(
                        textStyle: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 200,
              child: StreamBuilder<QuerySnapshot>(
                stream: _offres,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                          "Erreur survenue, essayez de relancer l'application"),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return shimmerOffre(
                      width: width,
                      height: 200,
                    );
                  }

                  return PageView.builder(
                      itemCount: snapshot.data!.docs.length,
                      controller: _offreController,
                      onPageChanged: (int page) {
                        setState(() {
                          if (mounted) {
                            _currentPage = page;
                          }
                        });
                      },
                      itemBuilder: (context, index) {
                        final DocumentSnapshot document = snapshot.data!.docs[index];
                        return GestureDetector(
                          onPanDown: (details) {
                            _stopAutoScroll();
                          },
                          onPanCancel: () {
                            _startAutoScroll();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                            child: Container(
                              width: width,
                              height: 200,
                              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: SizedBox(
                                      width: width,
                                      height: 200,
                                      child: CachedNetworkImage(
                                        cacheManager: CustomCacheManager(),
                                        imageUrl: document['image'],
                                        placeholder: (context, url) => Center(
                                            child: shimmerOffre(
                                          height: 200,
                                          width: width,
                                        )),
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                                child: Icon(Icons.error)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: width,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.black.withValues(alpha:0.5),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 15, 20, 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          document['title'],
                                          maxLines: 1,
                                          style: GoogleFonts.lalezar(
                                              textStyle: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                        Text(
                                          document['content'],
                                          maxLines: 3,
                                          style: GoogleFonts.jura(
                                              textStyle: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.0,
                                                  color: Colors.white)),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 15),

                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: TextButton(
                                            onPressed: (){
                                              showDialog(context: context, builder: (BuildContext context){
                                                return AlertDialog(
                                                  title: const Center(child: Icon(LucideIcons.externalLink, size: 50,)),
                                                  content: const Text("Vous allez être redirigé vers un site externe pour voir les details de l'offre"),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: (){
                                                          Navigator.pop(context);
                                                        }, child: const Text("D'accord")
                                                    ),

                                                    TextButton(
                                                        onPressed: (){
                                                          Navigator.pop(context);
                                                        }, child: const Text("Retour", style: TextStyle(color: Colors.red),)
                                                    ),
                                                  ],
                                                );
                                              }

                                              );
                                            },
                                            child: Text(document['textlink'],
                                              style: GoogleFonts.jura(
                                                  textStyle: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: ListeVue.verte)),),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                },
              ),
            ),

            StoriesList(wondersPopulaire: _wondersPopulaire),
            //Storie(path: wonders[1].imagePath),

            Container(
              padding: const EdgeInsets.only(left: 20, top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.bookOpen,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Catégories",
                    style: GoogleFonts.jura(
                        textStyle: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            Container(
              height: 40,
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: cats.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            cats[index].statut
                                ? select_cat = index
                                : showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Icon(
                                          LucideIcons.fileWarning,
                                          size: 50,
                                          color: Colors.orange,
                                        ),
                                        content: Text(
                                          "Catégorie bientôt disponible",
                                          style: GoogleFonts.lalezar(
                                              textStyle: const TextStyle(
                                                  fontSize: 20)),
                                        ),
                                      );
                                    }); select_cat = index;

                            _loadCat(index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 1000), // Durée de l'animation
                            curve: Curves.easeOut, // Type de courbe d'animation
                            transform: Matrix4.translationValues(
                                0,
                                _visible ? 0 : 50,
                                0), // Déplacement vers le bas
                            child: catButton(
                                select_cat: select_cat,
                                rang: index,
                                width: width,
                                verte: ListeVue.verte,
                                cat: cats[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: listewonderscat,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        shimmerWonder(width: size.width),
                        shimmerWonder(width: size.width),
                      ],
                    ),
                  );
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: size.height / 10,
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(30),
                            child: Theme.of(context).brightness ==
                                Brightness.light
                                ? Image.asset('assets/vide_light.png')
                                : Image.asset('assets/vide_dark.png'),
                          ),
                          const Text("Vide, aucun element !")
                        ],
                      ));
                }

                return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final DocumentSnapshot document =
                      snapshot.data!.docs[index];
                      final Wonder wond = Wonder(
                          idWonder: document.id,
                          wonderName: document['wonderName'],
                          description: document['description'],
                          imagePath: document['imagePath'],
                          city: document['city'],
                          region: document['region'],
                          free: document['free'],
                          price: document['price'],
                          horaire: document['horaire'],
                          latitude: document['latitude'],
                          longitude: document['longitude'],
                          note: (document['note'] as num).toDouble(),
                          categorie: document['categorie'],
                          isreservable: document['isreservable'],
                          acces: document['acces']);
                      return GestureDetector(
                        onTap: () {
                          if(userProvider.isPremium || wond.free){
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                      WonderPage(wond: wond),
                                  transitionDuration:
                                  const Duration(milliseconds: 500),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    animation = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeIn);
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  }),
                            );
                          }else{
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => SubscriptionPage()));
                          }
                        },
                        child: isLoading
                            ? shimmerWonder(
                          width: size.width,
                        )
                            : WonderWidget(
                            size: size, wonderscat: wond),
                      );
                    });
              },
            ),

            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: (){
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (_, __, ___) => PageCategorie(cat: cats[select_cat]),
                                transitionsBuilder: (_, animation, __, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                        begin: const Offset(-1.0, 0.0), end: Offset.zero)
                                        .animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeInOut,
                                        reverseCurve: Curves.easeInOutBack)),
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 700)));
                      },
                      child: const Row(
                        children: [
                          Text('Tout voir', style: TextStyle(decoration: TextDecoration.underline),),
                          SizedBox(width: 10,),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      )
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class catButton extends StatelessWidget {
  const catButton({
    super.key,
    required this.width,
    required this.verte,
    required this.cat, required this.select_cat, required this.rang,
  });

  final double width;
  final Color verte;
  final Categorie cat;
  final int select_cat;
  final int rang;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            width: width * 15 / 40,
            height: 35,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: cat.statut ? rang == select_cat ? verte : Theme.of(context).brightness ==
                  Brightness.light ? Colors.white : Colors.transparent : Theme.of(context).brightness ==
                  Brightness.light ? Colors.grey.shade100 : Colors.transparent,
                borderRadius: BorderRadius.circular(200),
                border: Border.all(
                    color: cat.statut ? Colors.grey.withValues(alpha:0.5) : Colors.grey.withValues(alpha:0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Icon(, size: 55, color: verte,),

                Text(
                  cat.categoryName,
                  style: GoogleFonts.jura(
                      color: cat.statut ? rang == select_cat ? Colors.white : Theme.of(context).brightness ==
                          Brightness.light ? Colors.black : Colors.white : Colors.grey,
                      textStyle: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                )
              ],
            )),
      ],
    );
  }
}

class StoriesList extends StatefulWidget {
  const StoriesList({super.key, required this.wondersPopulaire});
  final Stream<QuerySnapshot> wondersPopulaire;

  static const verte = Color(0xff226900);

  @override
  State<StoriesList> createState() => _StoriesListState();
}

class _StoriesListState extends State<StoriesList> {
  final ScrollController _controller = ScrollController();
  final double _height = 200.0;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 20, bottom: 8),
          child: Row(
            children: [
              const Icon(
                LucideIcons.heart,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Populaires",
                style: GoogleFonts.jura(
                    textStyle: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 15),
          child: SizedBox(
              height: _height,
              child: StreamBuilder<QuerySnapshot>(
                  stream: widget.wondersPopulaire,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            shimmerStorie(),
                            shimmerStorie(),
                            shimmerStorie()
                          ],
                        ),
                      );
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: size.height / 10,
                            margin: const EdgeInsets.all(10),
                            child:
                                Theme.of(context).brightness == Brightness.light
                                    ? Image.asset('assets/vide_light.png')
                                    : Image.asset('assets/vide_dark.png'),
                          ),
                          const Text(
                              "Vide pour le moment, bientot disponible !")
                        ],
                      ));
                    }
                    return ListView.builder(
                        controller: _controller,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final DocumentSnapshot document =
                              snapshot.data!.docs[index];
                          final Wonder wond = Wonder(
                            idWonder: document.id,
                            wonderName: document['wonderName'],
                            description: document['description'],
                            imagePath: document['imagePath'],
                            city: document['city'],
                            region: document['region'],
                            free: document['free'],
                            price: document['price'],
                            horaire: document['horaire'],
                            latitude: document['latitude'],
                            longitude: document['longitude'],
                            note: (document['note'] as num).toDouble(),
                            categorie: document['categorie'],
                            isreservable: document['isreservable'],
                              acces: document['acces']
                          );
                          return GestureDetector(
                            onTap: () {

                              (userProvider.isPremium || wond.free) ? Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        Sttories(wond: wond),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      animation = CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeIn);
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  )) : Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => SubscriptionPage()));
                            },
                            child: isLoading
                                ? const shimmerStorie()
                                : Storie(wond: wond),
                          );
                        });
                  })),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller
        .dispose(); // N'oubliez pas de libérer le contrôleur lorsque vous n'en avez plus besoin
    super.dispose();
  }
}

class Storie extends StatefulWidget {
  static const verte = Color(0xff226900);
  final Wonder wond;

  const Storie({super.key, required this.wond});

  @override
  _StorieState createState() => _StorieState(wond: wond);
}

class _StorieState extends State<Storie> with SingleTickerProviderStateMixin {
  double _opacity = 0;
  final Wonder wond;

  _StorieState({required this.wond});

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _opacity = 1;
      });
    });
  }

  String truncate(String text) {
    if (text.length > 10) {
      return "${text.substring(0, 10)}..";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Container(
      width: 145,
      height: 200,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
      child: AnimatedOpacity(
        opacity: _opacity,
        duration:
            const Duration(milliseconds: 500), // Durée de l'effet de transition
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 140,
              height: 200,
              margin: const EdgeInsets.all(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  cacheManager: CustomCacheManager(),
                  imageUrl: widget.wond.imagePath,
                  placeholder: (context, url) =>
                      const Center(child: shimmerStorie()),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.error)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            (userProvider.isPremium || wond.free)
                ? const SizedBox()  // Un widget vide au lieu d'un Center inutile
                : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black.withValues(alpha:0.6),
              ),
              height: 200,
              width: 140,

              child: const Icon(Icons.lock, size: 70, color: Colors.white),
            ),
            Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(8),
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color.fromARGB(255, 0, 0, 0).withValues(alpha:0.8),
                        const Color.fromARGB(255, 0, 0, 0).withValues(alpha:0.0),
                      ]),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            truncate(widget.wond.wonderName),
                            maxLines: 1,
                            style: GoogleFonts.lalezar(
                                textStyle: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    height: 1.0)),
                          ),
                          Row(children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.orange,
                              size: 20,
                            ),
                            Text(
                              widget.wond.note.toStringAsFixed(1),
                              style: GoogleFonts.lalezar(
                                  textStyle:
                                      const TextStyle(color: Colors.white)),
                            )
                          ])
                        ]),

                    const SizedBox(height: 3),

                    Row(
                      children: [
                        const Icon(
                          LucideIcons.mapPin,
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Expanded(
                            child: Text(
                          "${widget.wond.city}, ${widget.wond.region}",
                          style: GoogleFonts.jura(
                              textStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  height: 1.0)),
                        )),
                      ],
                    )
                    //Text(wond.city, maxLines: 1, style: GoogleFonts.jura(textStyle: const TextStyle(color: Colors.white)),),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class MapVue extends StatefulWidget {
  const MapVue({super.key}); // Correction du constructeur

  static const verte = Color(0xff226900);

  @override
  State<MapVue> createState() => _MapVueState();
}

class _MapVueState extends State<MapVue> with SingleTickerProviderStateMixin {
  double su = 20;
  bool is_loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    //await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        is_loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return is_loading ? const shimmerMaps() : const maps();
  }
}

class shimmerMaps extends StatelessWidget {
  const shimmerMaps({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.light
              ? const Color.fromARGB(255, 235, 235, 235)
              : const Color.fromARGB(255, 63, 63, 63),
          highlightColor: Theme.of(context).brightness == Brightness.light
              ? const Color.fromARGB(255, 255, 255, 255)
              : const Color.fromARGB(255, 95, 95, 95),
          child: Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        Center(
          child: Gif(
            height: 100,
            image: const AssetImage("assets/load.gif"),
            autostart: Autostart.loop,
            placeholder: (context) => const Text('Loading...'),
          ),
        ),
      ],
    );
  }
}

class maps extends StatefulWidget {
  const maps({super.key});

  @override
  State<maps> createState() => _mapsState();
}

class _mapsState extends State<maps> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: latLng.LatLng(6.308663695718445, 12.619149719332942),
        initialZoom: 6,
        interactionOptions:
            InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
      ),
      children: [
        openStreetMapTileLatter,
        const MarkerLayer(
          markers: [],
        ),
        FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('wonders').get(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text("Vous n'êtes pas connecté"),
              );
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("Aucune donnée trouvée"),
              );
            } else {
              return MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  maxZoom: 13,
                  markers: snapshot.data!.docs.map((DocumentSnapshot document) {
                    final Wonder wond = Wonder(
                        idWonder: document.id,
                        wonderName: document['wonderName'],
                        description: document['description'],
                        imagePath: document['imagePath'],
                        city: document['city'],
                        region: document['region'],
                        free: document['free'],
                        price: document['price'],
                        horaire: document['horaire'],
                        latitude: document['latitude'],
                        longitude: document['longitude'],
                        note: (document['note'] as num).toDouble(),
                        categorie: document['categorie'],
                        isreservable: document['isreservable'],
                        acces: document['acces']);
                    return Marker(
                      point: latLng.LatLng(double.parse(wond.latitude),
                          double.parse(wond.longitude)),
                      child: WonderMarker(wonder: wond),
                    );
                  }).toList(),
                  builder: (context, markers) {
                    return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(0xff226900)),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

TileLayer get openStreetMapTileLatter => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );

class WonderMarker extends StatelessWidget {
  final Wonder wonder;
  const WonderMarker({super.key, required this.wonder});

  String truncate(String text) {
    if (text.length > 20) {
      return "${text.substring(0, 20)}...";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: Container(
                  height: 170,
                  width: MediaQuery.of(context).size.width,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: 170,
                            width: 120,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                cacheManager: CustomCacheManager(),
                                imageUrl: wonder.imagePath,
                                placeholder: (context, url) => const Center(
                                    child: shimmerOffre(width: 120, height: 170)),
                                errorWidget: (context, url, error) =>
                                    const Center(child: Icon(Icons.error)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          (userProvider.isPremium || wonder.free)
                              ? const SizedBox()  // Un widget vide au lieu d'un Center inutile
                              : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.black.withValues(alpha:0.6),
                            ),
                            height: 170,
                            width: 120,

                            child: const Icon(Icons.lock, size: 100, color: Colors.white),
                          ),
                        ],
                      ),

                      //SizedBox(width: 10,),

                      Container(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              truncate(wonder.wonderName),
                              style: GoogleFonts.lalezar(
                                  textStyle: const TextStyle(
                                      fontSize: 16, color: Color(0xff226900))),
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Row(
                                      children: List.generate(
                                        wonder.note.floor(),
                                        (index) => const Icon(
                                          Icons.star_rounded,
                                          color: Colors.orange,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                    // Demi-étoile si nécessaire
                                    if (wonder.note - wonder.note.floor() !=
                                            1 &&
                                        wonder.note - wonder.note.floor() != 0)
                                      const Icon(
                                        Icons.star_half_rounded,
                                        color: Colors.orange,
                                        size: 15,
                                      ),
                                    // Étoiles vides
                                    if (wonder.note.floor() != 5 &&
                                        wonder.note - wonder.note.floor() == 0)
                                      Row(
                                        children: List.generate(
                                          5 - wonder.note.floor(),
                                          (index) => const Icon(
                                            Icons.star_border_rounded,
                                            color: Colors.orange,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    if (wonder.note.floor() != 5 &&
                                        wonder.note - wonder.note.floor() !=
                                            1 &&
                                        wonder.note - wonder.note.floor() != 0)
                                      Row(
                                        children: List.generate(
                                          4 - wonder.note.floor(),
                                          (index) => const Icon(
                                            Icons.star_border_rounded,
                                            color: Colors.orange,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    if (wonder.note.floor() == 5 &&
                                        wonder.note - wonder.note.floor() !=
                                            1 &&
                                        wonder.note - wonder.note.floor() != 0)
                                      Row(
                                        children: List.generate(
                                          4 - wonder.note.floor(),
                                          (index) => const Icon(
                                            Icons.star_border_rounded,
                                            color: Colors.orange,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  width: 2,
                                  height: 20,
                                  color: const Color(0xff226900),
                                ),
                                Text(
                                  wonder.note.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  truncate(wonder.region),
                                  style: GoogleFonts.jura(
                                      textStyle: const TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  height: 15,
                                  width: 1,
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  truncate(wonder.city),
                                  style: GoogleFonts.jura(
                                      textStyle: const TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                            SizedBox(
                                width: 150,
                                child: Text(
                                  "Ce lieu se situe dans la région de ${wonder.region}",
                                  style: GoogleFonts.jura(
                                      textStyle: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                )),
                            SizedBox(
                              height: 30,
                              child: ElevatedButton(
                                  onPressed: () {
                                    if(userProvider.isPremium || wonder.free){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  WonderPage(wond: wonder)));
                                    }else{
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  SubscriptionPage()));
                                    }
                                  },
                                  child: const Text("Découvrir")),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
      },
      child: Container(
        child: wonder.categorie == "Wonders nature"
            ? Image.asset("assets/locationNature.png")
            : wonder.categorie == "Wonders patrimoine"
                ? Image.asset("assets/locationPatrimoine.png")
                : wonder.categorie == "Wonders hotels"
                    ? Image.asset("assets/locationHotels.png")
                    : Image.asset("assets/locationRestau.png"),
      ),
    );
  }
}
