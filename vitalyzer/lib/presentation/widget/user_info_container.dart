import 'package:flutter/material.dart';
import 'package:vitalyzer/const/color_palette.dart';

class UserInfoContainer extends StatefulWidget {
  final String text;
  final IconData icon;

  const UserInfoContainer({super.key, required this.text, required this.icon});

  @override
  State<UserInfoContainer> createState() => _UserInfoContainerState();
}

class _UserInfoContainerState extends State<UserInfoContainer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorPalette.lightGreen,
            width: 3,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          color: ColorPalette.lightGreen.withOpacity(0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  widget.icon,
                  color: ColorPalette.green,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.text,
                  style: const TextStyle(
                    color: ColorPalette.darkGreen,
                  ),
                )
              ],
            ),
            InkWell(
              onTap: () {},
              child: const Row(
                children: [
                  Text(
                    'Select',
                    style: TextStyle(
                      color: ColorPalette.green,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: ColorPalette.green,
                    size: 16,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
