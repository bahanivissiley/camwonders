import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FilterButton extends StatelessWidget {
  final VoidCallback onTap;
  final String buttonText;
  final IconData icon;

  const FilterButton({
    Key? key,
    required this.onTap,
    this.buttonText = "Filtrer",
    this.icon = LucideIcons.slidersHorizontal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width * 0.2, // 20% de la largeur de l'écran
        padding: EdgeInsets.all(size.width * 0.02),
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xff226900),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              icon,
              size: 17,
              color: Colors.white,
            ),
            Text(
              buttonText,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class WondersProvider with ChangeNotifier {
  Stream<QuerySnapshot> _wondersStream = FirebaseFirestore.instance.collection('wonders').snapshots();
  String _searchQuery = '';

  Stream<QuerySnapshot> get wondersStream => _wondersStream;
  String get searchQuery => _searchQuery;

  void applyFilters(String? selectedForfait, String? region, String? ville, String? categorie) {
    // Commencer avec une référence de base à la collection 'wonders'
    Query query = FirebaseFirestore.instance.collection('wonders').where('categorie', isEqualTo: categorie);

    // Appliquer les filtres uniquement si les paramètres sont fournis
    if (selectedForfait == 'Payants') {
      query = query.where('free', isEqualTo: false);
    }

    if (selectedForfait == 'Non payants') {
      query = query.where('free', isEqualTo: true);
    }

    if (region != null && region.isNotEmpty && region != 'Toutes les régions') {
      query = query.where('region', isEqualTo: region);
    }

    if (ville != null && ville.isNotEmpty && ville != 'Toutes les villes') {
      query = query.where('city', isEqualTo: ville);
    }

    // Appliquer la recherche si un terme de recherche est présent
    if (_searchQuery.isNotEmpty) {
      query = query.where('wonderNameLower', isGreaterThanOrEqualTo: _searchQuery).where('wonderNameLower', isLessThan: _searchQuery + 'z');
    }

    // Mettre à jour le Stream avec la nouvelle requête
    _wondersStream = query.snapshots();

    // Notifier les écouteurs que les données ont changé
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    applyFilters(null, null, null, null); // Réappliquer les filtres avec la nouvelle requête de recherche
  }
}
