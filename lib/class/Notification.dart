import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part "Notification.g.dart";

@HiveType(typeId: 2)
class NotificationItem {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String message;
  @HiveField(2)
  final String image;
  @HiveField(3)
  bool read;
  @HiveField(4) // Nouveau champ
  final DateTime timestamp; // Ajoutez ce champ pour trier les notifications

  NotificationItem(this.message, this.title, this.image, this.read, this.timestamp);
}