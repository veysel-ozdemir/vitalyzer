import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/model/user_nutrition.dart';
import 'package:vitalyzer/model/user_profile.dart';
import 'package:vitalyzer/presentation/page/landing_page.dart';
import 'package:vitalyzer/presentation/page/user_info_fill_page.dart';
import 'package:vitalyzer/service/nutrition_storage_service.dart';
import 'package:vitalyzer/util/funtions.dart';
import 'package:vitalyzer/controller/user_profile_controller.dart';
import 'package:vitalyzer/controller/user_nutrition_controller.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final userProfileController = Get.find<UserProfileController>();
  final userNutritionController = Get.find<UserNutritionController>();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign Up
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String fullName,
    XFile? image,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        String? profilePhotoUrl;

        if (image != null) {
          // Upload to Firebase Storage
          final storageRef = _storage.ref().child('profile_photos').child(
              '${userCredential.user!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

          try {
            await storageRef.putFile(File(image.path));
            profilePhotoUrl = await storageRef.getDownloadURL();
          } catch (e) {
            Get.snackbar(
              'Error',
              'Failed to upload image $e',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            debugPrint('Failed to upload image: $e');
          }
        }

        // Store additional user data in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': fullName,
          'email': email,
          'profilePhotoUrl': profilePhotoUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> initializeUserData(UserCredential userCredential) async {
    final prefs = await SharedPreferences.getInstance();

    // Store Firebase UID
    await prefs.setString('userFirebaseUid', userCredential.user!.uid);

    // Get user profile from local database
    await userProfileController.loadUserProfile(userCredential.user!.uid);

    final userProfile = userProfileController.currentProfile.value;
    if (userProfile != null) {
      // Store user profile ID
      await prefs.setInt('userProfileId', userProfile.userId!);

      // Initialize nutrition data
      await userNutritionController
          .initializeUserNutritionData(userProfile.userId!);
    } else {
      debugPrint('User profile not found');

      if (prefs.get('userHasFilledInfoForm') == false) {
        Get.snackbar(
          'Note:',
          'You have to provide your physical attributes in order to login in this device.',
          backgroundColor: ColorPalette.beige,
          colorText: ColorPalette.darkGreen,
        );
        await Get.to(() => const UserInfoFillPage());
      }

      Map<String, dynamic>? map;

      /// Fetch user data by UID from the 'users' collection
      DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        debugPrint('User document found');
        map = userDoc.data();
      } else {
        debugPrint('User document does not exist!');
        await Get.offAll(() => const LandingPage());
      }

      String? fullName = map!['fullName'];
      debugPrint(fullName);
      String? imagePath = map['profilePhotoUrl'];
      debugPrint(imagePath);
      Uint8List? uint8ListImage;
      if (imagePath != null) {
        // Fetch the image from the URL
        final http.Response response = await http.get(Uri.parse(imagePath));

        // Check if the response is successful
        if (response.statusCode == 200) {
          // Convert the image data into bytes
          uint8ListImage = response.bodyBytes;
        }

        UserProfile userProfile = UserProfile(
            firebaseUserUid: userCredential.user!.uid,
            fullName: fullName!,
            email: userCredential.user!.email!,
            profilePhoto: uint8ListImage,
            height: prefs.getInt('userHeight') ?? 170,
            weight: prefs.getDouble('userWeight') ?? 70.0,
            age: prefs.getInt('userAge') ?? 35,
            gender: prefs.getString('userSex') ?? 'Male',
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
        }
      }
    }
  }

  // Sign In
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      // Store nutrition data before logging out
      await NutritionStorageService().storeCurrentDayNutrition(
          DateFormat('yyyy-MM-dd').format(DateTime.now()));

      final prefs = await SharedPreferences.getInstance();
      // Clear shared preferences
      await prefs.clear();
      // Initialize essential shared preferences data
      await initSharedPrefData(prefs);

      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error during sign out: $e');
      rethrow;
    }
  }
}
