import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

/// Top-level function for handling background messages
/// Must not depend on UI or context
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If we need to perform data-only processing in the background, we do it here.
  // We can also initialize local notifications to show custom UI.
  debugPrint('Handling a background message: ${message.messageId}');
}

class NotificationHandler {
  static void handleNotificationNavigation(RemoteMessage message) {
    final type = message.data['type'];
    final emergencyId = message.data['emergencyId'];

    if (emergencyId == null) return;

    // Based on the type of notification, deep link appropriately.
    // Assuming go_router is configured to handle deep links or we use a global navigator key.
    // A simplified generic approach for now (actual navigation depends on app router setup)
    
    // We would typically dispatch an event or push to a global navigation service.
    // For this boilerplate, we log the intended route.
    
    if (type == 'EMERGENCY_REQUEST') {
      debugPrint('Deep Link -> /emergency/response/$emergencyId');
    } else if (['EMERGENCY_ACCEPTED', 'DONOR_ASSIGNED', 'DONATION_COMPLETED'].contains(type)) {
      debugPrint('Deep Link -> /emergency/$emergencyId');
    } else {
      // Default to history or details
      debugPrint('Deep Link -> /emergency/$emergencyId');
    }
  }

  static void processIncomingMessage(RemoteMessage message, NotificationService service) {
    // Show local notification if the app is in the foreground
    if (message.notification != null) {
      service.showLocalNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }
}
