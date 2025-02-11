import 'package:cached_network_image/cached_network_image.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/class/classes.dart';
import 'package:camwonders/pages/wonder_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ReservationDetails extends StatefulWidget {
  const ReservationDetails(
      {super.key, required this.reservation, required this.wond});
  final Reservations reservation;
  final Wonder wond;

  @override
  State<ReservationDetails> createState() => _ReservationDetailsState();
}

class _ReservationDetailsState extends State<ReservationDetails> {
  String devise = "FCFA";
  @override
  void initState() {
    super.initState();
    chargercached();
  }

  Future<void> chargercached() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      devise = prefs.getString('devise')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Retour à l'écran précédent
          },
        ),
        backgroundColor: Colors.transparent, // Arrière-plan transparent
        elevation: 0,
      ),

      body: Stack(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl: widget.wond.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 300,
                width: MediaQuery.of(context).size.width,
                color: Colors.black.withValues(alpha:0.5),
              ),
            ],
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    color: Colors.transparent,
                    height: 250,
                  ),
                  Expanded(
                      child: Container(
                          padding: const EdgeInsets.all(30),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(30),
                                topLeft: Radius.circular(30)),
                            color: Theme.of(context).brightness ==
                                    Brightness.light
                                ? Colors.white
                                : const Color(0xff222222),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 30),
                                  child: Text(
                                    widget.wond.wonderName,
                                    style: GoogleFonts.lalezar(
                                        textStyle: const TextStyle(
                                            fontSize: 25,
                                            color: Color(0xff226900))),
                                  ),
                                ),
                                Text(
                                  "Date : ${widget.reservation.date}",
                                  style: GoogleFonts.jura(
                                      textStyle: const TextStyle(fontSize: 15)),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                WonderPage(
                                                    wond: widget.wond)));
                                  },
                                  child: Text(
                                    "Voir le lieu...",
                                    style: GoogleFonts.jura(
                                        textStyle: const TextStyle(
                                            fontSize: 15,
                                            decoration:
                                                TextDecoration.underline,
                                            color: Color(0xff226900))),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey, width: 1))),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Statut :  ",
                                        style: GoogleFonts.lalezar(
                                            textStyle:
                                                const TextStyle(fontSize: 20)),
                                      ),
                                      Container(
                                        height: 40,
                                        width: 130,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: widget.reservation.isload
                                              ? Colors.amber
                                              : widget.reservation.isvalidate
                                                  ? const Color(0xff226900)
                                                  : Colors.red,
                                        ),
                                        child: Center(
                                            child: Text(
                                          widget.reservation.isload
                                              ? "En cours"
                                              : widget.reservation.isvalidate
                                                  ? "Disponible"
                                                  : "Pas disponible",
                                          style: GoogleFonts.lalezar(
                                              textStyle: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white)),
                                        )),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.only(bottom: 10, top: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Motif :  ",
                                        style: GoogleFonts.lalezar(
                                            textStyle:
                                                const TextStyle(fontSize: 20)),
                                      ),
                                      Text(
                                        widget.reservation.motif,
                                        style: GoogleFonts.lalezar(
                                            textStyle:
                                                const TextStyle(fontSize: 15)),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Lorsque votre reservation est marqué disponible, vous avez 24h pour appeler et confirmer, sinon votre reservation est annulé",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.jura(
                                      textStyle: const TextStyle(fontSize: 15)),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      decoration: const BoxDecoration(),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.monetization_on,
                                              color: Colors.amber, size: 30),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Prix :",
                                                style: GoogleFonts.jura(
                                                    textStyle: const TextStyle(
                                                        fontSize: 11)),
                                              ),
                                              Text(
                                                devise == 'FCFA'
                                                    ? "${widget.reservation.nbrePersonnes * widget.wond.price} Fcfa"
                                                    : devise == 'Dollar'
                                                        ? "\$${((widget.reservation.nbrePersonnes * widget.wond.price) / 600).toStringAsFixed(2)}"
                                                        : "...",
                                                style: GoogleFonts.lalezar(
                                                    textStyle: const TextStyle(
                                                        fontSize: 13)),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      decoration: const BoxDecoration(),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.people,
                                              color: Color(0xff226900),
                                              size: 30),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Nombre :",
                                                style: GoogleFonts.jura(
                                                    textStyle: const TextStyle(
                                                        fontSize: 11)),
                                              ),
                                              Text(
                                                "${widget.reservation.nbrePersonnes} Personnes",
                                                style: GoogleFonts.lalezar(
                                                    textStyle: const TextStyle(
                                                        fontSize: 13)),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      decoration: const BoxDecoration(),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.phone,
                                              color: Color.fromARGB(
                                                  255, 8, 71, 122),
                                              size: 30),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Telephone :",
                                                style: GoogleFonts.jura(
                                                    textStyle: const TextStyle(
                                                        fontSize: 11)),
                                              ),
                                              Text(
                                                widget.reservation.numeroTel,
                                                style: GoogleFonts.lalezar(
                                                    textStyle: const TextStyle(
                                                        fontSize: 13)),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (widget.reservation.isvalidate) {
                                        final Uri launchUri = Uri(
                                          scheme: 'tel',
                                          path: widget.reservation.numeroTel,
                                        );
                                        if (await canLaunchUrl(launchUri)) {
                                          await launchUrl(launchUri);
                                        } else {

                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                            "Votre reservation n'a pas été validé",
                                            style: TextStyle(
                                                color: Colors.white),
                                          ),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                    },
                                    child: const Text("Appeler"),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (widget.reservation.isvalidate) {
                                        final String message =
                                            "Je souhaiterai confirmer ma reservation pour le lieu *${widget.wond.wonderName}* vu sur *_Camwonders_*";
                                        final String url =
                                            "https://wa.me/${widget.reservation.numeroTel}?text=${Uri.encodeComponent(message)}";
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                            "Votre reservation n'a pas été validé",
                                            style: TextStyle(
                                                color: Colors.white),
                                          ),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                    },
                                    child: const Text("Whatsapp"),
                                  ),
                                )
                              ],
                            ),
                          )))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
