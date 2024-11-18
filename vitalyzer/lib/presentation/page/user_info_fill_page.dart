import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/presentation/page/register_page.dart';
import 'package:vitalyzer/presentation/widget/user_info_container.dart';
import 'package:vitalyzer/util/extension.dart';

class UserInfoFillPage extends StatefulWidget {
  const UserInfoFillPage({super.key});

  @override
  State<UserInfoFillPage> createState() => _UserInfoFillPageState();
}

class _UserInfoFillPageState extends State<UserInfoFillPage> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = context.deviceSize;

    return Scaffold(
      backgroundColor: ColorPalette.beige,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding:
            const EdgeInsets.only(top: 50, bottom: 25, right: 25, left: 25),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: ColorPalette.darkGreen,
                  ),
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorPalette.lightGreen.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorPalette.lightGreen,
                      width: 3,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.person,
                      color: ColorPalette.green,
                      size: 40,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    'About you',
                    style: TextStyle(
                      color: ColorPalette.darkGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  'This information will be used to calculate your target calories, will be stored on your device and will not be shared with third parties.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorPalette.darkGreen,
                  ),
                )
              ],
            ),
            const Spacer(flex: 1),
            const UserInfoContainer(text: 'Sex', icon: Icons.people_alt),
            const UserInfoContainer(text: 'Age', icon: Icons.cake),
            const UserInfoContainer(text: 'Height', icon: Icons.height),
            const UserInfoContainer(text: 'Weight', icon: Icons.scale),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: ElevatedButton(
                onPressed: () async =>
                    await Get.off(() => const RegisterPage()),
                style: ButtonStyle(
                  fixedSize: WidgetStatePropertyAll(
                      Size.fromWidth(deviceSize.width * 0.5)),
                  backgroundColor:
                      const WidgetStatePropertyAll(ColorPalette.green),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: ColorPalette.beige,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
