import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('notifications');
    if (data != null) {
      List<dynamic> jsonData = jsonDecode(data);
      _notifications = jsonData.map((item) => NotificationModel.fromJson(item)).toList();
      notifyListeners();
    }
  }

  // Sauvegarder les notifications dans SharedPreferences
  Future<void> _saveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(_notifications.map((notif) => notif.toJson()).toList());
    await prefs.setString('notifications', jsonData);
  }
}
