import 'package:camwonders/class/Utilisateur.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:camwonders/class/classes.dart';
import 'package:camwonders/firebase/supabase_logique.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

part "Wonder.g.dart";

// Classe Wonder
@HiveType(typeId: 1)
class Wonder {
  @HiveField(0)
  int idWonder;

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
  final double latitude;

  @HiveField(10)
  final double longitude;

  @HiveField(11)
  double note;

  @HiveField(12)
  final int categorie;

  @HiveField(13)
  final bool isreservable;

  @HiveField(14)
  final String acces;

  @HiveField(15)
  final String description_acces;

  @HiveField(16)
  final bool is_premium;

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
      required this.isreservable,
      required this.acces,
      required this.description_acces,
      required this.is_premium});

  factory Wonder.fromDocument(Map<String, dynamic> doc) {
    return Wonder(
        idWonder: doc['id'],
        wonderName: doc['wonder_name'],
        description: doc['description'],
        imagePath: doc['image_path'],
        city: doc['city'],
        region: doc['region'],
        free: doc['free'],
        price: doc['price'],
        horaire: doc['horaire'],
        latitude: doc['latitude'],
        longitude: doc['longitude'],
        note: (doc['note'] as num).toDouble(),
        categorie: doc['categorie'],
        isreservable: doc['is_reservable'],
        acces: doc['acces'],
        description_acces: doc['description_acces'],
        is_premium: doc['is_premium']
    );
  }

  void setNote(double note) {
    this.note = note;
  }


  Future<double?> getNoteForWonder() async {
    final response = await Supabase.instance.client
        .from('wonder')
        .select('note')
        .eq('id', idWonder)
        .single();

    if (response.isNotEmpty) {
      return (response['note'] as num).toDouble();
    }
    return null;
  }

  Future<List<int>> fetchAvantageIds() async {
    try {
      final response = await Supabase.instance.client
          .from('av_in_wonder')
          .select('an_in')
          .eq('wonder', idWonder);

      final List<int> avantageIds = (response as List)
          .map((doc) => doc['an_in'] as int)
          .toList();
      return avantageIds;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchImages() async {
    final response = await Supabase.instance.client
        .from('wonder_image')
        .select()
        .eq('wonder', idWonder);

    return response;
  }

  Future<List<Map<String, dynamic>>> getAvantages() async {
    final cacheKey = 'avantages$idWonder';
    final cachedData = dataCache.getAvantages(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    final List<int> ids = await fetchAvantageIds();
    final response = await Supabase.instance.client
        .from('avantage_inconvenient')
        .select()
        .inFilter('id', ids)
        .eq('is_avantage', true);

    dataCache.setAvantages(cacheKey, response);
    return response;
  }


  Future<List<Map<String, dynamic>>> getInconvenients() async {
    final cacheKey = 'inconvenients$idWonder';
    final cachedData = dataCache.getAvantages(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    final List<int> ids = await fetchAvantageIds();
    final response = await Supabase.instance.client
        .from('avantage_inconvenient')
        .select()
        .inFilter('id', ids)
        .eq('is_avantage', false);

    dataCache.setAvantages(cacheKey, response);
    return response;
  }


  Stream<List<Map<String, dynamic>>> getAvis() {
    return Supabase.instance.client
        .from('avis')
        .stream(primaryKey: ['id'])
        .eq('wonder', idWonder);;
  }

  Stream<List<Map<String, dynamic>>> getGuide() {
    return Supabase.instance.client
        .from('guide')
        .stream(primaryKey: ['id'])
        .eq('wonder', idWonder);
  }

  Future<void> addAvis(String content, double note) async {
    final Utilisateur user = await Camwonder().getUserInfo();
    final Avis avis = Avis(
        idAvis: user.idUser,
        note: note,
        content: content,
        wonder: idWonder,
        userName : user.nom,
        userImage: user.profilPath, userId: user.uid);

    final double? ancienNote = await getNoteForWonder();

    if (ancienNote != null) {
      if (ancienNote == 0) {
        await Supabase.instance.client
            .from('wonder')
            .update({'note': note})
            .eq('id', idWonder);
      } else {
        final double newNote = (ancienNote + note) / 2;
        await Supabase.instance.client
            .from('wonder')
            .update({'note': newNote})
            .eq('id', idWonder);
      }
    }

    await Supabase.instance.client.from('avis').insert({
      'note': avis.note,
      'content': avis.content,
      'wonder': avis.wonder,
      'user': avis.userId,
      'user_name': avis.userName,
      'profil_path_user': avis.userImage
    });
  }


  Future<void> addSignalement(String content) async {
    await Supabase.instance.client.from('signalement').insert({
      'wonder': idWonder,
      'content': content,
    });
  }


  Future<void> addReservation(String numeroTel, int nbrePersonnes, String date) async {
    await Supabase.instance.client.from('reservation').insert({
      'user': Supabase.instance.client.auth.currentUser!.id,
      'nbre_personnes': nbrePersonnes,
      'numero_tel': numeroTel,
      'wonder': idWonder,
      'date': date,
      'is_load': true,
      'is_validate': false,
      'motif': 'Pas encore traité',
    });
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



  Future<List<Map<String, dynamic>>> getEvenement() async {
    try {
      final response = await Supabase.instance.client
          .from('evenement')
          .select()
          .eq('wonder', idWonder);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSimilar() async {
    try {
      final response = await Supabase.instance.client
          .from('wonder')
          .select()
          .eq('region', region)
          .limit(6);

      return response;
    } catch (e) {
      rethrow;
    }
  }

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
