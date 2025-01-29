import 'package:cached_network_image/cached_network_image.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/class/classes.dart';
import 'package:camwonders/pages/wonder_page.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';


class GuidesDetails extends StatefulWidget {
  const GuidesDetails({super.key, required this.guide});
  final Guide guide;

  @override
  State<GuidesDetails> createState() => _GuidesDetailsState();
}

class _GuidesDetailsState extends State<GuidesDetails> {


  @override
  void initState() {
    super.initState();
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
                SizedBox(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl: widget.guide.profilPath,
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
                            padding: EdgeInsets.all(30),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                              color: Theme.of(context).brightness == Brightness.light ? Colors.white : Color(0xff222222),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 30),
                                    child: Text(widget.guide.nom ,style: GoogleFonts.lalezar(textStyle: TextStyle(fontSize: 22)),),
                                  ),
                                  Container(
                                    height: 30,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Center(child: Text('Guide certifié', style: GoogleFonts.jura(textStyle: TextStyle(fontSize: 12, color: Colors.black)),)),
                                  ),


                                  SizedBox(height: 20),

                                  Text("Tout les guides de notre plateforme sont verifié et ont la capacité de communication necessaire pour vous accompagner", style: GoogleFonts.jura(textStyle: TextStyle(fontSize: 10, color: Colors.red)),),


                                  SizedBox(height: 10),

                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final Uri launchUri = Uri(
                                          scheme: 'tel',
                                          path: widget.guide.numero,
                                        );
                                        if (await canLaunchUrl(launchUri)) {
                                          await launchUrl(launchUri);
                                        } else {
                                          print('Impossible de lancer l\'appel téléphonique');
                                        }
                                      },
                                      child: Text("Appeler"),
                                    ),
                                  ),

                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        String message = "J'ai vu votre profile sur Camwonders et je veux un guide, êtes vous disponible ?";
                                        String url = "https://wa.me/${widget.guide.numero}?text=${Uri.encodeComponent(message)}";
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Text("Whatsapp"),
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
      ),
    );
  }
}
