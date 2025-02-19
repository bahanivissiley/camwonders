import 'package:camwonders/class/Utilisateur.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/class/WonderShort.dart';
import 'package:camwonders/widgetGlobal.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Camwonder {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<List<WonderShort>> getWonderShortStream() {
    return _supabase
        .from('wonder_short')
        .stream(primaryKey: ['id'])
        .map((list) => list
        .map((doc) => WonderShort(
      idWonderShort: doc['id'],
      like: doc['likes'] as int,
      desc: doc['description'] as String,
      videoPath: doc['video_path'] as String,
      dateUpload: doc['created_at'] as String,
      vues: doc['vues'] as int,
      wond: doc['wonder'],
    ))
        .toList());
  }

  Future<void> createUser(
      String? nom, String? identifiant, String uid, String? profilPath, BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (await checkIfUserExists(uid, context)) {
      return;
    } else {
      if (profilPath != null) {
        await prefs.setString('uid', uid);
        await prefs.setString('nom', nom!);
        await prefs.setString('identifiant', identifiant!);
        await prefs.setBool('premium', false);
        await prefs.setString('profilPath', profilPath);
        final user = await _supabase.from('user').insert({
          'uid': uid,
          'name': nom,
          'identifiant': identifiant,
          'is_premium': false,
          'profil_path': profilPath,
        });
      } else {
        await prefs.setString('uid', uid);
        await prefs.setString('nom', nom!);
        await prefs.setString('identifiant', identifiant!);
        await prefs.setBool('premium', false);
        await prefs.setString('profilPath',
            "https://www.camwonders.com/static/img/Logo.jpg");
        await _supabase.from('user').insert({
          'uid': uid,
          'name': nom,
          'identifiant': identifiant,
          'is_premium': false,
          'profil_path':
          "https://www.camwonders.com/static/img/Logo.jpg",
        });
      }
    }
  }

  Future<bool> checkIfUserExists(String userId, BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Utilisateur? user = await getUserByAuthId(_supabase.auth.currentUser!.id);
    try {
      final response = await _supabase
          .from('user')
          .select()
          .eq('uid', userId)
          .single();
      if (response.isNotEmpty) {
        await prefs.setString('uid', _supabase.auth.currentUser!.id);
        await prefs.setString('nom', user!.nom);
        await prefs.setString('identifiant', user.identifiant);
        await prefs.setBool('premium', user.premium);
        await prefs.setString('profilPath', user.profilPath);
        if (user.premium) {
          Provider.of<UserProvider>(context, listen: false).setPremium(true);
        } else {
          Provider.of<UserProvider>(context, listen: false).setPremium(false);
        }
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }
  

  Future<Utilisateur?> getUserByAuthId(String userId) async {
    try {
      final response = await _supabase
          .from('user')
          .select()
          .eq('uid', userId)
          .single();
      if (response.isNotEmpty) {
        return Utilisateur.fromDocument(response);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Utilisateur> getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = _supabase.auth.currentUser!.id;
    final String? nom = prefs.getString('nom');
    final String? identifiant = prefs.getString('identifiant');
    final bool? premium = prefs.getBool('premium');
    final String? profilPath = prefs.getString('profilPath');

    if (nom == null || identifiant == null) {
      return Utilisateur(
          idUser: 1,
          uid: 'sdds',
          identifiant: "Pas connecté",
          nom: "Utilisateur inconnu",
          premium: false,
          profilPath:
          "https://www.camwonders.com/static/img/Logo.jpg");
    }

    if (profilPath == null){
      return Utilisateur(
          idUser: 1,
          uid: _supabase.auth.currentUser!.id,
          identifiant: identifiant,
          nom: nom,
          premium: premium!,
          profilPath: "assets/profil.png");
    }

    return Utilisateur(
        idUser: 1,
        uid: _supabase.auth.currentUser!.id,
        identifiant: identifiant,
        nom: nom,
        premium: premium!,
        profilPath: profilPath);
  }



  Future<List<Map<String, dynamic>>> getReservations() async {
    try {
      final response = await _supabase
          .from('reservation')
          .select()
          .eq('user', _supabase.auth.currentUser!.id);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getWonder() async {
    try {
      final response = await _supabase.from('wonder').select();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReservation(int documentId) async {
    await _supabase.from('reservation').delete().eq('id', documentId);
  }

  Future<Wonder?> getWonderById(int wonderId) async {
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);
    print(wonderId);

    try {
      final response = await _supabase
          .from('wonder')
          .select()
          .eq('id', wonderId)
          .single();
        return Wonder.fromDocument(response);
    } catch (e) {
      return null;
    }
  }



  Future<Utilisateur?> getUserByUniqueId(int userId) async {
    try {
      final response = await _supabase
          .from('user')
          .select()
          .eq('id', userId)
          .single();
      if (response != null) {
        return Utilisateur.fromDocument(response);
      } else {
        print('Utilisateur non trouvé pour l\'id: $userId');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur : $e');
      return null;
    }
  }

  Future<Utilisateur?> getUserByUniqueRealId(String userId) async {
    try {
      final response = await _supabase
          .from('user')
          .select()
          .eq('uid', userId)
          .single();
      if (response != null) {
        return Utilisateur.fromDocument(response);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }




  static Future<void> updatePremiumStatusByFieldId(String userIdField, bool isPremium) async {
    try {
       await Supabase.instance.client
          .from('users')
          .update({'premium': isPremium})
          .eq('id', userIdField);
    } catch (e) {
      print('Erreur lors de la mise à jour du statut premium : $e');
    }
  }
}