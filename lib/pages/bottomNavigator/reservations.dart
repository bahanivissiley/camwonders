import 'package:cached_network_image/cached_network_image.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/class/classes.dart';
import 'package:camwonders/pages/reservation_details.dart';
import 'package:camwonders/services/cachemanager.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:camwonders/shimmers_effect/menu_shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  static Future<QuerySnapshot<Object?>> futurreservations = Camwonder().getReservations();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
              child: Text(
            "Reservations",
            style: GoogleFonts.lalezar(
                textStyle: const TextStyle(
                    color: Colors.personnalgreen, fontSize: 23)),
          )),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Toutes vos reservations", textAlign: TextAlign.left, style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 30)),),
                  Text("Cliquez pour avoir les informations sur chaque reservation", textAlign: TextAlign.center, style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold)),)
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                  future: Camwonder().getReservations(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: Colors.personnalgreen,
                      ));
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text("Vous n'etes pas connecté "),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: size.height / 12,
                            child: Theme.of(context).brightness == Brightness.light
                                ? Image.asset('assets/vide_light.png')
                                : Image.asset('assets/vide_dark.png'),
                          ),
                          const Text("Pas de reservations")
                        ],
                      ));
                    } else {
                      return ListView(
                        shrinkWrap: true,
                        children:
                            snapshot.data!.docs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          Reservations reservation = Reservations(idReservation: document.id, user: data['user'], nbrePersonnes: data['nbrePersonnes'], numeroTel: data['numeroTel'], idWonder: data['idWonder'], date: data['date'], isvalidate: data['isvalidate'], isload: data['isload'], motif: data['motif']);
                          return FavorisWidget(reservation: reservation);
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
  });

  final Reservations reservation;

  @override
  State<FavorisWidget> createState() => _FavorisWidgetState();
}

class _FavorisWidgetState extends State<FavorisWidget> {
  Wonder wond = Wonder(
      idWonder: "chargement...",
      wonderName: "chargement...",
      description: "chargement...",
      imagePath: "chargement...",
      city: "chargement...",
      region: "chargement...",
      free: false,
      price: 500,
      horaire: "chargement...",
      latitude: "chargement...",
      longitude: "chargement...",
      note: 0.0,
      categorie: "chargement...",
      isreservable: false
  );
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
    Wonder? wondd = await Camwonder().getWonderById(widget.reservation.idWonder);
    setState(() {
      if (wondd != null) {
        wond = wondd;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => ReservationDetails(reservation: widget.reservation, wond: wond),
            transitionsBuilder: (_,animation,__,child){
              return SlideTransition(
                position: Tween<Offset> (begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut, reverseCurve: Curves.easeInOutBack)),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 700)
        )
        );
      },
      child: Dismissible(
        key: Key(wond.wonderName),
        background: Container(
            margin: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10)
            ),
            child: const Center(child: Icon(LucideIcons.trash, color: Colors.white,))
        ),

        confirmDismiss: (DismissDirection direction) async {
          return await showDialog<bool>(context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Center(child: Text("Suppression")),
                  content: Container(
                    padding: const EdgeInsets.all(20),
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Icon(LucideIcons.helpCircle, color: Colors.red, size: 50,),
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
                          Camwonder().deleteReservation(widget.reservation.idReservation);
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

                        child: const Text("Supprimer"))
                  ],
                );
              });
        },

        onDismissed: (DismissDirection direction){
          Navigator.pop(context);
          Camwonder().deleteReservation(widget.reservation.idReservation);
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
                  Border.all(width: 1.0, color: Colors.grey.withOpacity(0.5))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: MediaQuery.of(context).size.width / 4,
                width: MediaQuery.of(context).size.width / 4,
                margin: const EdgeInsets.only(right: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    cacheManager: CustomCacheManager(),
                    imageUrl: wond.imagePath,
                    placeholder: (context, url) => Center(child: shimmerOffre(width: MediaQuery.of(context).size.width / 4, height: MediaQuery.of(context).size.width / 4)),
                    errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.error)),
                    fit: BoxFit.cover,
                  ),
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
                            textStyle: const TextStyle(
                                fontSize: 13)),
                      ),
                      Text(
                        'Date : ${widget.reservation.date}',
                        style: GoogleFonts.jura(
                            textStyle: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                      ),

                    ],
                  ),

                  widget.reservation.isload ?
                  Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12))
                    ),
                    child: Center(child: Text("En cours", style: GoogleFonts.lalezar(textStyle: const TextStyle(color: Colors.amber,)),)),
                  ) : widget.reservation.isvalidate ?
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(topRight: Radius.circular(12))
                            ),
                            child: Center(child: Text("Traité", style: GoogleFonts.lalezar(textStyle: const TextStyle()),)),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(bottomRight: Radius.circular(12))
                            ),
                            child: Center(child: Text("Disponible", style: GoogleFonts.lalezar(textStyle: const TextStyle(color: Colors.personnalgreen,)),)),
                          ),
                        ],
                      )
                  ) :
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(topRight: Radius.circular(12))
                            ),
                            child: Center(child: Text("Traité", style: GoogleFonts.lalezar(textStyle: const TextStyle()),)),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(bottomRight: Radius.circular(12))
                            ),
                            child: Center(child: Text("Pas disponible", style: GoogleFonts.lalezar(textStyle: const TextStyle(color: Colors.red,)),)),
                          ),
                        ],
                      )
                  )
                ],
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.personnalgreen,),
              SizedBox(width: 5),

            ],
          ),
        ),
      ),
    );
  }
}
