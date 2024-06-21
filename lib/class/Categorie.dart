import 'package:camwonders/class/Wonder.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';

part "Categorie.g.dart";


// Fonction de mappage pour obtenir IconData à partir du nom de l'icône
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
    // Ajoutez d'autres cas selon vos besoins landmark
    default:
      return LucideIcons.leaf;
  }
}

// Classe Categorie
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

  // Méthode pour obtenir l'icône
  Icon get iconcat => Icon(getIconData(iconName), size: 50, color: Color(0xff226900));

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getWonders(){
    return _firestore.collection('wonders').where('categorie', isEqualTo: categoryName).snapshots();
  }

  Stream<QuerySnapshot> getWondersBySearch(String keyword){
    return _firestore.collection('wonders').where('categorie', isEqualTo: categoryName).where('wonderName', isEqualTo: keyword).snapshots();
  }

  Stream<QuerySnapshot> getWondersByFilters(bool gratuit, String region){
    if(gratuit &&region == ""){
      return _firestore.collection('wonders').where('free', isEqualTo: true).snapshots();
    }else if(region != "" && gratuit==false){
      return _firestore.collection('wonders').where('free', isEqualTo: false).where('region', isEqualTo: region).snapshots();
    }else if(region != "" && gratuit){
      return _firestore.collection('wonders').where('free', isEqualTo: true).where('region', isEqualTo: region).snapshots();
    }else{
      return _firestore.collection('wonders').snapshots();
    }
  }
}