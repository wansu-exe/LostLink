import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/item_model.dart';
import '../services/mock_data.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifs = MockData.notifications;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final n = notifs[i];
          return Container(
            decoration: BoxDecoration(
              color: n.isRead ? Colors.white : AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: n.isRead ? AppColors.divider : AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _iconBg(n.type),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon(n.type), color: Colors.white, size: 20),
              ),
              title: Text(
                n.message,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              trailing: Text(
                _timeAgo(n.time),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _icon(NotificationType type) {
    switch (type) {
      case NotificationType.update:
        return Icons.campaign_outlined;
      case NotificationType.match:
        return Icons.check_circle_outline;
      case NotificationType.claimed:
        return Icons.inventory_2_outlined;
      case NotificationType.reminder:
        return Icons.notifications_outlined;
    }
  }

  Color _iconBg(NotificationType type) {
    switch (type) {
      case NotificationType.update:
        return AppColors.primary;
      case NotificationType.match:
        return AppColors.foundBadge;
      case NotificationType.claimed:
        return Colors.orange;
      case NotificationType.reminder:
        return Colors.amber.shade700;
    }
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
