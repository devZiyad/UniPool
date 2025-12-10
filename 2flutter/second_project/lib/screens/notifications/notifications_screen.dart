import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notification.dart' as model;
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_drawer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<model.Notification> _notifications = [];
  bool _isLoading = true;
  String? _error;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await NotificationService.getMyNotifications();
      final unreadCount = await NotificationService.getUnreadCount();

      // Sort by created date (newest first)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _notifications = notifications.cast<model.Notification>();
        _unreadCount = unreadCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(model.Notification notification) async {
    if (notification.read) return;

    try {
      await NotificationService.markAsRead(notification.id);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          final updatedNotification = model.Notification(
            id: notification.id,
            userId: notification.userId,
            type: notification.type,
            title: notification.title,
            body: notification.body,
            read: true,
            createdAt: notification.createdAt,
          );
          _notifications[index] = updatedNotification;
          if (_unreadCount > 0) {
            _unreadCount--;
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking notification as read: $e')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      setState(() {
        _notifications = _notifications.map((n) {
          return model.Notification(
            id: n.id,
            userId: n.userId,
            type: n.type,
            title: n.title,
            body: n.body,
            read: true,
            createdAt: n.createdAt,
          );
        }).toList();
        _unreadCount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking all as read: $e')),
      );
    }
  }

  bool _isDriverNotification(String type) {
    return type.toUpperCase().contains('BOOKING') ||
        type.toUpperCase().contains('RIDE') ||
        type.toUpperCase().contains('DRIVER');
  }

  bool _isRiderNotification(String type) {
    return type.toUpperCase().contains('BOOKING') ||
        type.toUpperCase().contains('RIDE') ||
        type.toUpperCase().contains('RIDER');
  }

  IconData _getNotificationIcon(String type) {
    final upperType = type.toUpperCase();
    if (upperType.contains('BOOKING_REQUESTED')) {
      return Icons.notifications_active;
    } else if (upperType.contains('BOOKING_CONFIRMED')) {
      return Icons.check_circle;
    } else if (upperType.contains('BOOKING_CANCELLED')) {
      return Icons.cancel;
    } else if (upperType.contains('RIDE_STARTED')) {
      return Icons.directions_car;
    } else if (upperType.contains('RIDE_COMPLETED')) {
      return Icons.flag;
    } else {
      return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    final upperType = type.toUpperCase();
    if (upperType.contains('CONFIRMED') || upperType.contains('COMPLETED')) {
      return AppTheme.success;
    } else if (upperType.contains('CANCELLED')) {
      return AppTheme.error;
    } else if (upperType.contains('REQUESTED') || upperType.contains('STARTED')) {
      return AppTheme.info;
    } else {
      return AppTheme.primaryGreen;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all as read'),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading notifications',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.softGrayText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: AppTheme.softGrayText,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.darkNavy,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You\'re all caught up!',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.softGrayText,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        final isDriver = _isDriverNotification(notification.type);
                        final isRider = _isRiderNotification(notification.type);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: notification.read
                              ? AppTheme.white
                              : AppTheme.primaryGreen.withOpacity(0.05),
                          child: InkWell(
                            onTap: () => _markAsRead(notification),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _getNotificationColor(
                                        notification.type,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getNotificationIcon(notification.type),
                                      color: _getNotificationColor(
                                        notification.type,
                                      ),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notification.title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.darkNavy,
                                                ),
                                              ),
                                            ),
                                            if (!notification.read)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryGreen,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notification.body,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.darkNavy
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            if (isDriver && isRider)
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryGreen
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'Both',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.primaryGreen,
                                                  ),
                                                ),
                                              )
                                            else if (isDriver)
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.darkNavy
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'Driver',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.darkNavy,
                                                  ),
                                                ),
                                              )
                                            else if (isRider)
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.info
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'Rider',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.info,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatDate(notification.createdAt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.softGrayText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

