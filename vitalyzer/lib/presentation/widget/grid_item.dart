import 'package:flutter/material.dart';

class GridItem extends StatelessWidget {
  final int index;
  final bool isPressed; // Initial pressed state
  final void Function(bool isPressed) onToggle; // Callback function

  const GridItem({
    super.key,
    required this.index,
    required this.onToggle,
    required this.isPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onToggle(!isPressed); // Notify parent about the change
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200), // Smooth transition
        opacity: isPressed ? 1.0 : 0.5, // Increase opacity if pressed
        child: Image.asset('assets/illustrations/water-bottle.png'),
      ),
    );
  }
}
