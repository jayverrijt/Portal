import 'package:flutter/material.dart';
import '../theme/nord_theme.dart';

class PortalLogo extends StatelessWidget {
  final double size;
  final double iconSize;

  const PortalLogo({
    super.key,
    this.size = 72,
    this.iconSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: NordColors.nord1, // #3B4252
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.bolt,
          color: NordColors.nord13, // #EBCB8B (Nord Yellow)
          size: iconSize,
        ),
      ),
    );
  }
}