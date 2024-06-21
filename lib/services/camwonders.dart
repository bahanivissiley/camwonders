import 'dart:developer';
import 'package:camwonders/class/Offre.dart';
import 'package:camwonders/class/Utilisateur.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/class/WonderShort.dart';
import 'package:camwonders/class/classes.dart';
import 'package:camwonders/firebase/firebase_logique.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Camwonder {

  Stream<List<WonderShort>> getWonderShortStream() {
    return FirebaseFirestore.instance
        .collection('wondershorts')
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
        .map((doc) => WonderShort(
      idWonderShort: doc.id,
      like: doc['like'],
      desc: doc['desc'],
      videoPath: doc['videoPath'],
      dateUpload: doc['dateUpload'],
      vues: doc['vues'],
      wond: doc['wond'],
    ))
        .toList());
  }



  Future<void> createUser(
      String? nom, String? identifiant, String id, String? profilPath) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (await checkIfUserExists(id)) {
      await prefs.setString('id', id);
      await prefs.setString('nom', nom!);
      await prefs.setString('identifiant', identifiant!);
      await prefs.setBool('premium', false);
      await prefs.setString('profilPath', profilPath!);
      return;
    } else {
      if (profilPath != null) {
        await prefs.setString('id', id);
        await prefs.setString('nom', nom!);
        await prefs.setString('identifiant', identifiant!);
        await prefs.setBool('premium', false);
        await prefs.setString('profilPath', profilPath);
        return users
            .add({
              'id': id,
              'name': nom,
              'identifiant': identifiant,
              'premium': false,
              'profilPath': profilPath,
            })
            .then((value) => print("User added successfully!"))
            .catchError((error) => print("Failed to add user: $error"));
      } else {
        await prefs.setString('id', id);
        await prefs.setString('nom', nom!);
        await prefs.setString('identifiant', identifiant!);
        await prefs.setBool('premium', false);
        await prefs.setString(
            'profilPath', "https://firebasestorage.googleapis.com/v0/b/camwonders.appspot.com/o/profilInconnu.png?alt=media&token=0221763b-3d58-4340-a027-4105b3d9f66a");
        return users
            .add({
              'id': id,
              'name': nom,
              'identifiant': identifiant,
              'premium': false,
              'profilPath': "https://firebasestorage.googleapis.com/v0/b/camwonders.appspot.com/o/profilInconnu.png?alt=media&token=0221763b-3d58-4340-a027-4105b3d9f66a",
            })
            .then((value) => print("User added successfully!"))
            .catchError((error) => print("Failed to add user: $error"));
      }
    }
  }

  Future<bool> checkIfUserExists(String userId) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Utilisateur? user = await getUserByAuthId(AuthService().currentUser!.uid);
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      QuerySnapshot<Object?> document =
          await users.where('id', isEqualTo: userId).get();
      if (document.docs.isNotEmpty) {
        await prefs.setString('id', AuthService().currentUser!.uid);
        await prefs.setString('nom', user!.nom);
        await prefs.setString('identifiant', user.identifiant);
        await prefs.setBool('premium', user.premium);
        await prefs.setString('profilPath', user.profilPath);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      // Optionnel : Vous pouvez enregistrer ou signaler l'erreur ici si nécessaire
      return false;
    }
  }

  Future<Utilisateur> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nom = prefs.getString('nom');
    String? identifiant = prefs.getString('identifiant');
    bool? premium = prefs.getBool('premium');
    String? profilPath = prefs.getString('profilPath');

    if (nom == null || identifiant == null) {
      return Utilisateur(
          idUser: "df5",
          identifiant: "Pas connecté",
          nom: "Utilisateur inconnu",
          premium: false,
          profilPath: "https://firebasestorage.googleapis.com/v0/b/camwonders.appspot.com/o/profilInconnu.png?alt=media&token=0221763b-3d58-4340-a027-4105b3d9f66a");
    }

    if (profilPath == null) {
      return Utilisateur(
          idUser: AuthService().currentUser!.uid,
          identifiant: identifiant,
          nom: nom,
          premium: premium!,
          profilPath: "assets/profil.png");
    }

    return Utilisateur(
        idUser: AuthService().currentUser!.uid,
        identifiant: identifiant,
        nom: nom,
        premium: premium!,
        profilPath: profilPath);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Offre>> getOffres() {
    return _firestore.collection('offres').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Offre.fromDocument(doc);
      }).toList();
    });
  }

  Stream<List<WonderShort>> getWonderShorts() {
    return _firestore.collection('wondershorts').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return WonderShort.fromDocument(doc);
      }).toList();
    });
  }

  Future<QuerySnapshot> getReservations() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('user', isEqualTo: AuthService().currentUser!.uid)
          .get();

      return querySnapshot;
    } catch (e) {
      print('Error fetching documents: $e');
      rethrow;  // Optionnel : vous pouvez relancer l'exception ou gérer l'erreur d'une autre manière
    }
  }


  void deleteReservation(String documentId) async {
    await FirebaseFirestore.instance
        .collection('reservations')
        .doc(documentId)
        .delete();
  }


  Future<Wonder?>  getWonderById(String wonderId) async {
    try {
      DocumentSnapshot WonderDoc = await FirebaseFirestore.instance
          .collection('wonders')
          .doc(wonderId)
          .get();
      if (WonderDoc.exists) {
        return Wonder.fromDocument(WonderDoc);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Utilisateur?> getUserByAuthId(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('id', isEqualTo: userId)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming there is only one document with the userId
        DocumentSnapshot<Map<String, dynamic>> userDoc =
            querySnapshot.docs.first;
        return Utilisateur.fromDocument(userDoc);
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur : $e');
      return null;
    }
  }



  Future<Utilisateur?> getUserByUniqueId(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('users').doc(userId)
          .get();

      if (querySnapshot.exists) {
        return Utilisateur.fromDocument(querySnapshot);
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur : $e');
      return null;
    }
  }
}
