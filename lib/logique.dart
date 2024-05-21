import 'package:camwonders/class/classes.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
class Logique {
  late Box<Wonder> favorisBox;
  void SetFavorisWonder(Wonder wonder){
    favorisBox = Hive.box<Wonder>('favoris_wonders');
    favorisBox.add(wonder);
  }

  void supprimerFavorisWonder(int index) {
    favorisBox = Hive.box<Wonder>('favoris_wonders');
    favorisBox.deleteAt(index);
  }
}