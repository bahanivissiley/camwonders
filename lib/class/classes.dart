class AvantagesInconvenient{
  final int id;
  final bool avantage;
  final String content;

  AvantagesInconvenient({required this.id, required this.avantage, required this.content});

  factory AvantagesInconvenient.fromDocument(Map<String, dynamic> doc) {
    return AvantagesInconvenient(
      id: doc['id'],
      avantage: doc['is_avantage'],
      content: doc['content'],
    );
  }
}

class AvantagesInconvenientWonder{
  final String ai;
  final String wonder;

  AvantagesInconvenientWonder({required this.ai, required this.wonder});

  factory AvantagesInconvenientWonder.fromDocument(Map<String, dynamic> doc) {
    return AvantagesInconvenientWonder(
      ai: doc['an_in'],
      wonder: doc['wonder']?['id'],
    );
  }

}

class Img{
  final int idImage;
  final String image_url;
  final int wonder_id;
  final String source;

  Img({required this.idImage,required this.image_url,required this.wonder_id, required this.source});

  factory Img.fromDocument(Map<String, dynamic> doc) {
    return Img(
      idImage: doc['id'],
      image_url: doc['image_url'],
      wonder_id: doc['wonder'],
      source: doc['source'],
    );
  }
}


class Avis{
  final int idAvis;
  final double note;
  final String content;
  final int wonder;
  final String userId;
  final String userImage;
  final String userName;

  Avis({required this.userId, required this.idAvis,required this.note,required this.content,required this.wonder, required this.userImage, required this.userName});

  factory Avis.fromDocument(Map<String, dynamic> doc) {
    return Avis(
      idAvis: doc['id'],
      note: doc['note'],
      content: doc['content'],
      wonder: doc['wonder'],
      userImage: doc['profil_path_user'],
      userName: doc['user_name'],
      userId: doc['user'],
    );
  }
}


class Guide{
  // ignore: non_constant_identifier_names
  final int id;
  final String numero;
  final String nom;
  final int wonder;
  final String profilPath;

  Guide({required this.id, required this.numero, required this.nom, required this.wonder, required this.profilPath});

  factory Guide.fromDocument(Map<String, dynamic> doc) {
    return Guide(
      id: doc['id'],
      numero: doc['numero'] as String,
      nom: doc['nom'] as String,
      wonder: doc['wonder'],
      profilPath: doc['profil_path'] as String,
    );
  }
}


class Comment{
  final int idComment;
  final String content;
  final int wondershort;
  final String idUser;
  final String userImage;
  final String userName;

  Comment({required this.idComment, required this.idUser, required this.content, required this.wondershort, required this.userImage, required this.userName});

  factory Comment.fromDocument(Map<String, dynamic> doc) {
    return Comment(
      idComment: doc['id'],
      idUser: doc['user']?['uid'],
      content: doc['content'],
      wondershort: doc['wonder_short'],
      userImage: doc['profil_path_user'],
      userName: doc['user_name'],
    );
  }
}


class Evenements{
  final int idevenements;
  final String contenu;
  final String title;
  final String numeroTel;
  final String imagePath;
  final int idWonder;
  final String date;

  Evenements({required this.idevenements, required this.contenu, required this.title, required this.numeroTel, required this.imagePath, required this.idWonder, required this.date});

  factory Evenements.fromDocument(Map<String, dynamic> doc) {
    return Evenements(
      idevenements: doc['id'],
      contenu: doc['contenu'],
      title: doc['title'],
      numeroTel: doc['numero_tel'],
      imagePath: doc['image_path'],
      idWonder: doc['wonder'],
      date: doc['date'],
    );
  }
}

class Reservations{
  final int idReservation;
  final String user;
  final int nbrePersonnes;
  final String numeroTel;
  final int idWonder;
  final String date;
  final bool isvalidate;
  final bool isload;
  final String motif;

  Reservations({required this.idReservation, required this.user, required this.nbrePersonnes, required this.numeroTel, required this.idWonder, required this.date, required this.isvalidate, required this.isload, required this.motif});

  factory Reservations.fromDocument(Map<String, dynamic> doc) {
    return Reservations(
      idReservation: doc['id'],
      user: doc['user']?['uid'],
      nbrePersonnes: int.parse(doc['nbre_personnes']),
      numeroTel: doc['numero_tel'],
      idWonder: doc['wonder']?['id'],
      date: doc['date'],
      isvalidate: doc['is_validate'],
      isload: doc['is_load'],
      motif: doc['motif']
    );
  }
}


class SignaleErreur{
  final int idSignalement;
  final String title;
  final String content;
  final int wonder;
  final int user;

  SignaleErreur(this.idSignalement, this.title, this.content, this.wonder, this.user);
}