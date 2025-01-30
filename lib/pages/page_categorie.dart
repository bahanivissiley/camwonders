import 'package:camwonders/auth_pages/debut_inscription.dart';
import 'package:camwonders/pages/bottomNavigator/page_favoris.dart';
import 'package:camwonders/pages/bottomNavigator/reservations.dart';
import 'package:camwonders/services/cachemanager.dart';
import 'package:camwonders/class/Categorie.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/firebase/firebase_logique.dart';
import 'package:camwonders/services/logique.dart';
import 'package:camwonders/pages/bottomNavigator/menu/menu.dart';
import 'package:camwonders/pages/bottomNavigator/profil.dart';
import 'package:camwonders/pages/wonder_page.dart';
import 'package:camwonders/pages/bottomNavigator/wondershort.dart';
import 'package:camwonders/shimmers_effect/menu_shimmer.dart';
import 'package:camwonders/widgetGlobal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';

class page_categorie extends StatefulWidget {
  final Categorie cat;
  const page_categorie({super.key, required this.cat});

  @override
  State<page_categorie> createState() => _page_categorieState();
}

class _page_categorieState extends State<page_categorie> {
  int _selectedItem = 5;
  static const verte = Color(0xff226900);
  late final Stream<QuerySnapshot> listewonderscat;

  @override
  void initState() {
    super.initState();
    _verifyConnection();
    setState(() {});
    listewonderscat = FirebaseFirestore.instance
        .collection('wonders')
        .where('categorie', isEqualTo: widget.cat.categoryName)
        .snapshots();
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

  void _changePage(int index) {
    setState(() {
      _selectedItem = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final List<Widget> pages = [
      const Menu(),
      const reservations(),
      const Wondershort(),
      const page_favoris(),
      const Profil(),
      wondersBody(
        size: size,
        listewonderscat: listewonderscat,
        cat: widget.cat,
      ),
    ];
    return Scaffold(
        body: pages[_selectedItem],
        bottomNavigationBar: Container(
          padding: const EdgeInsets.only(bottom: 7, top: 7),
          decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : const Color(0xff323232),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey
                        : const Color(0xff323232),
                    offset: const Offset(0, 3),
                    blurRadius: 4)
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                      height: 35,
                      duration: const Duration(milliseconds: 800),
                      decoration: _selectedItem == 0
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey.withOpacity(0.3)
                                  : const Color.fromARGB(255, 56, 56, 56),
                            )
                          : null,
                      child: IconButton(
                        onPressed: () => _changePage(0),
                        icon: Icon(
                          LucideIcons.layoutGrid,
                          size: 20,
                          color: _selectedItem == 0
                              ? verte
                              : Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey
                                  : Colors.white,
                        ),
                      )),
                  Text(
                    "Accueil",
                    style: GoogleFonts.jura(
                        textStyle: TextStyle(
                            fontSize: 10,
                            color: _selectedItem == 0 ? verte : Colors.grey,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                      height: 35,
                      duration: const Duration(milliseconds: 800),
                      decoration: _selectedItem == 1
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey.withOpacity(0.3)
                                  : const Color.fromARGB(255, 56, 56, 56),
                            )
                          : null,
                      child: IconButton(
                        onPressed: () => _changePage(1),
                        icon: Icon(
                          LucideIcons.calendarClock,
                          size: 20,
                          color: _selectedItem == 1
                              ? verte
                              : Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey
                                  : Colors.white,
                        ),
                      )),
                  Text(
                    "Reservations",
                    style: GoogleFonts.jura(
                        textStyle: TextStyle(
                            fontSize: 10,
                            color: _selectedItem == 1 ? verte : Colors.grey,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                      height: 35,
                      duration: const Duration(milliseconds: 800),
                      decoration: _selectedItem == 2
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey.withOpacity(0.3)
                                  : const Color.fromARGB(255, 56, 56, 56),
                            )
                          : null,
                      child: IconButton(
                        onPressed: () => _changePage(2),
                        icon: Icon(
                          LucideIcons.listVideo,
                          size: 30,
                          color: _selectedItem == 2
                              ? verte
                              : Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey
                                  : Colors.white,
                        ),
                      )),
                  Text(
                    "Videos",
                    style: GoogleFonts.jura(
                        textStyle: TextStyle(
                            fontSize: 10,
                            color: _selectedItem == 2 ? verte : Colors.grey,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                      height: 35,
                      duration: const Duration(milliseconds: 800),
                      decoration: _selectedItem == 3
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey.withOpacity(0.3)
                                  : const Color.fromARGB(255, 56, 56, 56),
                            )
                          : null,
                      child: IconButton(
                        onPressed: () => _changePage(3),
                        icon: Icon(
                          LucideIcons.heart,
                          size: 20,
                          color: _selectedItem == 3
                              ? verte
                              : Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey
                                  : Colors.white,
                        ),
                      )),
                  Text(
                    "Favoris",
                    style: GoogleFonts.jura(
                        textStyle: TextStyle(
                            fontSize: 10,
                            color: _selectedItem == 3 ? verte : Colors.grey,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                      height: 35,
                      duration: const Duration(milliseconds: 800),
                      decoration: _selectedItem == 4
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey.withOpacity(0.3)
                                  : const Color.fromARGB(255, 56, 56, 56),
                            )
                          : null,
                      child: IconButton(
                        onPressed: () => _changePage(4),
                        icon: Icon(
                          LucideIcons.user,
                          size: 20,
                          color: _selectedItem == 4
                              ? verte
                              : Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey
                                  : Colors.white,
                        ),
                      )),
                  Text(
                    "Profil",
                    style: GoogleFonts.jura(
                        textStyle: TextStyle(
                            fontSize: 10,
                            color: _selectedItem == 4 ? verte : Colors.grey,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ));
  }
}

class wondersBody extends StatefulWidget {
  wondersBody({
    super.key,
    required this.size,
    required this.listewonderscat,
    required this.cat,
  });

  final Size size;
  Stream<QuerySnapshot> listewonderscat;
  final Categorie cat;

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
  final TextEditingController _controller = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
    widget.listewonderscat = widget.cat.getWonders();
  }

  Future loadData() async {
    setState(() {
      isLoading = true;
    });

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {});
    widget.listewonderscat = FirebaseFirestore.instance
        .collection('wonders')
        .where('categorie', isEqualTo: widget.cat.categoryName)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final wondersProvider = Provider.of<WondersProvider>(context);
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: Center(child: Text(widget.cat.categoryName)),
        actions: [
          AuthService().currentUser == null
              ? Container(
                  child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                const Debut_Inscription(),
                            transitionsBuilder: (_, animation, __, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero)
                                    .animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeInOut,
                                        reverseCurve: Curves.easeInOutBack)),
                                child: child,
                              );
                            },
                            transitionDuration:
                                const Duration(milliseconds: 500)));
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    decoration: BoxDecoration(
                        color: const Color(0xff226900),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Se connecter",
                          style: GoogleFonts.jura(
                              textStyle: const TextStyle(
                                  fontSize: 10, color: Colors.white)),
                        ),
                        const Icon(
                          LucideIcons.userPlus,
                          size: 13,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ))
              : Container(),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
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
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(notification),
                            content: const Text("Contenu de la notification"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Marquer comme lu")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Retour")),
                            ],
                          );
                        });
                  },
                ),
                notifications.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 15, right: 5),
                        padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
                        decoration: BoxDecoration(
                            color: const Color(0xff226900),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          notifications.length.toString(),
                          style: GoogleFonts.lalezar(
                              textStyle: const TextStyle(
                                  fontSize: 12, color: Colors.white)),
                        ))
                    : const SizedBox()
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
                      width: size.width * 8 / 11,
                      padding: const EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50)),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                            icon: Icon(
                              LucideIcons.search,
                              size: 20,
                            ),
                            hintText: "Rechercher",
                            border: InputBorder.none),
                        style: GoogleFonts.jura(
                            textStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        onChanged: (value) {
                          context.read<WondersProvider>().setSearchQuery(value.toLowerCase());
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return FilterDialog(
                              cat: widget.cat,
                              listewonderscat: widget.listewonderscat,
                            );
                          },
                        );
                      },
                      child: Container(
                        width: size.width * 3 / 15,
                        padding: EdgeInsets.all(size.width * 1 / 50),
                        height: 45,
                        decoration: BoxDecoration(
                            color: const Color(0xff226900),
                            borderRadius: BorderRadius.circular(50)),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              LucideIcons.slidersHorizontal,
                              size: 17,
                              color: Colors.white,
                            ),
                            Text(
                              "Filtrer",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
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
              child: widget.listewonderscat.length != 0
                  ? LiquidPullToRefresh(
                      onRefresh: _handleRefresh,
                      color: _page_categorieState.verte,
                      backgroundColor: Colors.white,
                      height: 50,
                      showChildOpacityTransition: false,
                      springAnimationDurationInMilliseconds: 700,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: wondersProvider.wondersStream,
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
                                    isreservable: document['isreservable']);
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            wonder_page(wond: wond),
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
                                  ),
                                  child: isLoading
                                      ? shimmerWonder(
                                          width: size.width,
                                        )
                                      : wonderWidget(
                                          size: size, wonderscat: wond),
                                );
                              });
                        },
                      ),
                    )
                  : Center(
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
                        const Text("Vide pour le moment, bientot disponible !")
                      ],
                    )))
        ],
      ),
    );
  }
}

class wonderWidget extends StatefulWidget {
  const wonderWidget({
    super.key,
    required this.size,
    required this.wonderscat,
  });

  final Size size;
  final Wonder wonderscat;

  @override
  State<wonderWidget> createState() => _wonderWidgetState();
}

// ignore: camel_case_types
class _wonderWidgetState extends State<wonderWidget>
    with SingleTickerProviderStateMixin {
  bool is_like = false;
  late Box<Wonder> favorisBox;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    favorisBox = Hive.box<Wonder>('favoris_wonder');
    final bool estPresent = favorisBox.values.any((wonder_de_la_box) =>
        wonder_de_la_box.idWonder == widget.wonderscat.idWonder);
    if (estPresent) {
      is_like = true;
    }

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
  }

  // ignore: non_constant_identifier_names
  void SetFavorisWonder(Wonder wonder) {
    favorisBox = Hive.box<Wonder>('favoris_wonder');
    favorisBox.add(wonder);
  }

  String truncate(String text) {
    if (text.length > 35) {
      return "${text.substring(0, 35)}...";
    }
    return text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          border: Border(
              bottom:
                  BorderSide(color: Colors.grey.withOpacity(0.5))),
        ),
        child: Column(
          children: [
            Hero(
              tag: "imageWonder${widget.wonderscat.wonderName}",
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Animate(
                    effects: [FadeEffect(duration: 500.ms)],
                    child: Container(
                      height: 250,
                      width: widget.size.width,
                      margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          cacheManager: CustomCacheManager(),
                          imageUrl: widget.wonderscat.imagePath,
                          placeholder: (context, url) => Center(
                              child: shimmerOffre(
                                  width: widget.size.width, height: 250)),
                          errorWidget: (context, url, error) =>
                              const Center(child: Icon(Icons.error)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      width: 50,
                      margin: const EdgeInsets.fromLTRB(0, 30, 30, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: ScaleTransition(
                        scale: _animation,
                        child: IconButton(
                            onPressed: () {
                              if (AuthService().currentUser != null) {
                                setState(() {
                                  if (is_like) {
                                    is_like = false;
                                    Logique().supprimerFavorisWonder(
                                        favorisBox.length - 1);
                                  } else {
                                    SetFavorisWonder(widget.wonderscat);
                                    is_like = true;
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: const Center(
                                            child: Text(
                                                "Element Ajouté aux Favoris !")),
                                      ),
                                      duration:
                                          const Duration(milliseconds: 900),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                    ));
                                  }
                                });
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Container(
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text("Ignorer",
                                                  style: TextStyle(
                                                      decoration: TextDecoration
                                                          .underline)),
                                            )
                                          ],
                                        )),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                                //width: 20,
                                                height: 100,
                                                child: Image.asset(
                                                    'assets/logo.png')),
                                            Text(
                                              "Connectez vous pour acceder a tout les foncionnalités",
                                              style: GoogleFonts.lalezar(
                                                  textStyle: const TextStyle(
                                                      fontSize: 25)),
                                            ),
                                            Text(
                                              "Connectez vous ou inscrivez vous pour acceder a toutes les fonctionnalites de l'application et pour garder une trace de tout vos activites et vos abonnements.",
                                              style: GoogleFonts.jura(
                                                  textStyle: const TextStyle(
                                                      fontSize: 10)),
                                            )
                                          ],
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(),
                                              onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const Debut_Inscription())),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(LucideIcons.userPlus),
                                                  Text("Me connecter")
                                                ],
                                              ))
                                        ],
                                      );
                                    });
                              }

                              _controller.forward();
                            },
                            icon: is_like
                                ? const Icon(
                                    Icons.favorite_rounded,
                                    color: Color.fromARGB(255, 238, 75, 63),
                                    size: 30,
                                    shadows: [
                                      BoxShadow(
                                        offset: const Offset(-1, -1),
                                        color: Colors.white,
                                      )
                                    ],
                                  )
                                : Icon(
                                    Icons.favorite_border_rounded,
                                    color: Colors.white,
                                    size: 28,
                                    shadows: [
                                      BoxShadow(
                                        offset: const Offset(3, 3),
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 7,
                                      )
                                    ],
                                  )),
                      )),
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
                      Text(truncate(widget.wonderscat.wonderName),
                          style: GoogleFonts.lalezar(
                              textStyle: const TextStyle(fontSize: 20))),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 8, 71, 122),
                                borderRadius: BorderRadius.circular(3)),
                            child: Text(
                              widget.wonderscat.city,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const Icon(LucideIcons.dot),
                          Text("Région du : ${widget.wonderscat.region}"),
                          const Icon(LucideIcons.dot),
                          const Text("24km"),
                        ],
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              // Pleines étoiles
                              Row(
                                children: List.generate(
                                  widget.wonderscat.note.floor(),
                                  (index) => const Icon(
                                    Icons.star_rounded,
                                    color: Colors.orange,
                                    size: 15,
                                  ),
                                ),
                              ),
                              // Demi-étoile si nécessaire
                              if (widget.wonderscat.note -
                                          widget.wonderscat.note.floor() !=
                                      1 &&
                                  widget.wonderscat.note -
                                          widget.wonderscat.note.floor() !=
                                      0)
                                const Icon(
                                  Icons.star_half_rounded,
                                  color: Colors.orange,
                                  size: 15,
                                ),
                              // Étoiles vides
                              if (widget.wonderscat.note.floor() != 5 &&
                                  widget.wonderscat.note -
                                          widget.wonderscat.note.floor() ==
                                      0)
                                Row(
                                  children: List.generate(
                                    5 - widget.wonderscat.note.floor(),
                                    (index) => const Icon(
                                      Icons.star_border_rounded,
                                      color: Colors.orange,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              if (widget.wonderscat.note.floor() != 5 &&
                                  widget.wonderscat.note -
                                          widget.wonderscat.note.floor() !=
                                      1 &&
                                  widget.wonderscat.note -
                                          widget.wonderscat.note.floor() !=
                                      0)
                                Row(
                                  children: List.generate(
                                    4 - widget.wonderscat.note.floor(),
                                    (index) => const Icon(
                                      Icons.star_border_rounded,
                                      color: Colors.orange,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              if (widget.wonderscat.note.floor() == 5 &&
                                  widget.wonderscat.note -
                                          widget.wonderscat.note.floor() !=
                                      1 &&
                                  widget.wonderscat.note -
                                          widget.wonderscat.note.floor() !=
                                      0)
                                Row(
                                  children: List.generate(
                                    4 - widget.wonderscat.note.floor(),
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
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            width: 2,
                            height: 20,
                            color: const Color(0xff226900),
                          ),
                          Text(
                            widget.wonderscat.note.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      Text(
                        "Personnes qui aiment ce lieu : ${widget.wonderscat.note}",
                        style: const TextStyle(
                            color: Color(0xff226900),
                            fontWeight: FontWeight.bold),
                      )
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
  FilterDialog({super.key, required this.cat, required this.listewonderscat});
  final Categorie cat;
  Stream<QuerySnapshot> listewonderscat;

  @override
  FilterDialogState createState() => FilterDialogState();
}

class FilterDialogState extends State<FilterDialog> {
  String _selectedRegion = 'Toutes les régions';
  String _selectedCity = 'Toutes les villes';
  String _selectedForfait = 'Tout';

  final List<String> _forfaits = [
    'Tout',
    'Payants',
    'Non payants',
  ];

  final List<String> _regions = [
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
  ];

  final List<String> _cities = [
    'Toutes les villes',
    'Yaoundé',
    'Douala',
    'Garoua',
    'Bamenda',
    'Maroua',
    'Ngaoundéré',
    'Bafoussam',
    'Bertoua',
    'Ebolowa',
    'Limbe',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Définissez vos options de filtrage'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            const Text('Les wonders à afficher'),
            DropdownButtonFormField<String>(
              value: _selectedForfait,
              onChanged: (newValue) {
                setState(() {
                  _selectedForfait = newValue!;
                });
              },
              items: _forfaits.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Choisir une région :'),
            DropdownButtonFormField<String>(
              value: _selectedRegion,
              onChanged: (newValue) {
                setState(() {
                  _selectedRegion = newValue!;
                });
              },
              items: _regions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Choisir une ville :'),
            DropdownButtonFormField<String>(
              value: _selectedCity,
              onChanged: (newValue) {
                setState(() {
                  _selectedCity = newValue!;
                });
              },
              items: _cities.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
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
            final wondersProvider = Provider.of<WondersProvider>(context, listen: false);
            wondersProvider.applyFilters(_selectedForfait, _selectedRegion, _selectedCity, widget.cat.categoryName);
            Navigator.of(context).pop();
          },
          child: const Text('Appliquer'),
        ),
      ],
    );
  }
}

