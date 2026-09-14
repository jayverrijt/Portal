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

  // HCD-vriendelijke bottom sheet voor het loggen van gewicht
  void _showAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NordColors.nord1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
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
                        Icon(Icons.monitor_weight_outlined, color: NordColors.nord8, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Gewicht Loggen',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Ochtend')),
                        selected: _selectedSession == 'Ochtend',
                        selectedColor: NordColors.nord13.withValues(alpha: 0.3),
                        backgroundColor: NordColors.nord0,
                        labelStyle: TextStyle(
                          color: _selectedSession == 'Ochtend' ? NordColors.nord13 : NordColors.nord4,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (selected) {
                          setSheetState(() => _selectedSession = 'Ochtend');
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Avond')),
                        selected: _selectedSession == 'Avond',
                        selectedColor: NordColors.nord9.withValues(alpha: 0.3),
                        backgroundColor: NordColors.nord0,
                        labelStyle: TextStyle(
                          color: _selectedSession == 'Avond' ? NordColors.nord9 : NordColors.nord4,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (selected) {
                          setSheetState(() => _selectedSession = 'Avond');
                          setState(() {});
                        },
                      ),
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
                    labelText: 'Gewicht in kg (bijv. 80.5)',
                    labelStyle: const TextStyle(color: NordColors.nord4),
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
                          backgroundColor: NordColors.nord8,
                          foregroundColor: NordColors.nord0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _addWeight,
                        child: const Text('Opslaan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        onPressed: _showAddBottomSheet,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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

class WeightChartPainter extends CustomPainter {
  final List<WeightEntry> entries;

  WeightChartPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final paintLine = Paint()
      ..color = NordColors.nord13
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintPoint = Paint()
      ..color = NordColors.nord13
      ..style = PaintingStyle.fill;

    final paintGrid = Paint()
      ..color = NordColors.nord2.withValues(alpha: 0.4)
      ..strokeWidth = 1;

    double minW = entries.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 1;
    double maxW = entries.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 1;
    if (minW == maxW) {
      minW -= 2;
      maxW += 2;
    }

    const steps = 4;
    for (int i = 0; i <= steps; i++) {
      double y = size.height / steps * i;
      canvas.drawLine(Offset(30, y), Offset(size.width, y), paintGrid);

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

    canvas.drawPath(path, paintLine);

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 4, paintPoint);

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