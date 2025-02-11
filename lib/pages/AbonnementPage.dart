import 'package:camwonders/firebase/firebase_logique.dart';
import 'package:camwonders/mainapp.dart';
import 'package:camwonders/pages/bottomNavigator/menu/vues.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:camwonders/widgetGlobal.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:cinetpay/cinetpay.dart';
import 'package:get/get.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int selectedOption = 0;


  void lancerPaiement(BuildContext context) async {
    Navigator.pop(context);
    final String transactionId = Random().nextInt(100000000).toString();

    await Get.to(
          () => CinetPayCheckout(
        title: 'Paiement',
        titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        titleBackgroundColor: Colors.green,
        configData: <String, dynamic>{
          'apikey': '202691081867a8f7cdb409a4.21795969',
          'site_id': "105887561",
          'notify_url': 'https://www.camwonders.com/notify',
        },
        paymentData: <String, dynamic>{
          'transaction_id': transactionId,
          'amount': selectedOption, // Montant fixe
          'currency': 'XAF',
          'channels': 'ALL',
          'description': 'Paiement test',
        },
        waitResponse: (data) async {
          if (data['status'] == 'ACCEPTED') {
            Get.back(); // Ferme la page de paiement
            await Camwonder.updatePremiumStatusByFieldId(AuthService().currentUser!.uid, true);
            Provider.of<UserProvider>(context, listen: false).setPremium(true);

            // Attendre un peu avant de rediriger
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainApp()),
                    (Route<dynamic> route) => false,
              );
            });

            _afficherModal(context, 'Paiement Réussi', Icons.check_circle, Colors.green);
          }
        },
        onError: (data) {
          if (Get.isOverlaysOpen) {
            Get.back();
          }
          _afficherModal(context, 'Échec du paiement', Icons.error, Colors.red);
        },
      ),
    );
  }


  void _afficherModal(BuildContext context, String message, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Icon(icon, color: color, size: 50),
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ListeVue.verte, Colors.greenAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const Icon(Icons.lock, size: 40, color: Colors.white),
            Column(
              children: [
                Text(
                  "Passez en mode premium",
                  style: GoogleFonts.lalezar(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildFeatureText("Accès à plus de +100 lieux"),
                    buildFeatureText("Accès aux itinéraires"),
                    buildFeatureText("Contacter un des guides certifiés"),
                    buildFeatureText("Pouvoir participer à des événements"),
                    buildFeatureText("Pouvoir reserver des places dans les places reservables"),
                    buildFeatureText("Acces à des offres et réduction"),
                    buildFeatureText("Supprimer toutes les publicités"),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                buildSubscriptionOption(
                  title: "1 Mois",
                  price: "2000 FCFA / Mois",
                  selected: selectedOption == 2000,
                  onTap: () {
                    setState(() {
                      selectedOption = 2000;
                    });
                  },
                ),
                buildSubscriptionOption(
                  title: "12 Mois",
                  price: " 12 000 FCFA / Month",
                  discount: "Economisez 50%",
                  originalPrice: "24 000 FCFA",
                  selected: selectedOption == 12000,
                  onTap: () {
                    setState(() {
                      selectedOption = 12000;
                    });
                  },
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  "Commencez votre essaie de 7jours gratuitement",
                  style: GoogleFonts.jura(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible:
                      false, // Empêche la fermeture du modal en cliquant à l'extérieur
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(), // Indicateur de chargement
                              SizedBox(height: 16), // Espacement
                              Text('Veuillez patienter...'),
                            ],
                          ),
                        );
                      },
                    );

                    lancerPaiement(context);

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    "Effectuez le paiement",
                    style: GoogleFonts.jura(
                      color: ListeVue.verte,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Spacing from bottom
          ],
        ),
      ),
    );
  }

  Widget buildFeatureText(String text) {
    return Row(
      children: [
        const Icon(Icons.check, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.jura(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSubscriptionOption({
    required String title,
    required String price,
    required bool selected,
    String? discount,
    String? originalPrice,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          color: selected ? Colors.white.withValues(alpha:0.2) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (discount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          discount,
                          style: GoogleFonts.jura(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (discount != null) const SizedBox(width: 8),
                    Text(
                      title,
                      style: GoogleFonts.jura(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (originalPrice != null)
                  Text(
                    originalPrice,
                    style: GoogleFonts.jura(
                      color: Colors.white70,
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  price,
                  style: GoogleFonts.jura(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
