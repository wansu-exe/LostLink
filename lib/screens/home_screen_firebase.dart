// Replace home_screen.dart with this file after Firebase setup.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/item_service.dart';
import '../models/item_model.dart';
import '../theme/app_theme.dart';
import '../widgets/item_card.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _itemService = ItemService();
  ItemStatus? _filter;

  Stream<List<ItemModel>> get _stream {
    if (_filter == null) return _itemService.watchAllItems();
    return _itemService.watchItemsByStatus(
        _filter == ItemStatus.lost ? 'lost' : 'found');
  }

  String get _greeting {
    final name = FirebaseAuth.instance.currentUser?.displayName ?? 'there';
    final first = name.split(' ').first;
    return first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(text: const TextSpan(children: [
                          TextSpan(text: 'Lost', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                          TextSpan(text: 'Link', style: TextStyle(color: AppColors.accent, fontSize: 20, fontWeight: FontWeight.w800)),
                        ])),
                        const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('👋 Hi, $_greeting!\nLet\'s help you find what you\'re looking for.',
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search for items...',
                          hintStyle: TextStyle(fontSize: 13),
                          prefixIcon: Icon(Icons.search, size: 20),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(children: [
                  _chip(null, 'All'),
                  const SizedBox(width: 8),
                  _chip(ItemStatus.lost, 'Lost'),
                  const SizedBox(width: 8),
                  _chip(ItemStatus.found, 'Found'),
                ]),
              ),
            ),

            // Header row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Posts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Row(children: const [
                      Text('See all', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                    ]),
                  ],
                ),
              ),
            ),

            // Live Firestore list
            StreamBuilder<List<ItemModel>>(
              stream: _stream,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                if (snap.hasError) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Error: ${snap.error}', style: const TextStyle(color: AppColors.danger)),
                    ),
                  );
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: Text('No items yet. Be the first to report!', style: TextStyle(color: AppColors.textSecondary))),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => ItemCard(
                        item: items[i],
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => ItemDetailScreen(item: items[i]))),
                      ),
                      childCount: items.length,
                    ),
                  ),
                );
              },
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }

  Widget _chip(ItemStatus? status, String label) {
    final isSelected = _filter == status;
    Color color = status == ItemStatus.lost
        ? AppColors.lostBadge
        : status == ItemStatus.found
            ? AppColors.foundBadge
            : AppColors.primary;
    return GestureDetector(
      onTap: () => setState(() => _filter = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : AppColors.divider),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, fontSize: 13)),
      ),
    );
  }
}
