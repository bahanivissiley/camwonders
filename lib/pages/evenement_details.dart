import 'package:cached_network_image/cached_network_image.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/class/classes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';


class EvenementDetails extends StatefulWidget {
  const EvenementDetails({super.key, required this.evenement, required this.wond});
  final Evenements evenement;
  final Wonder wond;

  @override
  State<EvenementDetails> createState() => _EvenementDetailsState();
}

class _EvenementDetailsState extends State<EvenementDetails> {


  @override
  void initState() {
    super.initState();
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
                    imageUrl: widget.evenement.imagePath,
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
                            borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                            color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xff222222),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 30),
                                  child: Text("Evénement ${widget.evenement.title}", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 22)),),
                                ),
                                Container(
                                  height: 30,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Center(child: Text(widget.evenement.date, style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 12, color: Colors.black)),)),
                                ),
                                Text("Lieu : ${widget.wond.wonderName}", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15, color: Colors.grey)),),

                                const SizedBox(height: 20),

                                Text(widget.evenement.contenu, style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15)),),

                                const SizedBox(height: 20),

                                Text("Pour participer a cette evenemenent, veillez cliquez sur le boutton pour pouvoir passer un appel et demander plus d'informations", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 10, color: Colors.red)),),


                                const SizedBox(height: 10),

                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final Uri launchUri = Uri(
                                        scheme: 'tel',
                                        path: widget.evenement.numeroTel,
                                      );
                                      if (await canLaunchUrl(launchUri)) {
                                      await launchUrl(launchUri);
                                      } else {
                                      }
                                    },
                                    child: const Text("Appeler"),
                                  ),
                                ),

                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final String message = "J'ai vu l'événement *${widget.evenement.title}* sur *_Camwonders_* est il possible d'y participer";
                                      final String url = "https://wa.me/${widget.evenement.numeroTel}?text=${Uri.encodeComponent(message)}";
                                      if (await canLaunch(url)) {
                                      await launch(url);
                                      } else {
                                      throw 'Could not launch $url';
                                      }
                                    },
                                    child: const Text("Whatsapp"),
                                  ),
                                )
                              ],
                            ),
                          )
                      )
                  )



                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
