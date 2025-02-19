class Utilisateur{
  final int idUser;
  final String uid;
  final String identifiant;
  final String nom;
  final bool premium;
  final String profilPath;

  Utilisateur({required this.idUser, required this.uid, required this.identifiant, required this.nom, required this.premium, required this.profilPath});

  factory Utilisateur.fromDocument(Map<String, dynamic> doc) {
    return Utilisateur(
      idUser: doc['id'],
      uid: doc['uid'],
      identifiant: doc['identifiant'] as String,
      nom: doc['name']as String,
      premium: doc['is_premium'] as bool,
      profilPath: doc['profil_path'] as String,
    );
  }

}