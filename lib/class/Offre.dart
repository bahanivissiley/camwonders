class Offre{
  final int id;
  final String title;
  final String content;
  final String textlink;
  final String link;
  final String image;

  Offre({required this.id, required this.title, required this.content, required this.textlink, required this.link, required this.image});

  factory Offre.fromDocument(Map<String, dynamic> doc) {
    return Offre(
      id: doc['id'],
      title: doc['title'],
      content: doc['content'],
      textlink: doc['textlink'],
      link: doc['link'],
      image: doc['image'],
    );
  }
}