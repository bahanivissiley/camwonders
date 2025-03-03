import 'package:cached_network_image/cached_network_image.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/class/classes.dart';
import 'package:camwonders/pages/reservation_details.dart';
import 'package:camwonders/services/cachemanager.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:camwonders/shimmers_effect/menu_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class reservations extends StatefulWidget {
  const reservations({super.key});

  @override
  State<reservations> createState() => _reservationsState();
}

class _reservationsState extends State<reservations> {
  List<Reservations> reservations = [];
  Future<List<Map<String, dynamic>>>? futureReservations;

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  void fetchReservations() {
    setState(() {
      futureReservations = Camwonder().getReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
              child: Text(
            "Reservations",
            style: GoogleFonts.lalezar(
                textStyle:
                    const TextStyle(color: Color(0xff226900), fontSize: 23)),
          )),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 100,
              child: Column(
                children: [
                  Text(
                    "Toutes vos reservations",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.lalezar(
                        textStyle: const TextStyle(fontSize: 30)),
                  ),
                  Text(
                    "Cliquez pour avoir les informations sur chaque reservation",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jura(
                        textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: futureReservations,
                  builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: Color(0xff226900),
                      ));
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text("Vous n'etes pas connecté "),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: size.height / 8,
                            child:
                                Theme.of(context).brightness == Brightness.light
                                    ? Image.asset('assets/reservation.png')
                                    : Image.asset('assets/reservation.png'),
                          ),
                          const Text("Pas de reservations")
                        ],
                      ));
                    } else {
                      return ListView(
                        shrinkWrap: true,
                        children: snapshot.data!
                            .map((Map<String, dynamic> document) {
                          final Reservations reservation = Reservations(
                              idReservation: document['id'],
                              user: document['user'],
                              nbrePersonnes: document['nbre_personnes'],
                              numeroTel: document['numero_tel'],
                              idWonder: document['wonder'],
                              date: document['date'],
                              isvalidate: document['is_validate'],
                              isload: document['is_load'],
                              motif: document['motif']);
                          return FavorisWidget(
                            reservation: reservation,
                            Ondelete: fetchReservations,
                          );
                        }).toList(),
                      );
                    }
                  }),
            ),
          ],
        ));
  }
}

class FavorisWidget extends StatefulWidget {
  const FavorisWidget({
    super.key,
    required this.reservation,
    required this.Ondelete,
  });

  final Reservations reservation;
  final VoidCallback Ondelete;

  @override
  State<FavorisWidget> createState() => _FavorisWidgetState();
}

class _FavorisWidgetState extends State<FavorisWidget> {
  Wonder wond = Wonder(
      idWonder: 1,
      wonderName: "chargement...",
      description: "chargement...",
      imagePath: "chargement...",
      city: "chargement...",
      region: "chargement...",
      free: false,
      price: 500,
      horaire: "chargement...",
      latitude: 0.0,
      longitude: 0.0,
      note: 0.0,
      categorie: 0,
      isreservable: false,
      acces: "Par voiture",
  description_acces: 'Par voiture',
  is_premium: true);

  bool isNetworkImage = false;

  String truncate(String text) {
    if (text.length > 25) {
      return "${text.substring(0, 25)}...";
    }
    return text;
  }

  @override
  void initState() {
    super.initState();
    _loadWond();
  }

  void _loadWond() async {
    final Wonder? wondd =
        await Camwonder().getWonderById(widget.reservation.idWonder);
    setState(() {
      if (wondd != null) {
        wond = wondd;
        isNetworkImage = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => ReservationDetails(
                    reservation: widget.reservation, wond: wond),
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
      child: Dismissible(
        key: Key(wond.wonderName),
        background: Container(
            margin: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(10)),
            child: const Center(
                child: Icon(
              LucideIcons.trash,
              color: Colors.white,
            ))),
        confirmDismiss: (DismissDirection direction) async {
          return await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha:0.2),
                              borderRadius: BorderRadius.circular(500)),
                          height: 80,
                          width: 80,
                          child: const Icon(
                            Icons.help,
                            size: 40,
                            color: Colors.red,
                          )),
                    ],
                  ),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Suppression",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      Center(
                          child: Text(
                        "Etes vous sûr de vouloir supprimer cette reservation ?",
                        style: TextStyle(color: Colors.grey),
                      ))
                    ],
                  ),
                  actions: [
                    Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () {
                                Navigator.pop(context);
                                Camwonder().deleteReservation(
                                    widget.reservation.idReservation);
                                widget.Ondelete();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Center(
                                        child: Text(
                                            "Element suprimé des Favoris !")),
                                  ),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                ));
                              },
                              child: const Text("Supprimer")),
                        ),
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Annuler",
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : Colors.white),
                            )),
                      ],
                    )
                  ],
                );
              });
        },
        onDismissed: (DismissDirection direction) {
          Camwonder().deleteReservation(widget.reservation.idReservation);
          widget.Ondelete();
        },
        child: Container(
          //width: MediaQuery.of(context).size.width*4/5,
          margin: const EdgeInsets.only(
            bottom: 10,
            left: 10,
            right: 10,
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.grey.withValues(alpha:0.5))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: MediaQuery.of(context).size.width / 4,
                width: MediaQuery.of(context).size.width / 4,
                margin: const EdgeInsets.only(right: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: isNetworkImage
                      ? CachedNetworkImage(
                          cacheManager: CustomCacheManager(),
                          imageUrl: wond.imagePath,
                          placeholder: (context, url) => Center(
                              child: shimmerOffre(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height:
                                      MediaQuery.of(context).size.width / 4)),
                          errorWidget: (context, url, error) =>
                              const Center(child: Icon(Icons.error)),
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: shimmerOffre(
                              width: MediaQuery.of(context).size.width / 4,
                              height: MediaQuery.of(context).size.width / 4)),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        truncate(wond.wonderName),
                        style: GoogleFonts.lalezar(
                            textStyle: const TextStyle(fontSize: 18)),
                      ),
                      Text(
                        'Reservation de ${widget.reservation.nbrePersonnes} personnes',
                        style: GoogleFonts.jura(
                            textStyle: const TextStyle(fontSize: 13)),
                      ),
                      Text(
                        'Date : ${widget.reservation.date}',
                        style: GoogleFonts.jura(
                            textStyle: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                      ),
                    ],
                  ),
                  widget.reservation.isload
                      ? Container(
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12))),
                          child: Center(
                              child: Text(
                            "En cours",
                            style: GoogleFonts.lalezar(
                                textStyle: const TextStyle(
                              color: Colors.amber,
                            )),
                          )),
                        )
                      : widget.reservation.isvalidate
                          ? Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(12))),
                                    child: Center(
                                        child: Text(
                                      "Traité",
                                      style: GoogleFonts.lalezar(
                                          textStyle: const TextStyle()),
                                    )),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(12))),
                                    child: Center(
                                        child: Text(
                                      "Disponible",
                                      style: GoogleFonts.lalezar(
                                          textStyle: const TextStyle(
                                        color: Color(0xff226900),
                                      )),
                                    )),
                                  ),
                                ],
                              ))
                          : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(12))),
                                    child: Center(
                                        child: Text(
                                      "Traité",
                                      style: GoogleFonts.lalezar(
                                          textStyle: const TextStyle()),
                                    )),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(12))),
                                    child: Center(
                                        child: Text(
                                      "Pas disponible",
                                      style: GoogleFonts.lalezar(
                                          textStyle: const TextStyle(
                                        color: Colors.red,
                                      )),
                                    )),
                                  ),
                                ],
                              ))
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: Color(0xff226900),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }
}
