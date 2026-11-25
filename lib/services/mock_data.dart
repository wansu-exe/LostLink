import '../models/item_model.dart';

class MockData {
  static final List<ItemModel> items = [
    ItemModel(
      id: 'LST-20261125-001',
      name: 'Black Backpack',
      description:
          'Black backpack with a small Nike logo. Contains notebooks and a laptop.',
      location: 'Embarcadero Park',
      date: DateTime(2026, 11, 25, 15, 15),
      status: ItemStatus.lost,
      imageUrl: null,
      reportedBy: 'Jose Arym Diaz III',
      category: 'Bags',
    ),
    ItemModel(
      id: 'FND-20261125-002',
      name: 'Wireless Earbuds',
      description: 'Black wireless earbuds found near the library entrance.',
      location: 'SM Legazpi',
      date: DateTime(2026, 11, 25, 10, 30),
      status: ItemStatus.found,
      imageUrl: null,
      reportedBy: 'Maria Santos',
      category: 'Electronics',
    ),
    ItemModel(
      id: 'LST-20261124-003',
      name: 'Student ID Card',
      description: 'DWC-L student ID, name: Juan dela Cruz.',
      location: 'Gymnasium',
      date: DateTime(2026, 11, 24, 14, 0),
      status: ItemStatus.lost,
      imageUrl: null,
      reportedBy: 'Juan dela Cruz',
      category: 'ID / Cards',
    ),
    ItemModel(
      id: 'FND-20261124-004',
      name: 'Blue Umbrella',
      description: 'Medium blue foldable umbrella left in Room 201.',
      location: 'Main Building Room 201',
      date: DateTime(2026, 11, 24, 9, 0),
      status: ItemStatus.found,
      imageUrl: null,
      reportedBy: 'Ana Reyes',
      category: 'Accessories',
    ),
    ItemModel(
      id: 'LST-20261123-005',
      name: 'Car Keys',
      description: 'Toyota car keys with a red lanyard.',
      location: 'Canteen',
      date: DateTime(2026, 11, 23, 12, 0),
      status: ItemStatus.lost,
      imageUrl: null,
      reportedBy: 'Pedro Villanueva',
      category: 'Keys',
    ),
    ItemModel(
      id: 'FND-20261122-006',
      name: 'Eyeglasses',
      description: 'Black frame prescription eyeglasses found in a case.',
      location: 'Library',
      date: DateTime(2026, 11, 22, 16, 30),
      status: ItemStatus.found,
      imageUrl: null,
      reportedBy: 'Liza Cruz',
      category: 'Accessories',
    ),
  ];

  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: '1',
      message:
          'Your lost item report (LST-20261125-001) has been updated.',
      time: DateTime.now().subtract(const Duration(minutes: 2)),
      type: NotificationType.update,
    ),
    NotificationModel(
      id: '2',
      message: 'A new match for your lost item! Tap to view.',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      type: NotificationType.match,
    ),
    NotificationModel(
      id: '3',
      message: 'Your found item has been claimed.',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      type: NotificationType.claimed,
      isRead: true,
    ),
    NotificationModel(
      id: '4',
      message: 'Reminder: Keep your items secure!',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.reminder,
      isRead: true,
    ),
  ];
}
