enum ItemStatus { lost, found }

class ItemModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime date;
  final ItemStatus status;
  final String? imageUrl;
  final String reportedBy;
  final String category;

  ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.status,
    this.imageUrl,
    required this.reportedBy,
    required this.category,
  });
}

class NotificationModel {
  final String id;
  final String message;
  final DateTime time;
  final NotificationType type;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType { update, match, claimed, reminder }
