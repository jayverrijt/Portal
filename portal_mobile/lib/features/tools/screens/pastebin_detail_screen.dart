import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/nord_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../budget/providers/budget_provider.dart';

// Definieer of importeer hier de apiClientProvider indien deze elders staat.
// (Controleer of jouw api client provider hier correct wordt ingeladen)

// Provider om de pastebin buffer op te halen van de API (/api/Pastebin)
final pastebinProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final res = await client.dio.get('/Pastebin');
    if (res.statusCode == 200 && res.data is Map) {
      return res.data as Map<String, dynamic>;
    }
  } catch (e) {
    debugPrint('Fout bij ophalen pastebin: $e');
  }
  return {'content': '', 'updatedAt': DateTime.now().toIso8601String()};
});

class PastebinDetailScreen extends ConsumerStatefulWidget {
  const PastebinDetailScreen({super.key});

  @override
  ConsumerState<PastebinDetailScreen> createState() => _PastebinDetailScreenState();
}

class _PastebinDetailScreenState extends ConsumerState<PastebinDetailScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  bool _isInitialized = false;

  Future<void> _savePaste(String content) async {
    setState(() => _isLoading = true);
    try {
      final client = ref.read(apiClientProvider);
      // POST naar /api/Pastebin overeenkomstig met je ASP.NET Controller [HttpPost] Save([FromBody] PastebinDto dto)
      await client.dio.post('/Pastebin', data: {'content': content});
      ref.invalidate(pastebinProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pastebin buffer succesvol opgeslagen')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout bij opslaan: $e'), backgroundColor: NordColors.nord11),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pasteAsync = ref.watch(pastebinProvider);

    return Scaffold(
      backgroundColor: NordColors.nord0,
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        title: const Text('Pastebin Buffer', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: NordColors.nord6),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: NordColors.nord4),
            tooltip: 'Vernieuwen',
            onPressed: () => ref.refresh(pastebinProvider),
          ),
        ],
      ),
      body: pasteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: NordColors.nord8)),
        error: (err, _) => Center(child: Text('Fout bij laden: $err', style: const TextStyle(color: NordColors.nord11))),
        data: (data) {
          final content = data['content'] ?? '';
          final updatedAtStr = data['updatedAt'];

          // Initialiseer de controller eenmalig met de data van de server
          if (!_isInitialized) {
            _controller.text = content;
            _isInitialized = true;
          }

          DateTime? updatedAt;
          if (updatedAtStr != null) {
            updatedAt = DateTime.tryParse(updatedAtStr)?.toLocal();
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Laatst bijgewerkt badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: NordColors.nord1,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NordColors.nord2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Laatst bijgewerkt:', style: TextStyle(color: NordColors.nord4, fontSize: 12)),
                      Text(
                        updatedAt != null ? DateFormat('dd MMM yyyy - HH:mm').format(updatedAt) : 'Onbekend',
                        style: const TextStyle(color: NordColors.nord8, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Hoofd-editor container
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: NordColors.nord1,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: NordColors.nord2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            maxLines: null,
                            expands: true,
                            style: const TextStyle(color: NordColors.nord6, fontFamily: 'monospace', fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Type or paste your snippet here...',
                              hintStyle: const TextStyle(color: NordColors.nord3),
                              filled: true,
                              fillColor: NordColors.nord0,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NordColors.nord14,
                              foregroundColor: NordColors.nord0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: _isLoading
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: NordColors.nord0))
                                : const Icon(Icons.save_outlined, size: 18),
                            label: Text(_isLoading ? 'Bezig met opslaan...' : 'Buffer Opslaan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            onPressed: _isLoading ? null : () => _savePaste(_controller.text),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}