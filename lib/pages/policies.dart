import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Policies extends StatelessWidget {
  const Policies({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conditions d'utilisation"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenue sur l'application mobile CamWonders !",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "En utilisant cette application, vous acceptez les termes et conditions suivants :",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),

            _SectionTitle("1. Acceptation des conditions"),
            _SectionText(
              "En téléchargeant ou en utilisant cette application, vous acceptez d'être lié par ces conditions d'utilisation. "
                  "Si vous n'acceptez pas ces conditions, veuillez ne pas utiliser l'application.",
            ),

            _SectionTitle("2. Utilisation autorisée"),
            _BulletPoint("Vous ne pouvez utiliser cette application qu'à des fins personnelles et non commerciales."),
            _BulletPoint("Toute tentative de reproduction, modification, distribution ou vente des contenus de l'application sans autorisation est strictement interdite."),

            _SectionTitle("3. Propriété intellectuelle"),
            _BulletPoint("Tout le contenu de CamWonders (textes, images, logos, etc.) est protégé par des droits d'auteur à part ceux dont la source est mentionné"),
            _BulletPoint("Tout le contenu que vous proposez à CamWonders (images) vous nous assurez la liberté de droits d'auteurs"),
            _BulletPoint("Vous acceptez de ne pas enfreindre ces droits, y compris en partageant des contenus sans permission."),

            _SectionTitle("4. Protection des données personnelles"),
            _BulletPoint("CamWonders respecte votre vie privée. Nous collectons uniquement les données nécessaires pour améliorer votre expérience utilisateur."),
            _BulletPoint("Les informations collectées ne seront pas partagées avec des tiers sans votre consentement."),

            _SectionTitle("5. Responsabilités de l'utilisateur"),
            _BulletPoint("Vous êtes responsable de l'exactitude des informations que vous fournissez lors de l'utilisation de l'application."),
            _BulletPoint("Vous ne devez pas utiliser l'application pour transmettre des contenus illégaux, nuisibles ou offensants."),

            _SectionTitle("6. Limitations de responsabilité"),
            _BulletPoint("CamWonders n'est pas responsable des dommages directs ou indirects résultant de l'utilisation de l'application."),
            _BulletPoint("Nous ne garantissons pas que l'application fonctionnera sans interruption ou sans erreur."),

            _SectionTitle("7. Modifications des conditions"),
            _BulletPoint("CamWonders se réserve le droit de modifier ces conditions d'utilisation à tout moment. Les utilisateurs seront informés des mises à jour importantes."),
            _BulletPoint("Votre utilisation continue de l'application après une modification constitue votre acceptation des nouvelles conditions."),

            _SectionTitle("8. Résiliation"),
            _BulletPoint("Nous nous réservons le droit de suspendre ou de résilier votre accès à l'application en cas de violation de ces conditions."),

            _SectionTitle("9. Contact"),
            _SectionText("Pour toute question ou préoccupation concernant ces conditions, veuillez nous contacter à : support@camwonders.com."),

            SizedBox(height: 30),
            Center(
              child: Text(
                "Merci d'utiliser CamWonders et de nous aider à promouvoir les merveilles du Cameroun !",
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14),
      textAlign: TextAlign.justify,
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
