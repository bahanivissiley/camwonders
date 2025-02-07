import 'package:camwonders/class/Notification.dart';
import 'package:camwonders/pages/bottomNavigator/menu/vues.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications", style: TextStyle(color: Colors.white),), backgroundColor: ListeVue.verte,),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          return ListView.builder(
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];

              return ListTile(
                leading: Icon(
                  notification.isOpened ? Icons.notifications_none : Icons.notifications_active,
                  color: notification.isOpened ? Colors.grey : Colors.green,
                ),
                title: Text(notification.title),
                subtitle: Text(notification.message),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    notificationProvider.removeNotification(notification.id);
                  },
                ),
                onTap: () {
                  _showNotificationDialog(context, notification);
                  notificationProvider.markAsRead(notification.id);
                },
              );
            },
          );
        },
      ),
    );
  }

  // Fonction pour afficher la notification dans un modal
  void _showNotificationDialog(BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(notification.title),
          content: Text(notification.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Fermer"),
            ),
          ],
        );
      },
    );
  }
}
