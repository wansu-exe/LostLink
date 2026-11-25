// Replace report_screen.dart with this file after Firebase setup.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/item_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _itemService = ItemService();
  final _storageService = StorageService();

  bool _isLost = true;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;
  File? _photo;
  bool _uploading = false;
  String? _error;

  final List<String> _categories = [
    'Bags', 'Electronics', 'ID / Cards', 'Keys', 'Accessories', 'Others'
  ];

  Future<void> _pickPhoto() async {
    final file = await _storageService.pickImage();
    if (file != null) setState(() => _photo = file);
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Item name and location are required.');
      return;
    }
    setState(() { _uploading = true; _error = null; });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      // 1. Write the item first (without photo) to get its auto-ID
      final itemId = await _itemService.addItem(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        status: _isLost ? 'lost' : 'found',
        category: _selectedCategory ?? 'Others',
        reportedByUid: user.uid,
        reportedByName: user.displayName ?? 'Anonymous',
        date: _selectedDate,
      );

      // 2. If the user attached a photo, upload it and patch the URL back
      if (_photo != null) {
        final url = await _storageService.uploadItemPhoto(
          file: _photo!,
          itemId: itemId,
        );
        await _itemService._db               // small patch — keep service clean
            .collection('items')
            .doc(itemId)
            .update({'photoUrl': url});
      }

      if (mounted) {
        _showSuccess();
        _nameCtrl.clear();
        _descCtrl.clear();
        _locationCtrl.clear();
        setState(() {
          _photo = null;
          _selectedDate = null;
          _selectedCategory = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Upload failed. Please try again.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60, height: 60,
              decoration: const BoxDecoration(color: AppColors.foundBadge, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Report Submitted!', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Your report is now live. We\'ll notify you of any updates.',
                textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
        actions: [SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Report Item'), backgroundColor: AppColors.primary, automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lost / Found toggle
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
              child: Row(children: [
                Expanded(child: _toggleBtn(true, 'Lost Item')),
                Expanded(child: _toggleBtn(false, 'Found Item')),
              ]),
            ),
            const SizedBox(height: 20),

            // Error banner
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.danger.withOpacity(0.3))),
                child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              ),
              const SizedBox(height: 16),
            ],

            // Photo picker
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                clipBehavior: Clip.hardEdge,
                child: _photo != null
                    ? Stack(children: [
                        Image.file(_photo!, fit: BoxFit.cover, width: double.infinity),
                        Positioned(top: 8, right: 8, child: GestureDetector(
                          onTap: () => setState(() => _photo = null),
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        )),
                      ])
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                        Icon(Icons.camera_alt_outlined, size: 32, color: AppColors.primary),
                        SizedBox(height: 8),
                        Text('Add a photo', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        Text('(Tap to upload)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ]),
              ),
            ),
            const SizedBox(height: 20),

            _label('Item Name', required: true),
            const SizedBox(height: 6),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'e.g. Black Backpack')),
            const SizedBox(height: 16),
            _label('Category'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text('Select category'),
              decoration: InputDecoration(filled: true, fillColor: AppColors.inputFill, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider))),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
            const SizedBox(height: 16),
            _label('Description'),
            const SizedBox(height: 6),
            TextField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Add more details...')),
            const SizedBox(height: 16),
            _label('Last Seen / Found Location', required: true),
            const SizedBox(height: 6),
            TextField(controller: _locationCtrl, decoration: const InputDecoration(hintText: 'e.g. Gymnasium, Room 201', prefixIcon: Icon(Icons.location_on_outlined, size: 20))),
            const SizedBox(height: 16),
            _label('Date'),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime.now());
                if (d != null) setState(() => _selectedDate = d);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_selectedDate != null ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}' : 'Select date', style: TextStyle(color: _selectedDate != null ? AppColors.textPrimary : AppColors.textSecondary, fontSize: 14))),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                ]),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _uploading ? null : _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _uploading
                    ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                        SizedBox(width: 12),
                        Text('Uploading...'),
                      ])
                    : const Text('Submit Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(bool isLost, String label) {
    final isActive = _isLost == isLost;
    return GestureDetector(
      onTap: () => setState(() => _isLost = isLost),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? (isLost ? AppColors.lostBadge : AppColors.foundBadge) : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );
  }

  Widget _label(String text, {bool required = false}) => Row(children: [
    Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
    if (required) const Text(' *', style: TextStyle(color: AppColors.danger)),
  ]);
}
