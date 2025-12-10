import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification.dart' as model;
import 'notification_service.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  StreamController<model.Notification>? _notificationController;
  Timer? _pollingTimer;
  Set<int> _shownNotificationIds = {};
  bool _isInitialized = false;
  bool _isPolling = false;
  
  Stream<model.Notification>? get notificationStream => _notificationController?.stream;

  /// Initialize push notifications
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      _isInitialized = true;
      print('Push notification service initialized');
      
      // Start polling for notifications
      startPolling();
    } catch (e) {
      print('Error initializing push notifications: $e');
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'unipool_notifications',
      'UniPool Notifications',
      description: 'Notifications for ride updates and bookings',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Navigate to notifications screen or specific screen based on payload
    if (_notificationController != null && response.payload != null) {
      // You can parse the payload and create a notification object
      // For now, we'll just trigger a refresh
    }
  }

  /// Start polling for new notifications
  void startPolling() {
    if (_isPolling) return;
    
    _isPolling = true;
    // Poll every 30 seconds for new notifications
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkForNewNotifications();
    });
    
    // Also check immediately
    _checkForNewNotifications();
  }

  /// Stop polling for notifications
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  /// Check for new notifications from backend
  Future<void> _checkForNewNotifications() async {
    try {
      // Get unread notifications from backend
      final unreadNotifications = await NotificationService.getUnreadNotifications();
      
      // Show local notifications for new unread notifications
      for (final notification in unreadNotifications) {
        if (!_shownNotificationIds.contains(notification.id)) {
          await _showLocalNotification(notification);
          _shownNotificationIds.add(notification.id);
          
          // Emit to stream if controller exists
          if (_notificationController != null) {
            _notificationController!.add(notification);
          }
        }
      }
      
      // Clean up old notification IDs (keep last 100)
      if (_shownNotificationIds.length > 100) {
        final idsToKeep = unreadNotifications.map((n) => n.id).toSet();
        _shownNotificationIds = _shownNotificationIds.intersection(idsToKeep);
      }
    } catch (e) {
      print('Error checking for new notifications: $e');
      // Don't throw - polling failures shouldn't break the app
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(model.Notification notification) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'unipool_notifications',
      'UniPool Notifications',
      channelDescription: 'Notifications for ride updates and bookings',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id,
      notification.title,
      notification.body,
      details,
      payload: notification.id.toString(),
    );
  }

  /// Initialize notification stream controller
  void initializeNotificationStream() {
    _notificationController = StreamController<model.Notification>.broadcast();
  }

  /// Dispose notification stream controller
  void disposeNotificationStream() {
    _notificationController?.close();
    _notificationController = null;
  }

  /// Manually check for notifications (useful for pull-to-refresh)
  Future<void> refreshNotifications() async {
    await _checkForNewNotifications();
  }

  /// Clear shown notification IDs (useful when user marks all as read)
  void clearShownNotificationIds() {
    _shownNotificationIds.clear();
  }

  /// Mark a notification as shown (prevents duplicate notifications)
  void markNotificationAsShown(int notificationId) {
    _shownNotificationIds.add(notificationId);
  }
}
