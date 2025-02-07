import 'package:camwonders/pages/bottomNavigator/menu/vues.dart';
import 'package:camwonders/widgetGlobal.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  // Variable pour stocker l'option sélectionnée
  String selectedOption = "12 Months";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ListeVue.verte, Colors.greenAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Icon(Icons.lock, size: 40, color: Colors.white),
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
                SizedBox(height: 16),
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
                  selected: selectedOption == "1 Mois",
                  onTap: () {
                    setState(() {
                      selectedOption = "1 Mois";
                    });
                  },
                ),
                buildSubscriptionOption(
                  title: "12 Mois",
                  price: " 12 000 FCFA / Month",
                  discount: "Economisez 50%",
                  originalPrice: "24 000 FCFA",
                  selected: selectedOption == "12 Months",
                  onTap: () {
                    setState(() {
                      selectedOption = "12 Months";
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
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<UserProvider>(context, listen: false).setPremium(true);
                    print("Option sélectionnée : $selectedOption");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    "Essayez gratuitement",
                    style: GoogleFonts.jura(
                      color: ListeVue.verte,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Spacing from bottom
          ],
        ),
      ),
    );
  }

  Widget buildFeatureText(String text) {
    return Row(
      children: [
        Icon(Icons.check, color: Colors.white, size: 20),
        SizedBox(width: 8),
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
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          color: selected ? Colors.white.withOpacity(0.2) : Colors.transparent,
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
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                    if (discount != null) SizedBox(width: 8),
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
