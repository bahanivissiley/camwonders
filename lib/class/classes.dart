import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lucide_icons/lucide_icons.dart';

part 'classes.g.dart';

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
  final String iconName; // Stockez l'icône en tant que nom de chaîne

  Categorie(this.idCategory, this.categoryName, this.iconName);

  // Méthode pour obtenir l'icône
  Icon get iconcat => Icon(getIconData(iconName), size: 50, color: Color(0xff226900));
}

// Adaptateur pour la classe Categorie
class CategorieAdapter extends TypeAdapter<Categorie> {
  @override
  final int typeId = 0;

  @override
  Categorie read(BinaryReader reader) {
    return Categorie(
      reader.readInt(),
      reader.readString(),
      reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Categorie obj) {
    writer.writeInt(obj.idCategory);
    writer.writeString(obj.categoryName);
    writer.writeString(obj.iconName);
  }
}

// Classe Wonder
@HiveType(typeId: 1)
class Wonder {
  @HiveField(0)
  final int idWonder;

  @HiveField(1)
  final String wonderName;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String imagePath;

  @HiveField(4)
  final String city;

  @HiveField(5)
  final bool free;

  @HiveField(6)
  final int price;

  @HiveField(7)
  final String horaire;

  @HiveField(8)
  final double altitude;

  @HiveField(9)
  final double latitude;

  @HiveField(10)
  int note;

  @HiveField(11)
  final Categorie categorie;

  Wonder(
      this.idWonder,
      this.wonderName,
      this.description,
      this.imagePath,
      this.city,
      this.free,
      this.price,
      this.horaire,
      this.altitude,
      this.latitude,
      this.note,
      this.categorie);

  void setNote(int note) {
    this.note = note;
  }
}

void registerHiveAdapters() {
  // Enregistrement de l'adaptateur pour la classe Categorie
  Hive.registerAdapter(CategorieAdapter());
}


class AvantagesInconvenient{
  final int id;
  final bool avantage;
  final String content;
  final Wonder wonder;

  AvantagesInconvenient(this.id, this.avantage, this.content, this.wonder);
}

class Img{
  final int idImage;
  final String path;
  final Wonder wonder;

  Img(this.idImage, this.path, this.wonder);
}

class WonderShort{
  final int idWonderShort;
  int like;
  final String desc;
  final String videoPath;
  final String dateUpload;
  final int vues;
  final Wonder wond;

  WonderShort(this.idWonderShort, this.like, this.desc,  this.videoPath, this.dateUpload, this.vues, this.wond);
}

class User{
  // ignore: non_constant_identifier_names
  final int IdUser;
  final String identifiant;
  final String password;
  final bool premium;
  Box<Wonder> favorisBox;

  User(this.IdUser, this.identifiant, this.password, this.premium, this.favorisBox);
}

class Avis{
  final int idAvis;
  final int note;
  final String content;
  final Wonder wonder;
  final User user;

  Avis(this.idAvis, this.note, this.content, this.wonder, this.user);
}

class comment{
  final int idComment;
  final String content;
  final WonderShort wondershort;
  final User user;

  comment(this.idComment, this.content, this.wondershort, this.user);
}

class SignaleErreur{
  final int idSignalement;
  final String title;
  final String content;
  final Wonder wonder;
  final User user;

  SignaleErreur(this.idSignalement, this.title, this.content, this.wonder, this.user);
}


class RappelVisite{
  final int idRappel;
  final String title;
  final String content;

  RappelVisite(this.idRappel, this.title, this.content);
}

class WonderMeteoTime{
  final String date;
  final double temperature;
  final bool sun;
  final bool cloud;
  final bool rain;

  WonderMeteoTime(this.date, this.temperature, this.sun, this.cloud, this.rain);
}

class NotificationItem {
  final String message;

  NotificationItem(this.message);
}