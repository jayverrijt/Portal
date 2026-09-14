import 'package:flutter/material.dart';
import '../../../core/theme/nord_theme.dart';

class ShortUrl {
  final String id;
  final String original;
  final String shortCode;

  ShortUrl({required this.id, required this.original, required this.shortCode});
}

class UrlShortenerDetailScreen extends StatefulWidget {
  const UrlShortenerDetailScreen({super.key});

  @override
  State<UrlShortenerDetailScreen> createState() => _UrlShortenerDetailScreenState();
}

class _UrlShortenerDetailScreenState extends State<UrlShortenerDetailScreen> {
  final List<ShortUrl> _urls = [
    ShortUrl(id: '1', original: 'https://github.com/jayverrijt/Portal', shortCode: 'portal.ly/xyz1'),
  ];

  final _urlController = TextEditingController();

  void _shortenUrl() {
    final text = _urlController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _urls.add(ShortUrl(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          original: text,
          shortCode: 'portal.ly/${text.hashCode.abs().toRadixString(36).substring(0, 4)}',
        ));
        _urlController.clear();
      });
      Navigator.of(context).pop();
    }
  }

  void _deleteUrl(String id) {
    setState(() {
      _urls.removeWhere((u) => u.id == id);
    });
  }

  // HCD-vriendelijke bottom sheet voor het verkorten van een URL
  void _showAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NordColors.nord1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.link, color: NordColors.nord9, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'URL Verkorten',
                        style: TextStyle(
                          color: NordColors.nord6,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: NordColors.nord4),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                autofocus: true,
                style: const TextStyle(color: NordColors.nord6),
                decoration: InputDecoration(
                  hintText: 'Plak lange URL hier...',
                  hintStyle: const TextStyle(color: NordColors.nord3),
                  filled: true,
                  fillColor: NordColors.nord0,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: NordColors.nord2,
                        foregroundColor: NordColors.nord6,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Annuleren'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NordColors.nord9,
                        foregroundColor: NordColors.nord0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _shortenUrl,
                      child: const Text('Verkorten', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HCD-vriendelijke bevestigingssheet voor verwijderen
  void _confirmDeleteUrl(BuildContext context, String id, String shortCode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NordColors.nord1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: NordColors.nord11, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'URL Verwijderen',
                      style: TextStyle(
                        color: NordColors.nord6,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: NordColors.nord4),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Weet je zeker dat je "$shortCode" wilt verwijderen?',
              style: const TextStyle(color: NordColors.nord4, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: NordColors.nord2,
                      foregroundColor: NordColors.nord6,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Annuleren'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NordColors.nord11,
                      foregroundColor: NordColors.nord6,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _deleteUrl(id);
                    },
                    child: const Text('Verwijderen', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NordColors.nord0,
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        title: const Text('URL Shortener', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: NordColors.nord6),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: NordColors.nord9,
        foregroundColor: NordColors.nord0,
        onPressed: _showAddBottomSheet,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: _urls.length,
          itemBuilder: (context, index) {
            final item = _urls[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: NordColors.nord1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: NordColors.nord2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, color: NordColors.nord9),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.shortCode, style: const TextStyle(color: NordColors.nord8, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(item.original, style: const TextStyle(color: NordColors.nord4, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: NordColors.nord11),
                    onPressed: () => _confirmDeleteUrl(context, item.id, item.shortCode),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}