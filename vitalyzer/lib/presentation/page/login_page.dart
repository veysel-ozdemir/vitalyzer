import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/controller/user_nutrition_controller.dart';
import 'package:vitalyzer/controller/user_profile_controller.dart';
import 'package:vitalyzer/presentation/page/home_page.dart';
import 'package:vitalyzer/presentation/page/register_page.dart';
import 'package:vitalyzer/presentation/page/user_info_fill_page.dart';
import 'package:vitalyzer/util/extension.dart';
import 'package:vitalyzer/service/auth_service.dart';
import 'package:vitalyzer/util/funtions.dart';
import 'package:vitalyzer/presentation/page/forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool userHasFilled = false;
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  late SharedPreferences prefs;
  final UserProfileController userProfileController = Get.find();
  final UserNutritionController userNutritionController = Get.find();

  void _toggleVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSharedPrefs();
  }

  Future<void> _loadSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      userHasFilled = prefs.getBool('userHasFilledInfoForm') ?? false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      debugPrint('\nShared Prefs before sign in:');
      printKeyValueOfSharedPrefs(prefs);

      UserCredential userCredential = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      debugPrint('Authenticated user uid: ${userCredential.user!.uid}');
      debugPrint('Authenticated user email: ${userCredential.user!.email}');

      debugPrint('\nShared Prefs after sign in:');
      printKeyValueOfSharedPrefs(prefs);

      // Initialize user data after successful login
      await _authService.initializeUserData(userCredential);

      await prefs.setBool('hasActiveSession', true);

      debugPrint('\nShared Prefs before home:');
      printKeyValueOfSharedPrefs(prefs);
      await Get.offAll(() => const HomePage());
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
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
                height: Get.width * 0.25,
                width: Get.width * 0.25,
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
                      size: Get.width * 0.175,
                      color: ColorPalette.green,
                    ),
                  ),
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
              onPressed: () async =>
                  await Get.to(() => const ForgotPasswordPage()),
              child: Text(
                'Forgot the password?',
                style: TextStyle(
                  color: ColorPalette.green.withOpacity(0.75),
                ),
              ),
            ),
            const Spacer(flex: 1),
            const Spacer(flex: 1),
            Column(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ButtonStyle(
                    backgroundColor:
                        const WidgetStatePropertyAll(ColorPalette.green),
                    fixedSize: WidgetStatePropertyAll(
                        Size.fromWidth(deviceSize.width * 0.5)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: ColorPalette.beige)
                      : const Text(
                          'Login',
                          style: TextStyle(
                            color: ColorPalette.beige,
                          ),
                        ),
                ),
                TextButton(
                  onPressed: userHasFilled
                      ? () async => await Get.off(() => const RegisterPage())
                      : () async =>
                          await Get.off(() => const UserInfoFillPage()),
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
