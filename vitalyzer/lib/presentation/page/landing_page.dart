import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/presentation/page/login_page.dart';
import 'package:vitalyzer/presentation/page/register_page.dart';
import 'package:vitalyzer/presentation/page/user_info_fill_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool userHasFilled = false;

  @override
  void initState() {
    super.initState();
    _loadSharedPrefs();
  }

  Future<void> _loadSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userHasFilled = prefs.getBool('userHasFilledInfoForm') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.beige,
      body: Padding(
        padding:
            const EdgeInsets.only(top: 50, bottom: 25, right: 25, left: 25),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              const Spacer(flex: 10),
              Container(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: Get.width * 0.3,
                  width: Get.width * 0.3,
                  decoration: BoxDecoration(
                    color: ColorPalette.lightGreen.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorPalette.darkGreen,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: IconButton(
                      onPressed: null,
                      enableFeedback: false,
                      icon: Icon(
                        Icons.health_and_safety,
                        size: Get.width * 0.2,
                        color: ColorPalette.green,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1),
              Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Vitalize Your Health\nwith\nSmart Analysis',
                  style: TextStyle(
                    color: ColorPalette.darkGreen,
                    fontSize: 25,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: userHasFilled
                        ? () async => await Get.to(() => const RegisterPage())
                        : () async =>
                            await Get.to(() => const UserInfoFillPage()),
                    style: ButtonStyle(
                      backgroundColor:
                          const WidgetStatePropertyAll(ColorPalette.green),
                      fixedSize: WidgetStatePropertyAll(
                          Size.fromWidth(Get.width * 0.5)),
                    ),
                    child: const Text(
                      'Start Now',
                      style: TextStyle(
                        color: ColorPalette.beige,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async =>
                        await Get.to(() => const LoginPage()),
                    child: Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: ColorPalette.green.withOpacity(0.75),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
