import 'package:hive/hive.dart';

part "Categorie.g.dart";


@HiveType(typeId: 0)
class Categorie {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String designation;

  @HiveField(2)
  final bool statut;

  Categorie({required this.id, required this.designation, required this.statut});

  factory Categorie.fromDocument(Map<String, dynamic> doc) {
    return Categorie(
      id: doc['id'],
      designation: doc['designation'] as String,
      statut: doc['statut'] as bool,
    );
  }
}