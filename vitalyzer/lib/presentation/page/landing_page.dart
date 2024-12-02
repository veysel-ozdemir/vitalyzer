import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/presentation/page/login_page.dart';
import 'package:vitalyzer/presentation/page/register_page.dart';
import 'package:vitalyzer/presentation/page/user_info_fill_page.dart';
import 'package:vitalyzer/util/extension.dart';

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

    // todo: this line is for testing, delete it later
    await prefs.clear();

    setState(() {
      userHasFilled = prefs.getBool('userHasFilledInfoForm') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = context.deviceSize;

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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorPalette.green,
                      width: 3,
                    ),
                  ),
                  child: FlutterLogo(
                    size: deviceSize.height * 0.1,
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
                          Size.fromWidth(deviceSize.width * 0.5)),
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
