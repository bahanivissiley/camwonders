import 'package:camwonders/class/Utilisateur.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:camwonders/class/classes.dart';
import 'package:camwonders/firebase/firebase_logique.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part "Wonder.g.dart";

// Classe Wonder
@HiveType(typeId: 1)
class Wonder {
  @HiveField(0)
  String idWonder;

  @HiveField(1)
  String wonderName;

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
  final String latitude;

  @HiveField(10)
  final String longitude;

  @HiveField(11)
  double note;

  @HiveField(12)
  final String categorie;

  @HiveField(13)
  final bool isreservable;

  Wonder(
      {required this.idWonder,
      required this.wonderName,
      required this.description,
      required this.imagePath,
      required this.city,
      required this.region,
      required this.free,
      required this.price,
      required this.horaire,
      required this.latitude,
      required this.longitude,
      required this.note,
      required this.categorie,
      required this.isreservable});

  factory Wonder.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Wonder(
        idWonder: doc.id,
        wonderName: data['wonderName'],
        description: data['description'],
        imagePath: data['imagePath'],
        city: data['city'],
        region: data['region'],
        free: data['free'],
        price: data['price'],
        horaire: data['horaire'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        note: (data['note'] as num).toDouble(),
        categorie: data['categorie'],
        isreservable: data['isreservable'],
    );
  }

  void setNote(double note) {
    this.note = note;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<double?> getNoteForWonder() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('wonders')
        .doc(idWonder)
        .get();

    if (documentSnapshot.exists) {
      return (documentSnapshot.get('note') as num).toDouble();
    }
    return null;
  }

  Future<List<String>> fetchAvantageIds() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('avantage_or_inconvenient_wonder')
          .where('wonder_id', isEqualTo: idWonder)
          .get();

      List<String> avantageIds = querySnapshot.docs
          .map((doc) => doc['avantage_or_inconvenient_id'] as String)
          .toList();

      return avantageIds;
    } catch (e) {
      print('Error fetching documents: $e');
      return [];
    }
  }

  Future<QuerySnapshot> fetchImages() async {
    return FirebaseFirestore.instance
        .collection('images_wonder')
        .where('wonder_id', isEqualTo: idWonder)
        .get();
  }

  Future<List<Map<String, dynamic>>> getAvantages() async {
    final cacheKey = 'avantages$idWonder';
    final cachedData = dataCache.getAvantages(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    List<String> ids = await fetchAvantageIds();
    print(ids);
    final querySnapshot = await FirebaseFirestore.instance
        .collection('avantages_or_inconvenients')
        .where('avantage', isEqualTo: true)
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    final avantages = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    dataCache.setAvantages(cacheKey, avantages);
    return avantages;
  }


  Future<List<Map<String, dynamic>>> getInconvenients() async {
    final cacheKey = 'inconvenients$idWonder';
    final cachedData = dataCache.getAvantages(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    List<String> ids = await fetchAvantageIds();
    final querySnapshot = await FirebaseFirestore.instance
        .collection('avantages_or_inconvenients')
        .where('avantage', isEqualTo: false)
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    final inconvenients = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    dataCache.setAvantages(cacheKey, inconvenients);
    return inconvenients;
  }


  Stream<QuerySnapshot> getAvis() {
    return FirebaseFirestore.instance
        .collection('avis')
        .where('wonder', isEqualTo: idWonder)
        .orderBy('note', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getGuide() {
    return FirebaseFirestore.instance
        .collection('guides')
        .where('wonder', isEqualTo: idWonder)
        .snapshots();
  }

  Future<void> addAvis(String content, double note) async {
    Utilisateur user = await Camwonder().getUserInfo();
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: AuthService().currentUser!.uid)
        .get();
    Avis avis = Avis(
        idAvis: "id_sera_genere",
        note: note,
        content: content,
        wonder: idWonder,
        user: querySnapshot.docs.first.id,
        userImage: user.profilPath);
    CollectionReference avisFirebase = FirebaseFirestore.instance.collection('avis');
    double? ancienNote = await getNoteForWonder();

    if (ancienNote != null) {
      if(ancienNote == 0){

        await FirebaseFirestore.instance
            .collection('wonders')
            .doc(idWonder)
            .update({'note': note});
      }else{
        double newNote = (ancienNote + note) / 2;

        await FirebaseFirestore.instance
            .collection('wonders')
            .doc(idWonder)
            .update({'note': newNote});
      }
    }

    return avisFirebase
        .add({
          'note': avis.note,
          'content': avis.content,
          'wonder': avis.wonder,
          'user': avis.user,
          'userImage': avis.userImage,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }


  Future<void> addReservation(String numeroTel, int nbrePersonnes, String date) async {

    CollectionReference ReservationFirebase = FirebaseFirestore.instance.collection('reservations');
    return ReservationFirebase
        .add({
      'user': AuthService().currentUser!.uid,
      'nbrePersonnes': nbrePersonnes,
      'numeroTel': numeroTel,
      'idWonder': idWonder,
      'date': date,
      'isload': true,
      'isvalidate': false,
      'motif': 'Pas encore traité'
    })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }


  Future<Map<String, dynamic>> meteoFetch() async {
    final cacheKey = 'weather_$latitude$longitude';
    final cachedData = dataCache.getWeather(cacheKey);

    if (cachedData != null) {
      return cachedData;
    }

      const apiKey = 'fdb4843fefffdf57f4a530d420b0ecc5';
      final url = 'https://api.openweathermap.org/data/3.0/onecall?lat=$latitude&lon=$longitude&exclude=minutely,hourly,alerts&appid=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      dataCache.setWeather(cacheKey, data);
      return data;
    } else {
      throw Exception('Failed to load weather data');
    }
  }



  Future<QuerySnapshot> getEvenement() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('evenements')
          .where('idwonder', isEqualTo: idWonder)
          .get();

      return querySnapshot;
    } catch (e) {
      print('Error fetching documents: $e');
      rethrow;  // Optionnel : vous pouvez relancer l'exception ou gérer l'erreur d'une autre manière
    }
  }

  Future<QuerySnapshot> getSimilar() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('wonders')
          .where('region', isEqualTo: region).limit(6)
          .get();

      return querySnapshot;
    } catch (e) {
      print('Error fetching documents: $e');
      rethrow;  // Optionnel : vous pouvez relancer l'exception ou gérer l'erreur d'une autre manière
    }
  }

  /*
  Future<CollectionReference<Map<String, dynamic>>> getAvantages() async {
    String? avantageId = await fetchAvantageId(idWonder);
    return _firestore.collection('avantages_or_inconvenients')..where('avantage', isEqualTo: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AvantagesInconvenient.fromDocument(doc);
      }).toList();
    });
  }*/

  //getAvis()

  //getPosition()

  //getImages()

  //getSimilary()

  //Reserver()

  //setMeteoTime()

  //List<AvantagesInconvenient> getAvantages()
}


class DataCache {
  final Map<String, Map<String, dynamic>> _weatherCache = {};
  final Map<String, List<Map<String, dynamic>>> _avantagesCache = {};
  final Map<String, List<Map<String, dynamic>>> _inconvenientsCache = {};

  Map<String, dynamic>? getWeather(String key) {
    return _weatherCache[key];
  }

  void setWeather(String key, Map<String, dynamic> data) {
    _weatherCache[key] = data;
  }

  List<Map<String, dynamic>>? getAvantages(String key) {
    return _avantagesCache[key];
  }

  void setAvantages(String key, List<Map<String, dynamic>> data) {
    _avantagesCache[key] = data;
  }

  List<Map<String, dynamic>>? getInconvenients(String key) {
    return _inconvenientsCache[key];
  }

  void setInconvenients(String key, List<Map<String, dynamic>> data) {
    _inconvenientsCache[key] = data;
  }

  void clearAllCache() {
    _weatherCache.clear();
    _avantagesCache.clear();
    _inconvenientsCache.clear();
  }
}

final DataCache dataCache = DataCache();
