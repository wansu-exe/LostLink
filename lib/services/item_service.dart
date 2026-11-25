import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class ItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Collections ───────────────────────────────────────────────────────────

  CollectionReference get _items => _db.collection('items');
  CollectionReference get _claims => _db.collection('claims');

  // ─── Items ─────────────────────────────────────────────────────────────────

  /// Live stream of all items, newest first. Used by Home Feed.
  Stream<List<ItemModel>> watchAllItems() {
    return _items
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_toList);
  }

  /// Live stream filtered to a single status ('lost' or 'found').
  Stream<List<ItemModel>> watchItemsByStatus(String status) {
    return _items
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_toList);
  }

  /// Live stream of items reported by [uid]. Used by My Reports.
  Stream<List<ItemModel>> watchMyItems(String uid) {
    return _items
        .where('reportedByUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_toList);
  }

  /// Search by item name (simple prefix match via Firestore range query).
  /// For full-text search, replace with Algolia / Typesense later.
  Future<List<ItemModel>> searchItems(String query) async {
    if (query.trim().isEmpty) return [];
    final snap = await _items
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .get();
    return _toList(snap);
  }

  /// Add a new item document.  Returns the auto-generated Firestore ID.
  Future<String> addItem({
    required String name,
    required String description,
    required String location,
    required String status,       // 'lost' | 'found'
    required String category,
    required String reportedByUid,
    required String reportedByName,
    String? photoUrl,
    DateTime? date,
  }) async {
    final ref = _items.doc(); // auto-generate ID
    await ref.set({
      'id': ref.id,
      'name': name,
      'description': description,
      'location': location,
      'status': status,
      'category': category,
      'reportedByUid': reportedByUid,
      'reportedByName': reportedByName,
      'photoUrl': photoUrl,
      'date': (date ?? DateTime.now()).toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
      'claimStatus': 'open', // open | claimed | returned
    });
    return ref.id;
  }

  /// Update the claimStatus field (admin use).
  Future<void> updateClaimStatus(String itemId, String claimStatus) async {
    await _items.doc(itemId).update({'claimStatus': claimStatus});
  }

  // ─── Claims ────────────────────────────────────────────────────────────────

  /// Submit a claim on an item.
  Future<void> submitClaim({
    required String itemId,
    required String claimedByUid,
    required String claimedByName,
    required String proofDescription,
  }) async {
    final ref = _claims.doc();
    await ref.set({
      'id': ref.id,
      'itemId': itemId,
      'claimedByUid': claimedByUid,
      'claimedByName': claimedByName,
      'proofDescription': proofDescription,
      'status': 'pending',       // pending | approved | rejected
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Live stream of all pending claims — for the Admin Review Dashboard.
  Stream<QuerySnapshot> watchPendingClaims() {
    return _claims
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Approve or reject a claim (admin).
  Future<void> reviewClaim(String claimId, String decision) async {
    // decision: 'approved' | 'rejected'
    await _claims.doc(claimId).update({'status': decision});
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  List<ItemModel> _toList(QuerySnapshot snap) {
    return snap.docs.map((doc) {
      final d = doc.data() as Map<String, dynamic>;
      return ItemModel(
        id: d['id'] ?? doc.id,
        name: d['name'] ?? '',
        description: d['description'] ?? '',
        location: d['location'] ?? '',
        date: DateTime.tryParse(d['date'] ?? '') ?? DateTime.now(),
        status: d['status'] == 'found' ? ItemStatus.found : ItemStatus.lost,
        imageUrl: d['photoUrl'],
        reportedBy: d['reportedByName'] ?? '',
        category: d['category'] ?? 'Others',
      );
    }).toList();
  }
}
