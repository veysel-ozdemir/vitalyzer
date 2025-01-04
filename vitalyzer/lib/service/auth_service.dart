import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
