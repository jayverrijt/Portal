import 'package:flutter/material.dart';
import '../../../core/theme/nord_theme.dart';

class PasteItem {
  final String id;
  final String content;
  final DateTime createdAt;

  PasteItem({required this.id, required this.content, required this.createdAt});
}

class PastebinDetailScreen extends StatefulWidget {
  const PastebinDetailScreen({super.key});

  @override
  State<PastebinDetailScreen> createState() => _PastebinDetailScreenState();
}

class _PastebinDetailScreenState extends State<PastebinDetailScreen> {
  final List<PasteItem> _pastes = [
    PasteItem(id: '1', content: 'docker-compose up -d --build', createdAt: DateTime.now()),
  ];

  final _pasteController = TextEditingController();

  void _createPaste() {
    final text = _pasteController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _pastes.add(PasteItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: text,
          createdAt: DateTime.now(),
        ));
        _pasteController.clear();
      });
    }
  }

  void _deletePaste(String id) {
    setState(() {
      _pastes.removeWhere((p) => p.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NordColors.nord0,
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        title: const Text('Pastebin', style: TextStyle(color: NordColors.nord6)),
        iconTheme: const IconThemeData(color: NordColors.nord6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                    controller: _pasteController,
                    maxLines: 3,
                    style: const TextStyle(color: NordColors.nord6),
                    decoration: InputDecoration(
                      hintText: 'Typ of plak je snippet hier...',
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
                        backgroundColor: NordColors.nord14,
                        foregroundColor: NordColors.nord0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _createPaste,
                      child: const Text('Create Paste', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _pastes.length,
                itemBuilder: (context, index) {
                  final paste = _pastes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: NordColors.nord1,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: NordColors.nord2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Snippet #${paste.id.substring(paste.id.length - 4)}', style: const TextStyle(color: NordColors.nord8, fontSize: 12)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: NordColors.nord11, size: 18),
                              onPressed: () => _deletePaste(paste.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          paste.content,
                          style: const TextStyle(color: NordColors.nord5, fontFamily: 'monospace'),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
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