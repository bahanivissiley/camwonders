
import 'package:cloud_firestore/cloud_firestore.dart';

class Utilisateur{
  final String idUser;
  final String identifiant;
  final String nom;
  final bool premium;
  final String profilPath;

  Utilisateur({required this.idUser, required this.identifiant, required this.nom, required this.premium, required this.profilPath});

  factory Utilisateur.fromDocument(DocumentSnapshot doc) {
    return Utilisateur(
      idUser: doc.id,
      identifiant: doc['identifiant'] as String,
      nom: doc['name']as String,
      premium: doc['premium'] as bool,
      profilPath: doc['profilPath'] as String,
    );
  }

}