import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../../../main.dart';
import '../../features/emergency/presentation/screens/donor_response_screen.dart';
import '../../features/emergency/presentation/screens/emergency_details_screen.dart';
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
    if (message.data.isEmpty) return; // Ignore malformed

    final type = message.data['type'];
    final emergencyId = message.data['emergencyId'];

    if (emergencyId == null || type == null) return; // Ignore malformed

    final navigator = globalNavigatorKey.currentState;
    if (navigator == null) return;

    final routeName = type == 'EMERGENCY_REQUEST' 
        ? '/emergency/response/$emergencyId' 
        : '/emergency/details/$emergencyId';

    // Prevent duplicate navigation if already viewing the destination screen
    bool isCurrentRoute = false;
    navigator.popUntil((route) {
      isCurrentRoute = route.settings.name == routeName;
      return true; // Stop immediately, popping nothing
    });

    if (isCurrentRoute) {
      debugPrint('Already on $routeName, ignoring navigation');
      return;
    }

    if (type == 'EMERGENCY_REQUEST') {
      navigator.push(MaterialPageRoute(
        settings: RouteSettings(name: routeName),
        builder: (_) => DonorResponseScreen(requestId: emergencyId),
      ));
    } else {
      // Default for EMERGENCY_ACCEPTED, DONOR_ASSIGNED, DONOR_ARRIVED, DONATION_COMPLETED
      navigator.push(MaterialPageRoute(
        settings: RouteSettings(name: routeName),
        builder: (_) => EmergencyDetailsScreen(requestId: emergencyId),
      ));
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
