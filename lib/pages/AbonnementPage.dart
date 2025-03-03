import 'package:camwonders/firebase/supabase_logique.dart';
import 'package:camwonders/mainapp.dart';
import 'package:camwonders/pages/bottomNavigator/menu/vues.dart';
import 'package:camwonders/pages/paiementPage.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:camwonders/widgetGlobal.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int selectedOption = 0;
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> tarifs = [];

  @override
  void initState() {
    super.initState();
    fetchTarifs();
  }

  Future<void> fetchTarifs() async {
    print('Etape 1');
    final response = await supabase.from('tarifs').select();
    print('Etape 2');
    if (response.isNotEmpty) {
      print('Etape 3');
      setState(() {
        tarifs = response;
      });
    }
  }

  void lancerPaiement(BuildContext context) async {
    if(selectedOption == 0){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.green,),
                SizedBox(height: 15),
                Text('Traitement', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      );
      Future.delayed(const Duration(seconds: 3));
      await Camwonder.updatePremiumStatusByFieldId(AuthService().currentUser!.id, true);
      Provider.of<UserProvider>(context, listen: false).setPremium(true);
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MainApp()),
              (Route<dynamic> route) => false
      );

    }else{
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentPage(
                amount: selectedOption,
              )));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ListeVue.verte, Colors.black],
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
                    buildFeatureText(
                        "Pouvoir reserver des places dans les places reservables"),
                    buildFeatureText("Acces à des offres et réduction"),
                    buildFeatureText("Supprimer toutes les publicités"),
                  ],
                ),
              ],
            ),
            Column(
              children: tarifs.map((tarif) {
                return buildSubscriptionOption(
                  title: "${tarif['periode']}",
                  price: "${tarif['montant']} FCFA / ${tarif['periode']}",
                  discount: tarif['reduction'] != null ? "Économisez ${tarif['reduction']}%" : null,
                  originalPrice: tarif['reduction'] != null
                      ? "${(tarif['montant'] * 100 / (100 - tarif['reduction'])).toInt()} FCFA"
                      : null,
                  selected: selectedOption == tarif['montant'],
                  onTap: () {
                    setState(() {
                      selectedOption = tarif['montant'];
                    });
                  },
                );
              }).toList(),
            ),
            Column(
              children: [
                Text(
                  "Commencez votre essaie de 7jours gratuitement",
                  style: GoogleFonts.jura(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {

                    lancerPaiement(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
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
    String? title,
    String? price,
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
          color: selected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
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
                      title!,
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
                  price!,
                  style: GoogleFonts.jura(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
