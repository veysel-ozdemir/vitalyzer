import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/controller/permission_controller.dart';
import 'package:vitalyzer/controller/user_nutrition_controller.dart';
import 'package:vitalyzer/controller/user_profile_controller.dart';
import 'package:vitalyzer/model/user_nutrition.dart';
import 'package:vitalyzer/model/user_profile.dart';
import 'package:vitalyzer/presentation/page/home_page.dart';
import 'package:vitalyzer/presentation/page/login_page.dart';
import 'package:vitalyzer/util/extension.dart';
import 'package:vitalyzer/service/auth_service.dart';
import 'package:vitalyzer/util/funtions.dart';

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
  final ImagePicker _imagePicker = ImagePicker();
  XFile? image;
  final PermissionController permissionController = Get.find();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  final UserProfileController userProfileController = Get.find();
  final UserNutritionController userNutritionController = Get.find();
  late SharedPreferences prefs;

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Sign up in Firebase
      UserCredential? userCredential = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text,
        image: image,
      );

      // If successfully signed up in Firebase
      if (userCredential != null && userCredential.user != null) {
        debugPrint('Successfully signed up in Firebase!');

        // Store the user firebase uid for current session
        await prefs.setString('userFirebaseUid', userCredential.user!.uid);

        Uint8List? uint8ListImage;

        if (image != null) {
          // Convert the image to bytes
          uint8ListImage = await convertXFileToUint8List(image!);
        }

        UserProfile userProfile = UserProfile(
            firebaseUserUid: userCredential.user!.uid,
            fullName: _nameController.text,
            email: _emailController.text.trim(),
            profilePhoto: uint8ListImage,
            height: prefs.getInt('userHeight') ?? -1,
            weight: prefs.getDouble('userWeight') ?? -1,
            age: prefs.getInt('userAge') ?? -1,
            gender: prefs.getString('userSex') ?? 'Not defined',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now());

        // Create user profile locally
        await userProfileController.createUserProfile(userProfile);
        debugPrint(
            'Created profile with Firebase UID: ${userProfile.firebaseUserUid}');

        // Load the current profile by Firebase UID
        await userProfileController.loadUserProfile(userCredential.user!.uid);
        debugPrint(
            'Loaded profile: ${userProfileController.currentProfile.value?.firebaseUserUid}');

        // Get the current user profile
        UserProfile? currentProfile =
            userProfileController.currentProfile.value;

        // If successfully created local user profile
        if (currentProfile != null) {
          debugPrint('Successfully created local user profile!');

          // Store the user profile id for current session
          await prefs.setInt('userProfileId', currentProfile.userId!);

          UserNutrition userNutrition = UserNutrition(
              userId: currentProfile.userId!,
              date: DateTime.parse(
                  DateFormat('yyyy-MM-dd').format(DateTime.now())),
              gainedCarbsCalorie: 0.0,
              gainedProteinCalorie: 0.0,
              gainedFatCalorie: 0.0,
              gainedCarbsGram: 0.0,
              gainedProteinGram: 0.0,
              gainedFatGram: 0.0,
              consumedWater: 0.0,
              waterLimit: prefs.getDouble('dailyWaterLimit')!,
              carbsGramLimit: prefs.getDouble('carbsGramLimit')!,
              proteinGramLimit: prefs.getDouble('proteinGramLimit')!,
              fatGramLimit: prefs.getDouble('fatGramLimit')!,
              carbsCalorieLimit: prefs.getDouble('carbsCalorieLimit')!,
              proteinCalorieLimit: prefs.getDouble('proteinCalorieLimit')!,
              fatCalorieLimit: prefs.getDouble('fatCalorieLimit')!,
              bmiLevel: prefs.getDouble('bodyMassIndexLevel')!,
              bmiAdvice: prefs.getString('bmiAdvice'));

          // Create user nutrition locally
          userNutritionController.createUserNutrition(userNutrition);

          debugPrint('Successfully created local user nutrition!');

          await prefs.setBool('hasActiveSession', true);
          await Get.offAll(() => const HomePage());
        } else {
          throw Exception(
              'Could not sign up in Firebase. Cancelled other operations!');
        }
      }
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
              onPressed: () async => await _pickImage(context),
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
                  onPressed: _isLoading ? null : _handleRegister,
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

  Future<void> _pickImage(BuildContext context) async {
    final isGranted = await permissionController.checkPhotoLibraryPermission();

    if (isGranted) {
      final selectedImage =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        image = selectedImage;
      });

      if (image != null) {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                backgroundColor: ColorPalette.beige,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(
                    width: 3,
                    color: ColorPalette.lightGreen,
                  ),
                ),
                title: const Text(
                  'Selected Image',
                  style: TextStyle(color: ColorPalette.darkGreen),
                ),
                content: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(image!.path),
                    fit: BoxFit.cover,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Ok',
                      style: TextStyle(color: ColorPalette.darkGreen),
                    ),
                  ),
                ],
              );
            },
          );
        }
      } else {
        if (context.mounted) {
          showModalBottomSheet(
            context: context,
            backgroundColor: ColorPalette.beige,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              side: BorderSide(
                color: ColorPalette.lightGreen,
                width: 3,
              ),
            ),
            builder: (context) {
              return SizedBox(
                height: Get.height * 0.25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Access to the photo library is required to select and upload your profile photo.',
                      style: TextStyle(color: ColorPalette.green),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () async =>
                          await permissionController.openSettings(),
                      child: const Text(
                        'Go to settings',
                        style: TextStyle(
                          color: ColorPalette.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        }
      }
    }
  }
}
