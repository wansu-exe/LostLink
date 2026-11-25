import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/item_model.dart';
import '../services/mock_data.dart';
import '../widgets/item_card.dart';
import 'item_detail_screen.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myItems = MockData.items
        .where((i) => i.reportedBy == 'Jose Arym Diaz III')
        .toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: AppColors.primary,
      ),
      body: myItems.isEmpty
          ? const Center(
              child: Text('No reports yet.',
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myItems.length,
              itemBuilder: (_, i) => ItemCard(
                item: myItems[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemDetailScreen(item: myItems[i]),
                  ),
                ),
              ),
            ),
    );
  }
}
