import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
  Stream<List<Map<String, dynamic>>> _wondersStream =
  Supabase.instance.client.from('wonder').stream(primaryKey: ['id']);
  Stream<List<Map<String, dynamic>>> _wondersStreamVue =
  Supabase.instance.client.from('wonder').stream(primaryKey: ['id']);
  String _searchQuery = '';

  Stream<List<Map<String, dynamic>>> get wondersStream => _wondersStream;
  Stream<List<Map<String, dynamic>>> get wondersStreamVue => _wondersStreamVue;
  String get searchQuery => _searchQuery;

  void loadCategorieVue(int id_categorie) {
    if(id_categorie == 0){
      _wondersStreamVue = Supabase.instance.client
          .from('wonder')
          .stream(primaryKey: ['id']);
    }else{
      _wondersStreamVue = Supabase.instance.client
          .from('wonder')
          .stream(primaryKey: ['id'])
          .eq('categorie', id_categorie);
    }

    notifyListeners();
  }

  void loadCategorie(int id_categorie) {
    if(id_categorie != 0){
      _wondersStream = Supabase.instance.client
          .from('wonder')
          .stream(primaryKey: ['id'])
          .eq('categorie', id_categorie);
    }else{
      _wondersStream = Supabase.instance.client
          .from('wonder')
          .stream(primaryKey: ['id']);
    }

    notifyListeners();
  }

  void applyFilters(
      String? selectedForfait,
      String? region,
      Position? currentPosition,
      double? maxDistance,
      int categorie
      ) {
    var query = Supabase.instance.client.from('wonder').select();

    print(selectedForfait);
    print(region);
    print(categorie);


    // Appliquer les filtres
    if (categorie != 0) {
      print(categorie);
      query = query.eq('categorie', categorie);
    }

    if (selectedForfait == 'Payants') {
      print('On entre dans les payants');
      query = query.eq('free', false);
    } else if (selectedForfait == 'Non payants') {
      query = query.eq('free', true);
    }

    if (region != null && region.isNotEmpty && region != 'Toutes les régions') {
      query = query.eq('region', region);
    }


    // Appliquer la recherche si un terme de recherche est présent
    if (_searchQuery.isNotEmpty) {
      query = query.ilike('wonder_name', '%$searchQuery%');
    }

    // Filtrer par distance si la position actuelle est disponible
    if (currentPosition != null && maxDistance != null) {
      print('Je suis dans le filtre de rayon');
      print(currentPosition);
      print(maxDistance);
      query = query.lt('latitude', currentPosition.latitude + maxDistance / 111.32)
          .gt('latitude', currentPosition.latitude - maxDistance / 111.32)
          .lt('longitude', currentPosition.longitude + maxDistance / (111.32 * cos(currentPosition.latitude * (3.141592653589793 / 180))))
          .gt('longitude', currentPosition.longitude - maxDistance / (111.32 * cos(currentPosition.latitude * (3.141592653589793 / 180))));
    }

    // Mettre à jour le Stream avec la nouvelle requête
    _wondersStream = query.asStream();
    notifyListeners();
  }

  void setSearchQuery(String query, int categorie) {
    _searchQuery = query;
    applyFilters(null, null, null, null, categorie); // Vous pouvez passer des valeurs si nécessaire
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
    try{
      await Supabase.instance.client
          .from('user')
          .update({'is_premium': value})
          .eq('uid', Supabase.instance.client.auth.currentUser!.id);

      _isPremium = value;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('premium', value);
      notifyListeners(); // Met à jour les widgets qui écoutent ce provider
    } catch (e){
      throw 'Erreur';
    }

  }

  // Déconnexion : Réinitialiser les données utilisateur
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprime toutes les données stockées
    _isPremium = false;  // Réinitialise l'état premium
    notifyListeners();   // Met à jour l'UI
  }

}


class OfferProvider with ChangeNotifier {
  Stream<List<Map<String, dynamic>>>? _offresStream;
  int _currentPage = 0;
  int _nombreOffres = 0;

  Stream<List<Map<String, dynamic>>>? get offresStream => _offresStream;
  int get currentPage => _currentPage;
  int get nombreOffres => _nombreOffres;

  OfferProvider() {
    loadData();
    _getNumberOfOffers();
  }

  Future<void> loadData() async {
    _offresStream = Supabase.instance.client.from('offre').stream(primaryKey: ['id']);
    notifyListeners();
  }

  Future<void> _getNumberOfOffers() async {
    try {
      final response = await Supabase.instance.client
          .from('offre')
          .select('id');
      _nombreOffres = response.length ?? 0;
      notifyListeners();
    } catch (e) {
      _nombreOffres = 0;
      notifyListeners();
    }
  }

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void incrementPage() {
    if (_currentPage < _nombreOffres - 1) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
    notifyListeners();
  }
}




class DataProvider with ChangeNotifier {
  Stream<List<Map<String, dynamic>>>? _offresStream;
  int _currentPage = 0;
  int _nombreOffres = 0;

  Stream<List<Map<String, dynamic>>>? get offresStream => _offresStream;
  int get currentPage => _currentPage;
  int get nombreOffres => _nombreOffres;

  OfferProvider() {
    loadData();
    _getNumberOfOffers();
  }

  Future<void> loadData() async {
    _offresStream = Supabase.instance.client.from('offre').stream(primaryKey: ['id']);
    notifyListeners();
  }

  Future<void> _getNumberOfOffers() async {
    try {
      final response = await Supabase.instance.client
          .from('offre')
          .select('id');
      _nombreOffres = response.length ?? 0;
      notifyListeners();
    } catch (e) {
      _nombreOffres = 0;
      notifyListeners();
    }
  }

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void incrementPage() {
    if (_currentPage < _nombreOffres - 1) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
    notifyListeners();
  }
}