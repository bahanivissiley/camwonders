import 'package:camwonders/class/Notification.dart';
import 'package:hive_flutter/hive_flutter.dart';

class gestionNotification {
  late Box<NotificationItem> notificationBox;

  void addNotif(){
    NotificationItem notif = NotificationItem("Bienvenu sur camwonders la meilleurs application de tourisme", "Bienvenue sur camwonders", "https://imgs.search.brave.com/p89rcGpg1i11nmOdaJduyD1D4F9OVxcT9SSBJJuOFMY/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90NC5m/dGNkbi5uZXQvanBn/LzAyLzA4LzcxLzcx/LzM2MF9GXzIwODcx/NzE2MV9pYXlmOGlp/R09ZSU1oRjJRa1V2/MHdvVkxCcmlGOWhr/aC5qcGc", false, DateTime.now());
    SetNotifications(notif);
  }

  void SetNotifications(NotificationItem notification) {
    notificationBox = Hive.box<NotificationItem>('notificationItems');
    notificationBox.clear();
    notificationBox.add(notification);
  }

  void videBox(){
    final Box<NotificationItem> box = Hive.box<NotificationItem>('notificationItems');
    box.clear(); // Vide la boîte
  }
}