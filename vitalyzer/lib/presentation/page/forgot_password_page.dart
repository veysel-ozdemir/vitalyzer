import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/service/auth_service.dart';
import 'package:vitalyzer/util/extension.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email address',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      if (mounted) {
        Get.back(); // Return to login page after successful email send
      }
    } catch (e) {
      debugPrint('Error sending reset password email: $e');
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
      appBar: AppBar(
        backgroundColor: ColorPalette.beige,
        foregroundColor: ColorPalette.green,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
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
                      Icons.lock_reset,
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
                'Reset Password',
                style: TextStyle(
                  color: ColorPalette.darkGreen,
                  fontSize: 25,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 25, right: 25, bottom: 25),
              child: Text(
                'Enter your email address and we will send you instructions to reset your password.',
                style: TextStyle(
                  color: ColorPalette.darkGreen,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
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
            const Spacer(flex: 4),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ButtonStyle(
                backgroundColor:
                    const WidgetStatePropertyAll(ColorPalette.green),
                fixedSize: WidgetStatePropertyAll(
                  Size.fromWidth(deviceSize.width * 0.5),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: ColorPalette.beige)
                  : const Text(
                      'Send Reset Link',
                      style: TextStyle(
                        color: ColorPalette.beige,
                      ),
                    ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
