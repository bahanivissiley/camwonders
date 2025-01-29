import 'package:cached_network_image/cached_network_image.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/class/classes.dart';
import 'package:camwonders/pages/wonder_page.dart';
import 'package:camwonders/services/camwonders.dart';
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      devise = prefs.getString('devise')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //padding: const EdgeInsets.all(50),
        child: Stack(
          children: [
            Stack(
              children: [
                Container(
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
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Container(
                      color: Colors.transparent,
                      height: 250,
                    ),
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.all(30),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  topLeft: Radius.circular(30)),
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : Color(0xff222222),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 30),
                                    child: Text(
                                      widget.wond.wonderName,
                                      style: GoogleFonts.lalezar(
                                          textStyle: TextStyle(
                                              fontSize: 25,
                                              color: Color(0xff226900))),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      "Date : ${widget.reservation.date}",
                                      style: GoogleFonts.jura(
                                          textStyle: TextStyle(fontSize: 15)),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  wonder_page(
                                                      wond: widget.wond)));
                                    },
                                    child: Text(
                                      "Voir le lieu...",
                                      style: GoogleFonts.jura(
                                          textStyle: TextStyle(
                                              fontSize: 15,
                                              decoration:
                                                  TextDecoration.underline,
                                              color: Color(0xff226900))),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    padding: EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
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
                                                  TextStyle(fontSize: 20)),
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
                                                    ? Color(0xff226900)
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
                                                textStyle: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white)),
                                          )),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.only(bottom: 10, top: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Motif :  ",
                                          style: GoogleFonts.lalezar(
                                              textStyle:
                                                  TextStyle(fontSize: 20)),
                                        ),
                                        Text(
                                          widget.reservation.motif,
                                          style: GoogleFonts.lalezar(
                                              textStyle:
                                                  TextStyle(fontSize: 15)),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "Lorsque votre reservation est marqué disponible, vous avez 24h pour appeler et confirmer, sinon votre reservation est annulé",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.jura(
                                        textStyle: TextStyle(fontSize: 15)),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.monetization_on,
                                                color: Colors.amber, size: 30),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Prix :",
                                                  style: GoogleFonts.jura(
                                                      textStyle: TextStyle(
                                                          fontSize: 11)),
                                                ),
                                                Text(
                                                  devise == 'FCFA'
                                                      ? "${widget.reservation.nbrePersonnes * widget.wond.price} Fcfa"
                                                      : devise == 'Dollar'
                                                          ? "\$${((widget.reservation.nbrePersonnes * widget.wond.price) / 600).toStringAsFixed(2)}"
                                                          : "...",
                                                  style: GoogleFonts.lalezar(
                                                      textStyle: TextStyle(
                                                          fontSize: 13)),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.people,
                                                color: Color(0xff226900),
                                                size: 30),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Nombre :",
                                                  style: GoogleFonts.jura(
                                                      textStyle: TextStyle(
                                                          fontSize: 11)),
                                                ),
                                                Text(
                                                  "${widget.reservation.nbrePersonnes} Personnes",
                                                  style: GoogleFonts.lalezar(
                                                      textStyle: TextStyle(
                                                          fontSize: 13)),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.phone,
                                                color: Color.fromARGB(
                                                    255, 8, 71, 122),
                                                size: 30),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Telephone :",
                                                  style: GoogleFonts.jura(
                                                      textStyle: TextStyle(
                                                          fontSize: 11)),
                                                ),
                                                Text(
                                                  "${widget.reservation.numeroTel}",
                                                  style: GoogleFonts.lalezar(
                                                      textStyle: TextStyle(
                                                          fontSize: 13)),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
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
                                            print(
                                                'Impossible de lancer l\'appel téléphonique');
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                              "Votre reservation n'a pas été validé",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
                                      },
                                      child: Text("Appeler"),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (widget.reservation.isvalidate) {
                                          String message =
                                              "Je souhaiterai confirmer ma reservation pour le lieu *${widget.wond.wonderName}* vu sur *_Camwonders_*";
                                          String url =
                                              "https://wa.me/${widget.reservation.numeroTel}?text=${Uri.encodeComponent(message)}";
                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          } else {
                                            throw 'Could not launch $url';
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                              "Votre reservation n'a pas été validé",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
                                      },
                                      child: Text("Whatsapp"),
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
      ),
    );
  }
}
