import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/presentation/page/home_page.dart';
import 'package:vitalyzer/presentation/page/register_page.dart';
import 'package:vitalyzer/presentation/page/user_info_fill_page.dart';
import 'package:vitalyzer/util/extension.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final bool _userHasFilled = false;
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _toggleVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = context.deviceSize;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorPalette.beige,
      body: Padding(
        padding:
            const EdgeInsets.only(top: 50, bottom: 25, right: 25, left: 25),
        child: Column(
          children: [
            const Spacer(flex: 1),
            Container(
              alignment: Alignment.center,
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
                  size: deviceSize.height * 0.05,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(25),
              child: Text(
                'Welcome back!',
                style: TextStyle(
                  color: ColorPalette.darkGreen,
                  fontSize: 25,
                ),
              ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
              child: TextFormField(
                controller: _emailController,
                style: const TextStyle(
                  color: ColorPalette.darkGreen,
                ),
                cursorColor: ColorPalette.green,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter email',
                  hintStyle: TextStyle(
                    color: ColorPalette.green.withOpacity(0.75),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: ColorPalette.green,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: ColorPalette.green,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: TextFormField(
                controller: _passwordController,
                style: const TextStyle(
                  color: ColorPalette.darkGreen,
                ),
                cursorColor: ColorPalette.green,
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  hintStyle: TextStyle(
                    color: ColorPalette.green.withOpacity(0.75),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: _toggleVisibility,
                  ),
                  suffixIconColor: ColorPalette.green,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: ColorPalette.green,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: ColorPalette.green,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Forgot the password?',
                style: TextStyle(
                  color: ColorPalette.green.withOpacity(0.75),
                ),
              ),
            ),
            const Spacer(flex: 1),
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                width: deviceSize.width,
                height: deviceSize.height * 0.15,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: ColorPalette.green,
                    width: 3,
                  ),
                ),
                child: const Text('Illustration'),
              ),
            ),
            const Spacer(flex: 1),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () async => await Get.offAll(const HomePage()),
                  style: ButtonStyle(
                    backgroundColor:
                        const WidgetStatePropertyAll(ColorPalette.green),
                    fixedSize: WidgetStatePropertyAll(
                        Size.fromWidth(deviceSize.width * 0.5)),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: ColorPalette.beige,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async => _userHasFilled
                      ? await Get.off(() => const RegisterPage())
                      : await Get.off(() => const UserInfoFillPage()),
                  child: Text(
                    "Don't you have an account?",
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
    );
  }
}
