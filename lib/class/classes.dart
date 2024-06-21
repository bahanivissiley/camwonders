import 'package:cloud_firestore/cloud_firestore.dart';

class AvantagesInconvenient{
  final String id;
  final bool avantage;
  final String content;

  AvantagesInconvenient({required this.id, required this.avantage, required this.content});

  factory AvantagesInconvenient.fromDocument(DocumentSnapshot doc) {
    return AvantagesInconvenient(
      id: doc['avantage_or_inconvenient_id'],
      avantage: doc['avantage'],
      content: doc['content'],
    );
  }
}

class AvantagesInconvenientWonder{
  final String ai;
  final String wonder;

  AvantagesInconvenientWonder({required this.ai, required this.wonder});

  factory AvantagesInconvenientWonder.fromDocument(DocumentSnapshot doc) {
    return AvantagesInconvenientWonder(
      ai: doc['avantage_or_inconvenient_id'],
      wonder: doc['wonder_id'],
    );
  }

}

class Img{
  final String idImage;
  final String image_url;
  final String wonder_id;

  Img({required this.idImage,required this.image_url,required this.wonder_id});

  factory Img.fromDocument(DocumentSnapshot doc) {
    return Img(
      idImage: doc.id,
      image_url: doc['image_url'],
      wonder_id: doc['wonder_id'],
    );
  }
}


class Avis{
  final String idAvis;
  final double note;
  final String content;
  final String wonder;
  final String user;
  String userImage;

  Avis({required this.idAvis,required this.note,required this.content,required this.wonder,required this.user, required this.userImage});

  factory Avis.fromDocument(DocumentSnapshot doc) {
    return Avis(
      idAvis: doc.id,
      note: doc['note'],
      content: doc['content'],
      wonder: doc['wonder'],
      user: doc['user'],
      userImage: doc['userImage'],
    );
  }
}

class Comment{
  final String idComment;
  final String content;
  final String wondershort;
  final String user;

  Comment({required this.idComment, required this.content, required this.wondershort, required this.user});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      idComment: doc.id,
      content: doc['content'],
      wondershort: doc['textlink'],
      user: doc['link'],
    );
  }
}


class Evenements{
  final String idevenements;
  final String contenu;
  final String title;
  final String numeroTel;
  final String imagePath;
  final String idWonder;
  final String date;

  Evenements({required this.idevenements, required this.contenu, required this.title, required this.numeroTel, required this.imagePath, required this.idWonder, required this.date});

  factory Evenements.fromDocument(DocumentSnapshot doc) {
    return Evenements(
      idevenements: doc.id,
      contenu: doc['contenu'],
      title: doc['title'],
      numeroTel: doc['numeroTel'],
      imagePath: doc['imagePath'],
      idWonder: doc['idWonder'],
      date: doc['date'],
    );
  }
}

class Reservations{
  final String idReservation;
  final String user;
  final int nbrePersonnes;
  final String numeroTel;
  final String idWonder;
  final String date;
  final bool isvalidate;
  final bool isload;
  final String motif;

  Reservations({required this.idReservation, required this.user, required this.nbrePersonnes, required this.numeroTel, required this.idWonder, required this.date, required this.isvalidate, required this.isload, required this.motif});

  factory Reservations.fromDocument(DocumentSnapshot doc) {
    return Reservations(
      idReservation: doc.id,
      user: doc['user'],
      nbrePersonnes: int.parse(doc['nbrePersonnes']),
      numeroTel: doc['numeroTel'],
      idWonder: doc['idWonder'],
      date: doc['date'],
      isvalidate: doc['isvalidate'],
      isload: doc['isload'],
      motif: doc['motif']
    );
  }
}


class SignaleErreur{
  final int idSignalement;
  final String title;
  final String content;
  final String wonder;
  final String user;

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