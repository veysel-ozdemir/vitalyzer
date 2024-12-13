import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vitalyzer/const/color_palette.dart';

class UserInfoItem extends StatefulWidget {
  final String text;
  final IconData icon;
  final Object? buttonText;
  final String? unit;
  final void Function()? onTap;

  const UserInfoItem({
    super.key,
    required this.text,
    required this.icon,
    required this.buttonText,
    required this.unit,
    required this.onTap,
  });

  @override
  State<UserInfoItem> createState() => _UserInfoContainerState();
}

class _UserInfoContainerState extends State<UserInfoItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Container(
        width: Get.width * 0.55,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorPalette.green,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
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
              onTap: widget.onTap,
              child: Row(
                children: [
                  Text(
                    widget.buttonText != null
                        ? (widget.unit != null
                                ? "${widget.buttonText.toString()} ${widget.unit}"
                                : widget.buttonText)
                            .toString()
                        : 'Select',
                    style: const TextStyle(
                      color: ColorPalette.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
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
