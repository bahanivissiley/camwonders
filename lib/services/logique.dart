import 'package:camwonders/class/Wonder.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:http/http.dart' as http;

class Logique {
  late Box<Wonder> favorisBox;
  void SetFavorisWonder(Wonder wonder){
    favorisBox = Hive.box<Wonder>('favoris_wonders');
    favorisBox.add(wonder);
  }

  void supprimerFavorisWonder(int index) {
    favorisBox = Hive.box<Wonder>('favoris_wonder');
    favorisBox.deleteAt(index);
  }

  static Future<bool> checkInternetConnection() async {
    final bool isConnected = await InternetConnection().hasInternetAccess;
    if (isConnected){
      return true;
    }else{
      return false;
    }
  }

}