import 'package:camwonders/auth_pages/debut_inscription.dart';
import 'package:camwonders/pages/AbonnementPage.dart';
import 'package:camwonders/pages/bottomNavigator/page_favoris.dart';
import 'package:camwonders/pages/bottomNavigator/reservations.dart';
import 'package:camwonders/services/cachemanager.dart';
import 'package:camwonders/class/Categorie.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/firebase/supabase_logique.dart';
import 'package:camwonders/services/logique.dart';
import 'package:camwonders/pages/bottomNavigator/menu/menu.dart';
import 'package:camwonders/pages/bottomNavigator/profil.dart';
import 'package:camwonders/pages/wonder_page.dart';
import 'package:camwonders/pages/bottomNavigator/wondershort.dart';
import 'package:camwonders/shimmers_effect/menu_shimmer.dart';
import 'package:camwonders/widgetGlobal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PageCategorie extends StatefulWidget {
  final String cat;
  final int id_categorie;
  const PageCategorie({super.key, required this.cat, required this.id_categorie});

  @override
  State<PageCategorie> createState() => _PageCategorieState();
}

class _PageCategorieState extends State<PageCategorie> {
  int _selectedItem = 5;
  static const verte = Color(0xff226900);

  @override
  void initState() {
    super.initState();
    _verifyConnection();
      Future.microtask(() {
        Provider.of<WondersProvider>(context, listen: false).loadCategorie(widget.id_categorie);
      });

    print(widget.cat);
    print(widget.id_categorie);
    print(widget.id_categorie);
    print(widget.id_categorie);
    print(widget.id_categorie);
    print(widget.id_categorie);

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
      WondersBody(
        size: size,
        cat: widget.cat, id_categorie: widget.id_categorie,
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
                                  ? Colors.grey.withValues(alpha:0.3)
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
                                  ? Colors.grey.withValues(alpha:0.3)
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
                                  ? Colors.grey.withValues(alpha:0.3)
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
                                  ? Colors.grey.withValues(alpha:0.3)
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
                                  ? Colors.grey.withValues(alpha:0.3)
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

class WondersBody extends StatefulWidget {
  WondersBody({
    super.key,
    required this.size,
    required this.cat, required this.id_categorie,
  });

  final Size size;
  final String cat;
  final int id_categorie;

  @override
  State<WondersBody> createState() => _WondersBodyState();
}

class _WondersBodyState extends State<WondersBody> {

  final TextEditingController _controller = TextEditingController();

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

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);
    final wonderProvider = Provider.of<WondersProvider>(context);
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: Center(child: Text(widget.cat)),
        actions: [
          AuthService().currentUser == null
              ? Container(
            margin: const EdgeInsets.only(right: 10),
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
                          color: Colors.grey.withValues(alpha:0.2),
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
                          Provider.of<WondersProvider>(context, listen: false).setSearchQuery(value.toLowerCase(), widget.id_categorie);

                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return FilterDialog(
                              cat: widget.cat, id_categorie: widget.id_categorie,
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
              child: widget.size != 0
                  ? LiquidPullToRefresh(
                      onRefresh: _handleRefresh,
                      color: _PageCategorieState.verte,
                      backgroundColor: Colors.white,
                      height: 50,
                      showChildOpacityTransition: false,
                      springAnimationDurationInMilliseconds: 700,
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: wonderProvider.wondersStream,
                        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                          if (snapshot.hasError) {
                            return const Text("Quelques choses n'a pas bien marché");
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

                          if (snapshot.data!.isEmpty) {
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
                                const Text("Vide, pas de wonder !")
                              ],
                            ));
                          }

                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Map<String, dynamic> document = snapshot.data![index];
                                final Wonder wond = Wonder(
                                    idWonder: document['id'],
                                    wonderName: document['wonder_name'],
                                    description: document['description'],
                                    imagePath: document['image_path'],
                                    city: document['city'],
                                    region: document['region'],
                                    free: document['free'],
                                    price: document['price'],
                                    horaire: document['horaire'],
                                    latitude: document['latitude'],
                                    longitude: document['longitude'],
                                    note: (document['note'] as num).toDouble(),
                                    categorie: document['categorie'],
                                    isreservable: document['is_reservable'],
                                    acces: document['acces'],
                                    description_acces: document['description_acces'],
                                    is_premium: document['is_premium']);
                                return GestureDetector(
                                  onTap: () {
                                    (userProvider.isPremium || wond.is_premium) ? Navigator.push(
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
                                    ) :
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => SubscriptionPage()));
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

class WonderWidget extends StatefulWidget {
  const WonderWidget({
    super.key,
    required this.size,
    required this.wonderscat,
  });

  final Size size;
  final Wonder wonderscat;

  @override
  State<WonderWidget> createState() => _WonderWidgetState();
}

// ignore: camel_case_types
class _WonderWidgetState extends State<WonderWidget>
    with SingleTickerProviderStateMixin {
  bool isLike = false;
  late Box<Wonder> favorisBox;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    favorisBox = Hive.box<Wonder>('favoris_wonder');
    final bool estPresent = favorisBox.values.any((wonderDeLaBox) =>
    wonderDeLaBox.idWonder == widget.wonderscat.idWonder);
    if (estPresent) {
      isLike = true;
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
    final userProvider = Provider.of<UserProvider>(context);
    return Animate(
      effects: [FadeEffect(duration: 500.ms)],
      child: Container(
        //height: 350,
        width: widget.size.width,
        margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border(
              bottom:
                  BorderSide(color: Colors.grey.withValues(alpha:0.5)),
              top:
              BorderSide(color: Colors.grey.withValues(alpha:0.5)),
              right:
              BorderSide(color: Colors.grey.withValues(alpha:0.5)),
              left:
          BorderSide(color: Colors.grey.withValues(alpha:0.5))),
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

                      child: Stack(
                        children: [
                          SizedBox(
                            height: 250,
                            width: widget.size.width,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
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



                          (userProvider.isPremium || widget.wonderscat.is_premium)
                              ? const SizedBox()  // Un widget vide au lieu d'un Center inutile
                              : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                              color: Colors.black.withValues(alpha:0.6),
                            ),
                            height: 250,
                            width: widget.size.width,

                            child: const Icon(Icons.lock, size: 100, color: Colors.white),
                          ),

                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      width: 50,
                      margin: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: ScaleTransition(
                        scale: _animation,
                        child: IconButton(
                            onPressed: () {
                              if (AuthService().currentUser != null) {
                                setState(() {
                                  if (isLike) {
                                    isLike = false;
                                    Logique().supprimerFavorisWonder(
                                        favorisBox.length - 1);
                                  } else {
                                    SetFavorisWonder(widget.wonderscat);
                                    isLike = true;
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
                                        title: Row(
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
                                                                                ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
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
                            icon: isLike
                                ? const Icon(
                                    Icons.favorite_rounded,
                                    color: Color.fromARGB(255, 238, 75, 63),
                                    size: 30,
                                    shadows: [
                                      BoxShadow(
                                        offset: Offset(-1, -1),
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
                                        color: Colors.black.withValues(alpha:0.5),
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
  FilterDialog({super.key, required this.cat, required this.id_categorie});
  final String cat;
  final int id_categorie;

  @override
  FilterDialogState createState() => FilterDialogState();
}

class FilterDialogState extends State<FilterDialog> {
  String _selectedRegion = 'Toutes les régions';
  String _selectedCity = 'Toutes les villes';
  String _selectedForfait = 'Tout';
  double _selectedDistance = 10.0; // Distance par défaut en kilomètres
  Position? _currentPosition;

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
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    final wondersProvider = Provider.of<WondersProvider>(context);
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
            Text('Distance maximale (km) : $_selectedDistance'),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.green,
                inactiveTrackColor: Colors.grey,
                thumbColor: Colors.green,
                overlayColor: Colors.green.withOpacity(0.2),
                valueIndicatorColor: Colors.green,
                trackHeight: 4.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0),
              ),
              child: Slider(
                value: _selectedDistance,
                min: 1,
                max: 1000,
                divisions: 999,
                label: _selectedDistance.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _selectedDistance = value;
                  });
                },
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
            wondersProvider.applyFilters(
              _selectedForfait,
              _selectedRegion,
              _currentPosition,
              _selectedDistance,
              widget.id_categorie,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Appliquer'),
        ),
      ],
    );
  }
}

