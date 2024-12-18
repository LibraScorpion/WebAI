import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../settings/settings_service.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final SettingsService _settingsService;

  NotificationService(this._settingsService);

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  Future<bool> requestPermission() async {
    if (!_settingsService.getNotificationsEnabled()) {
      return false;
    }

    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }

    return true;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_settingsService.getNotificationsEnabled()) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'webai_channel',
      'WebAI Notifications',
      channelDescription: 'Notifications from WebAI',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> showMessageNotification({
    required String sender,
    required String message,
  }) async {
    if (!_settingsService.getChatNotificationsEnabled()) {
      return;
    }

    await showNotification(
      title: 'New message from $sender',
      body: message,
      payload: 'chat',
    );
  }

  Future<void> showImageGenerationNotification({
    required bool success,
    String? error,
  }) async {
    if (success) {
      await showNotification(
        title: 'Image Generation Complete',
        body: 'Your image has been generated successfully',
        payload: 'image_generation',
      );
    } else {
      await showNotification(
        title: 'Image Generation Failed',
        body: error ?? 'Failed to generate image',
        payload: 'image_generation_error',
      );
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
