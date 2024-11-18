import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/presentation/page/home_page.dart';
import 'package:vitalyzer/presentation/page/login_page.dart';
import 'package:vitalyzer/util/extension.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;

  void _toggleVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.all(25),
              child: TextFormField(
                controller: _nameController,
                style: const TextStyle(
                  color: ColorPalette.darkGreen,
                ),
                cursorColor: ColorPalette.green,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
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
              padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
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
                  hintText: 'Create password',
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
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
              child: TextFormField(
                controller: _confirmPasswordController,
                style: const TextStyle(
                  color: ColorPalette.darkGreen,
                ),
                cursorColor: ColorPalette.green,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Confirm password',
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
            ElevatedButton(
              onPressed: () {},
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                side: WidgetStatePropertyAll(
                  BorderSide(
                    color: ColorPalette.green,
                    width: 2,
                  ),
                ),
              ),
              child: const Icon(
                Icons.cloud_upload,
                color: ColorPalette.green,
                size: 30,
              ),
            ),
            Text(
              'Upload profile photo',
              style: TextStyle(
                color: ColorPalette.green.withOpacity(0.75),
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
            Column(
              children: [
                ElevatedButton(
                  onPressed: () async =>
                      await Get.offAll(() => const HomePage()),
                  style: ButtonStyle(
                    backgroundColor:
                        const WidgetStatePropertyAll(ColorPalette.green),
                    fixedSize: WidgetStatePropertyAll(
                        Size.fromWidth(deviceSize.width * 0.5)),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: ColorPalette.beige,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async => await Get.off(() => const LoginPage()),
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
    );
  }
}
