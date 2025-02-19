import 'package:camwonders/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  bool isOpened; // Pour savoir si elle est déjà lue

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.isOpened = false,
  });

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'isOpened': isOpened,
    };
  }

  // Créer une notification depuis JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      isOpened: json['isOpened'],
    );
  }
}


class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  NotificationProvider() {
    eventBus.on<NotificationEvent>().listen((event) {
      addNotification(event.title!, event.body!);
    });
    _loadNotifications();

  }



  // Ajouter une nouvelle notification
  Future<void> addNotification(String title, String message) async {
    final newNotification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
    );
    _notifications.insert(0, newNotification);
    await _saveNotifications();
    notifyListeners();
  }

  // Marquer une notification comme lue
  Future<void> markAsRead(String id) async {
    for (var notification in _notifications) {
      if (notification.id == id) {
        notification.isOpened = true;
        break;
      }
    }
    await _saveNotifications();
    notifyListeners();
  }

  // Supprimer une notification
  Future<void> removeNotification(String id) async {
    _notifications.removeWhere((notification) => notification.id == id);
    await _saveNotifications();
    notifyListeners();
  }

  // Charger les notifications depuis SharedPreferences
  Future<void> _loadNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('notifications');
    if (data != null) {
      final List<dynamic> jsonData = jsonDecode(data);
      _notifications = jsonData.map((item) => NotificationModel.fromJson(item)).toList();
      notifyListeners();
    }
  }

  // Sauvegarder les notifications dans SharedPreferences
  Future<void> _saveNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonData = jsonEncode(_notifications.map((notif) => notif.toJson()).toList());
    await prefs.setString('notifications', jsonData);
  }
}




/*
class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void initialize(BuildContext context) {
    // Demander l'autorisation pour les notifications
    _firebaseMessaging.requestPermission();

    // Écouter les messages en arrière-plan et lorsque l'application est ouverte
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message, context);
    });

    // Écouter les messages lorsque l'application est en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message, context);
    });

    // Gérer les messages lorsque l'application est terminée
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleMessage(message, context);
      }
    });
  }

  void _handleMessage(RemoteMessage message, BuildContext context) {
    final notificationProvider =
    Provider.of<NotificationProvider>(context, listen: false);

    // Ajouter la notification au provider
    notificationProvider.addNotification(
      message.notification?.title ?? 'Nouvelle notification',
      message.notification?.body ?? 'Vous avez reçu une nouvelle notification.',
    );
  }
}

*/