

import 'package:camwonders/class/Utilisateur.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/class/classes.dart';
import 'package:camwonders/firebase/firebase_logique.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WonderShort{
  final String idWonderShort;
  int like;
  final String desc;
  final String videoPath;
  final String dateUpload;
  final int vues;
  final String wond;

  WonderShort({required this.idWonderShort,required this.like, required this.desc, required this.videoPath, required this.dateUpload, required this.vues, required this.wond});

  factory WonderShort.fromDocument(DocumentSnapshot doc) {
    return WonderShort(
      idWonderShort: doc.id,
      like: doc['likes'],
      desc: doc['desc'],
      videoPath: doc['videoPath'],
      dateUpload: doc['dateUpload'],
      vues: doc['vues'],
      wond: doc['wond'],
    );
  }

  String getTitle(){
    return wond;
  }

  String getDescription(){
    return desc;
  }

  Future<int?> getLikes() async{
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('wondershorts')
        .doc(idWonderShort)
        .get();

    if (documentSnapshot.exists) {
      return (documentSnapshot.get('like') as num).toInt();
    }
    return null;
  }

  Future<void> setLike() async {
    int? likeactu = await getLikes();
    int likeUpdate = likeactu! + 1;
    await FirebaseFirestore.instance
        .collection('wondershorts')
        .doc(idWonderShort)
        .update({'like': likeUpdate});
  }

  Future<void> disLike() async {
    int? likeactu = await getLikes();
    int likeUpdate = likeactu! - 1;
    await FirebaseFirestore.instance
        .collection('wondershorts')
        .doc(idWonderShort)
        .update({'like': likeUpdate});
  }


  Future<int?> getVues() async{
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('wondershorts')
        .doc(idWonderShort)
        .get();

    if (documentSnapshot.exists) {
      return (documentSnapshot.get('vues') as num).toInt();
    }
    return null;
  }

  Future<void> setVues() async {
    int? likeactu = await getLikes();
    int likeUpdate = likeactu! + 1;
    await FirebaseFirestore.instance
        .collection('wondershorts')
        .doc(idWonderShort)
        .update({'vues': likeUpdate});
  }


  Future<void> addCommentaire(String content) async {
    Comment comment = Comment(idComment: "genere", content: content, wondershort: idWonderShort, user: AuthService().currentUser!.uid);
    CollectionReference commentaire = FirebaseFirestore.instance.collection('commentaires');


    return commentaire
        .add({
      'content': comment.content,
      'wondershort': comment.wondershort,
      'user': comment.user,
    })
        .then((value) => print("Commentaire ajouté"))
        .catchError((error) => print("Commentaire pas ajouté: $error"));
  }

  Stream<QuerySnapshot> getCommentaires() {
    return FirebaseFirestore.instance
        .collection('commentaires')
        .where('wondershort', isEqualTo: idWonderShort)
        .snapshots();
  }
}