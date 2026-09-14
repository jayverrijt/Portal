import 'package:flutter/material.dart';
import '../../../core/theme/nord_theme.dart';

class WeightEntry {
  final String id;
  final double weight;
  final DateTime date;
  final String session; // 'Ochtend' of 'Avond'

  WeightEntry({
    required this.id,
    required this.weight,
    required this.date,
    required this.session,
  });
}

class WeightDetailScreen extends StatefulWidget {
  const WeightDetailScreen({super.key});

  @override
  State<WeightDetailScreen> createState() => _WeightDetailScreenState();
}

class _WeightDetailScreenState extends State<WeightDetailScreen> {
  String _selectedSession = 'Ochtend'; // 'Ochtend' of 'Avond'

  final List<WeightEntry> _entries = [
    WeightEntry(id: '1', weight: 82.0, date: DateTime(2026, 8, 14), session: 'Ochtend'),
    WeightEntry(id: '2', weight: 80.0, date: DateTime(2026, 9, 14), session: 'Ochtend'),
  ];

  final _weightController = TextEditingController();

  void _addWeight() {
    final val = double.tryParse(_weightController.text.replaceAll(',', '.'));
    if (val != null) {
      setState(() {
        _entries.add(WeightEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          weight: val,
          date: DateTime.now(),
          session: _selectedSession,
        ));
        _weightController.clear();
      });
      Navigator.of(context).pop();
    }
  }

  void _deleteEntry(String id) {
    setState(() {
      _entries.removeWhere((e) => e.id == id);
    });
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: NordColors.nord1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Gewicht Loggen', style: TextStyle(color: NordColors.nord6)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ochtend / Avond toggle in dialog
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Ochtend'),
                    selected: _selectedSession == 'Ochtend',
                    selectedColor: NordColors.nord13,
                    backgroundColor: NordColors.nord0,
                    labelStyle: TextStyle(
                      color: _selectedSession == 'Ochtend' ? NordColors.nord0 : NordColors.nord4,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      setDialogState(() => _selectedSession = 'Ochtend');
                      setState(() {});
                    },
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Avond'),
                    selected: _selectedSession == 'Avond',
                    selectedColor: NordColors.nord9,
                    backgroundColor: NordColors.nord0,
                    labelStyle: TextStyle(
                      color: _selectedSession == 'Avond' ? NordColors.nord0 : NordColors.nord4,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      setDialogState(() => _selectedSession = 'Avond');
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(color: NordColors.nord6),
                decoration: InputDecoration(
                  hintText: 'Bijv. 80.5',
                  hintStyle: const TextStyle(color: NordColors.nord3),
                  filled: true,
                  fillColor: NordColors.nord0,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuleren', style: TextStyle(color: NordColors.nord4)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NordColors.nord8,
                foregroundColor: NordColors.nord0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _addWeight,
              child: const Text('Opslaan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter entries op basis van geselecteerde sessie (Ochtend / Avond)
    final filteredEntries = _entries.where((e) => e.session == _selectedSession).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final latest = filteredEntries.isNotEmpty ? filteredEntries.last.weight : 0.0;

    return Scaffold(
      backgroundColor: NordColors.nord0,
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        title: const Text('Weight Tracker', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: NordColors.nord6),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: NordColors.nord8,
        foregroundColor: NordColors.nord0,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header met Ochtend / Avond Toggle exact zoals webapp
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NordColors.nord1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NordColors.nord2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Voortgangsgrafiek (kg)', style: TextStyle(color: NordColors.nord6, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Laatst: $latest kg', style: const TextStyle(color: NordColors.nord13, fontSize: 13)),
                  ],
                ),
                // Toggle Knoppen
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _selectedSession = 'Ochtend'),
                      child: Row(
                        children: [
                          Icon(Icons.wb_sunny_outlined, size: 16, color: _selectedSession == 'Ochtend' ? NordColors.nord13 : NordColors.nord4),
                          const SizedBox(width: 4),
                          Text('Ochtend', style: TextStyle(color: _selectedSession == 'Ochtend' ? NordColors.nord13 : NordColors.nord4, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => setState(() => _selectedSession = 'Avond'),
                      child: Row(
                        children: [
                          Icon(Icons.nightlight_outlined, size: 16, color: _selectedSession == 'Avond' ? NordColors.nord9 : NordColors.nord4),
                          const SizedBox(width: 4),
                          Text('Avond', style: TextStyle(color: _selectedSession == 'Avond' ? NordColors.nord9 : NordColors.nord4, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grafiek Container (Strakke lijn met punten zoals op de foto)
          Container(
            height: 240,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            decoration: BoxDecoration(
              color: NordColors.nord1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NordColors.nord2),
            ),
            child: filteredEntries.isEmpty
                ? const Center(child: Text('Geen data voor deze sessie', style: TextStyle(color: NordColors.nord3)))
                : CustomPaint(
              painter: WeightChartPainter(entries: filteredEntries),
              child: Container(),
            ),
          ),
          const SizedBox(height: 20),

          // Historie & CRUD lijst
          const Text('Metingen Beheren', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ..._entries.reversed.map((entry) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: NordColors.nord1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NordColors.nord2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      entry.session == 'Ochtend' ? Icons.wb_sunny : Icons.nightlight,
                      size: 18,
                      color: entry.session == 'Ochtend' ? NordColors.nord13 : NordColors.nord9,
                    ),
                    const SizedBox(width: 12),
                    Text('${entry.weight} kg', style: const TextStyle(color: NordColors.nord6, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Row(
                  children: [
                    Text('${entry.date.day}-${entry.date.month}-${entry.date.year}', style: const TextStyle(color: NordColors.nord4, fontSize: 12)),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: NordColors.nord11, size: 20),
                      onPressed: () => _deleteEntry(entry.id),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// Custom Painter om exact de lijn en punten te tekenen zoals in je webapp
class WeightChartPainter extends CustomPainter {
  final List<WeightEntry> entries;

  WeightChartPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final paintLine = Paint()
      ..color = NordColors.nord13 // Lichtgele/gouden accentkleur
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintPoint = Paint()
      ..color = NordColors.nord13
      ..style = PaintingStyle.fill;

    final paintGrid = Paint()
      ..color = NordColors.nord2.withValues(alpha: 0.4)
      ..strokeWidth = 1;

    // Min en Max waarden bepalen voor de Y-as schaal
    double minW = entries.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 1;
    double maxW = entries.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 1;
    if (minW == maxW) {
      minW -= 2;
      maxW += 2;
    }

    // Teken horizontale hulplijnen (grid)
    const steps = 4;
    for (int i = 0; i <= steps; i++) {
      double y = size.height / steps * i;
      canvas.drawLine(Offset(30, y), Offset(size.width, y), paintGrid);

      // Y-as labels
      double val = maxW - ((maxW - minW) / steps * i);
      final textSpan = TextSpan(
        text: val.toStringAsFixed(1),
        style: const TextStyle(color: NordColors.nord3, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < entries.length; i++) {
      double x = 40 + (i / (entries.length == 1 ? 1 : entries.length - 1)) * (size.width - 60);
      double y = size.height - ((entries[i].weight - minW) / (maxW - minW)) * (size.height - 20) - 10;
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Teken de lijn
    canvas.drawPath(path, paintLine);

    // Teken datapunten en labels boven de punten
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 4, paintPoint);

      // Waarde label boven de punt
      final textSpan = TextSpan(
        text: '${entries[i].weight.toStringAsFixed(1)}',
        style: const TextStyle(color: NordColors.nord13, fontSize: 11, fontWeight: FontWeight.bold),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(points[i].dx - 12, points[i].dy - 20));

      // Datum label onderaan
      final dateSpan = TextSpan(
        text: '${entries[i].date.day} ${_getMonthName(entries[i].date.month)}',
        style: const TextStyle(color: NordColors.nord4, fontSize: 10),
      );
      final datePainter = TextPainter(
        text: dateSpan,
        textDirection: TextDirection.ltr,
      );
      datePainter.layout();
      datePainter.paint(canvas, Offset(points[i].dx - 15, size.height + 4));
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}