import 'package:flutter/material.dart';

class GridItem extends StatefulWidget {
  final int index;
  final bool isPressed; // Initial pressed state
  final void Function(bool isPressed) onToggle; // Callback function

  const GridItem(
      {super.key,
      required this.index,
      required this.onToggle,
      required this.isPressed});

  @override
  State<GridItem> createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  late bool isPressed;

  @override
  void initState() {
    super.initState();
    isPressed = widget.isPressed; // Initialize state
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isPressed = !isPressed; // Toggle pressed state
        });
        widget.onToggle(isPressed); // Notify parent about the change
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200), // Smooth transition
        opacity: isPressed ? 1.0 : 0.5, // Increase opacity if pressed
        child: Image.asset('assets/illustrations/water-bottle.png'),
      ),
    );
  }
}
