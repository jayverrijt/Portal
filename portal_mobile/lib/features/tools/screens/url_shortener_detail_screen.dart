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
    }
  }

  void _deleteUrl(String id) {
    setState(() {
      _urls.removeWhere((u) => u.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NordColors.nord0,
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        title: const Text('URL Shortener', style: TextStyle(color: NordColors.nord6)),
        iconTheme: const IconThemeData(color: NordColors.nord6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Invoer Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NordColors.nord1,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: NordColors.nord2),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _urlController,
                    style: const TextStyle(color: NordColors.nord6),
                    decoration: InputDecoration(
                      hintText: 'Plak lange URL hier...',
                      hintStyle: const TextStyle(color: NordColors.nord3),
                      filled: true,
                      fillColor: NordColors.nord0,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NordColors.nord9,
                        foregroundColor: NordColors.nord6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _shortenUrl,
                      child: const Text('Verkort URL'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
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
                          onPressed: () => _deleteUrl(item.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}