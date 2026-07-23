import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_handler.dart';
import '../../../features/auth/data/auth_repository.dart';

// --- State Management ---

class NotificationState {
  final int unreadCount;
  final RemoteMessage? latestNotification;
  final List<RemoteMessage> historyCache;

  const NotificationState({
    this.unreadCount = 0,
    this.latestNotification,
    this.historyCache = const [],
  });

  NotificationState copyWith({
    int? unreadCount,
    RemoteMessage? latestNotification,
    List<RemoteMessage>? historyCache,
  }) {
    return NotificationState(
      unreadCount: unreadCount ?? this.unreadCount,
      latestNotification: latestNotification ?? this.latestNotification,
      historyCache: historyCache ?? this.historyCache,
    );
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState());

  void addNotification(RemoteMessage message) {
    final updatedHistory = [message, ...state.historyCache];
    // Keep a bounded cache (e.g., last 50)
    if (updatedHistory.length > 50) {
      updatedHistory.removeLast();
    }
    state = state.copyWith(
      latestNotification: message,
      historyCache: updatedHistory,
      unreadCount: state.unreadCount + 1,
    );
  }

  void markAllAsRead() {
    state = state.copyWith(unreadCount: 0);
  }
}

// --- Notification Service ---

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

class NotificationService {
  final Ref _ref;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  NotificationService(this._ref);

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Request permissions
    await _requestPermissions();

    // 2. Initialize Local Notifications
    await _initLocalNotifications();

    // 3. Register Token
    await _registerToken();

    // 4. Setup Listeners
    _setupListeners();

    // 5. Handle initial message if app was terminated
    await _handleInitialMessage();

    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    // Firebase permissions (iOS + Web)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permissions.');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional notification permissions.');
    } else {
      debugPrint('User declined or has not accepted permission.');
    }

    // Local notifications permissions (Android 13+)
    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      // Reconstruct minimal RemoteMessage from payload if needed
      // Or just navigate based on payload map
      // For simplicity we route using a custom mock message
      const mockMessage = RemoteMessage(data: {'type': 'EMERGENCY_REQUEST', 'emergencyId': 'payload'});
      NotificationHandler.handleNotificationNavigation(mockMessage);
    }
  }

  Future<void> _registerToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        _sendTokenToBackend(token);
      }
      
      // Listen to token refreshes
      _fcm.onTokenRefresh.listen((newToken) {
        _sendTokenToBackend(newToken);
      }).onError((err) {
        debugPrint('Error listening to token refresh: \$err');
      });
    } catch (e) {
      debugPrint('Failed to get FCM token: \$e');
      // In a real app, implement retry logic with backoff
    }
  }

  void _sendTokenToBackend(String token) {
    debugPrint('FCM Token registered: $token');
    _ref.read(authRepositoryProvider).updateFcmToken(token);
  }

  void _setupListeners() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground notification received: \${message.messageId}');
      
      // Update Riverpod state
      _ref.read(notificationProvider.notifier).addNotification(message);

      // Show local notification
      NotificationHandler.processIncomingMessage(message, this);
    });

    // Background message tapped (App was in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification caused app to open from background');
      NotificationHandler.handleNotificationNavigation(message);
    });
  }

  Future<void> _handleInitialMessage() async {
    // Terminated message tapped
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Notification caused app to open from terminated state');
      NotificationHandler.handleNotificationNavigation(initialMessage);
    }
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'emergency_channel', // id
      'Emergency Alerts', // title
      channelDescription: 'High priority alerts for blood requests',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      category: AndroidNotificationCategory.alarm,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotifications.show(id, title, body, platformDetails, payload: payload);
    } catch (e) {
      debugPrint('Failed to show local notification: \$e');
    }
  }
}
