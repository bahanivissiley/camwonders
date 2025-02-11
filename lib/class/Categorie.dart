import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';

part "Categorie.g.dart";


IconData getIconData(String iconName) {
  switch (iconName) {
    case 'leaf':
      return LucideIcons.leaf;
    case 'utensils':
      return LucideIcons.utensils;
    case 'bed':
      return LucideIcons.bed;
    case 'landmark':
      return LucideIcons.landmark;
    default:
      return LucideIcons.leaf;
  }
}

@HiveType(typeId: 0)
class Categorie {
  @HiveField(0)
  final int idCategory;

  @HiveField(1)
  final String categoryName;

  @HiveField(2)
  final String iconName;

  @HiveField(3)
  final bool statut;

  Categorie(this.idCategory, this.categoryName, this.iconName, this.statut);

  Icon get iconcat => Icon(getIconData(iconName), size: 50, color: const Color(0xff226900));

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getWonders(){
    return _firestore.collection('wonders').where('categorie', isEqualTo: categoryName).snapshots();
  }

  Stream<QuerySnapshot> getWondersBySearch(String keyword){
    return _firestore.collection('wonders').where('categorie', isEqualTo: categoryName).where('wonderName', isEqualTo: keyword).snapshots();
  }

  Stream<QuerySnapshot> getWondersByFilters(bool gratuit, String region, String ville) {
    // Créer une référence de base à la collection 'wonders'
    final CollectionReference wondersRef = _firestore.collection('wonders');

    // Initialiser une requête avec la référence de base
    Query query = wondersRef;

    // Appliquer les filtres en fonction des paramètres
    if (gratuit) {
      query = query.where('free', isEqualTo: true);
    } else {
      query = query.where('free', isEqualTo: false);
    }

    if (region.isNotEmpty) {
      query = query.where('region', isEqualTo: region);
    }

    if (ville.isNotEmpty) {
      query = query.where('ville', isEqualTo: ville);
    }

    // Retourner le flux de résultats
    return query.snapshots();
  }
}