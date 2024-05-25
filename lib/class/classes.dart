import 'package:camwonders/donneesexemples.dart';
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

  List<Wonder> getWonders(){
    return wonders.where((wonder) => wonder.categorie == this).toList();
  }

  List<Wonder> getWondersByFilters(bool gratuit, String region){
    if(gratuit &&region == ""){
      return wonders.where((wonder) => wonder.free == true).toList();
    }else if(region != "" && gratuit==false){
      return wonders.where((wonder) => wonder.region == region).toList();
    }else if(region != "" && gratuit){
      return wonders.where((wonder) => wonder.free == true).toList() + wonders.where((wonder) => wonder.region == region).toList();
    }else{
      return wonders.where((wonder) => wonder.categorie == this).toList();
    }
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
  final String region;

  @HiveField(6)
  final bool free;

  @HiveField(7)
  final int price;

  @HiveField(8)
  final String horaire;

  @HiveField(9)
  final double altitude;

  @HiveField(10)
  final double latitude;

  @HiveField(11)
  int note;

  @HiveField(12)
  final Categorie categorie;

  Wonder(
      this.idWonder,
      this.wonderName,
      this.description,
      this.imagePath,
      this.city,
      this.region,
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

  //getAvis()

  //getPosition()

  //getImages()

  //getSimilary()

  //Reserver()

  //setMeteoTime()

  //List<AvantagesInconvenient> getAvantages()
}


class AvantagesInconvenient{
  final int id;
  final bool avantage;
  final String content;

  AvantagesInconvenient(this.id, this.avantage, this.content);
}

class AvantagesInconvenient_wonder{
  final AvantagesInconvenient ai;
  final Wonder wonder;

  AvantagesInconvenient_wonder({required this.ai, required this.wonder});

  String getAvantagesInconvenientContent(){
    return ai.content;
  }

  bool get_if_is_avantages_or_inconvenient(){
    if(ai.avantage){
      return true;
    }else{
      return false;
    }
  }
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

  String getTitle(){
    return this.wond.wonderName;
  }

  String getDescription(){
    return this.desc;
  }

  int getLikes(){
    return like;
  }

  //List<Comment> getCommenttaires(){
    //return;
  //}
}

class User{
  // ignore: non_constant_identifier_names
  final int IdUser;
  final String identifiant;
  final String password;
  final bool premium;
  Box<Wonder> favorisBox;

  User(this.IdUser, this.identifiant, this.password, this.premium, this.favorisBox);

  //getWonderFavoris()

  //getNotifications()

  //UpdateProfilPicture()

  //changePassword()

  //changeUsername()

  //setSignalErreur()

  //setRappelVisite()

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