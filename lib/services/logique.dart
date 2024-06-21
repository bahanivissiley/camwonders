import 'package:camwonders/class/Wonder.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
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
    bool result = await InternetConnectionChecker().hasConnection;
    if (result){
      try {
        await http.get(Uri.parse('https://www.google.com')).timeout(Duration(seconds: 10));
        return true;
      } catch (e) {
        return false;
      }
    }else{
      return false;
    }
  }

}