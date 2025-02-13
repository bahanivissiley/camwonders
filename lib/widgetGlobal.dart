import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void loadCategorie(String categorieName) {
    _wondersStream = FirebaseFirestore.instance
        .collection('wonders')
        .where('categorie', isEqualTo: categorieName)
        .snapshots();
  }

  void applyFilters(String? selectedForfait, String? region, String? ville, String? categorie) {
    Query query = FirebaseFirestore.instance.collection('wonders');

    // Appliquer les filtres
    if (categorie != null) {
      query = query.where('categorie', isEqualTo: categorie);
    }

    if (selectedForfait == 'Payants') {
      query = query.where('free', isEqualTo: false);
    } else if (selectedForfait == 'Non payants') {
      query = query.where('free', isEqualTo: true);
    }

    if (region != null && region.isNotEmpty && region != 'Toutes les régions') {
      query = query.where('region', isEqualTo: region);
    }

    if (ville != null && ville.isNotEmpty && ville != 'Toutes les villes') {
      query = query.where('city', isEqualTo: ville);
    }

    print("Etape 3");

    // Appliquer la recherche si un terme de recherche est présent
    if (_searchQuery.isNotEmpty) {
      print("Etape 4");
      query = query.where('wonderNameLower', isGreaterThanOrEqualTo: _searchQuery)
          .where('wonderNameLower', isLessThan: '${_searchQuery}z');

      print(query.count().toString());
    }

    // Mettre à jour le Stream avec la nouvelle requête
    _wondersStream = query.snapshots();
    print("Etape 5");
    print(_wondersStream.first.toString());

    notifyListeners();
  }

  void setSearchQuery(String query) {
    print("Etape 2");
    print(query);
    _searchQuery = query;
    applyFilters(null, null, null, null); // Vous pouvez passer des valeurs si nécessaire
  }
}


class UserProvider with ChangeNotifier {
  bool _isPremium = false;  // État par défaut
  String _idUser = "";
  String _name = "";
  String _profilPath = "";

  bool get isPremium => _isPremium;
  String get idUser => _idUser;
  String get nom => _name;
  String get profilPath => _profilPath;

  UserProvider() {
    _loadUserPreferences();  // Charger l'état premium au démarrage
  }

  // Charger l'état premium depuis SharedPreferences
  Future<void> _loadUserPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('premium') ?? false;
    _idUser = prefs.getString('id') ?? "";
    _name = prefs.getString('nom') ?? "";
    _profilPath = prefs.getString('profilPath') ?? "";
    notifyListeners(); // Notifier les widgets écoutant ce provider
  }

  // Mettre à jour l'état premium et sauvegarder
  Future<void> setPremium(bool value) async {
    _isPremium = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('premium', value);
    notifyListeners(); // Met à jour les widgets qui écoutent ce provider
  }

  // Déconnexion : Réinitialiser les données utilisateur
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprime toutes les données stockées
    _isPremium = false;  // Réinitialise l'état premium
    notifyListeners();   // Met à jour l'UI
  }

}
