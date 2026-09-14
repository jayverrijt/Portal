import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class PastebinWidget extends StatelessWidget {
  const PastebinWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NordColors.polarNight1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NordColors.polarNight2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Pastebin",
                style: TextStyle(
                  color: NordColors.snowStorm2,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.notes, color: NordColors.frost1),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 4,
            style: const TextStyle(color: NordColors.snowStorm0),
            decoration: InputDecoration(
              hintText: "Type or paste your snippet here...",
              hintStyle: const TextStyle(color: NordColors.polarNight3),
              filled: true,
              fillColor: NordColors.polarNight0,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NordColors.green,
                foregroundColor: NordColors.polarNight0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Create Paste",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}