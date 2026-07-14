import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Configuración para Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Configuración para iOS
    const iosSettings = DarwinInitializationSettings();

    // Inicializar
    await _notificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  // Mostrar notificación
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.show(
      // Cada argumento debe llevar su nombre (id, title, body, notificationDetails)
      id: 0,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'nfc_tracker_channel',
          'NFC Tracker',
          channelDescription: 'Notificaciones de NFC Tracker',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
