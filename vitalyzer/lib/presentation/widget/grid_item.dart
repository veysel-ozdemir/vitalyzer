import 'package:flutter/material.dart';

class GridItem extends StatefulWidget {
  final int index;

  const GridItem({super.key, required this.index});

  @override
  State<GridItem> createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isPressed = !isPressed; // Toggle pressed state
        });
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200), // Smooth transition
        opacity: isPressed ? 1.0 : 0.5, // Increase opacity if pressed
        child: Image.asset('assets/illustrations/water-bottle.png'),
      ),
    );
  }
}
