import 'package:cloud_firestore/cloud_firestore.dart';

class Offre{
  final String id;
  final String title;
  final String content;
  final String textlink;
  final String link;
  final String image;

  Offre({required this.id, required this.title, required this.content, required this.textlink, required this.link, required this.image});

  factory Offre.fromDocument(DocumentSnapshot doc) {
    return Offre(
      id: doc.id,
      title: doc['title'],
      content: doc['content'],
      textlink: doc['textlink'],
      link: doc['link'],
      image: doc['image'],
    );
  }
}