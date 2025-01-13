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

      // Get physical attributes
      await prefs.setInt('userHeight', userProfile.height);
      await prefs.setDouble('userWeight', userProfile.weight);
      await prefs.setInt('userAge', userProfile.age);
      await prefs.setString('userSex', userProfile.gender);

      // Initialize nutrition data
      await userNutritionController
          .initializeUserNutritionData(userProfile.userId!);
    } else {
      debugPrint('User profile not found');

      bool? filledForm = prefs.getBool('userHasFilledInfoForm');
      if (filledForm == null || filledForm == false) {
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
      UserProfile? currentProfile = userProfileController.currentProfile.value;

      // If successfully created local user profile
      if (currentProfile != null) {
        debugPrint('Successfully created local user profile!');

        // Store the user profile id for current session
        await prefs.setInt('userProfileId', currentProfile.userId!);

        UserNutrition userNutrition = UserNutrition(
            userId: currentProfile.userId!,
            date:
                DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now())),
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

  Future<Map<String, dynamic>?> getUserCredentialByUid(String uid) async {
    try {
      // Fetch user document from Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc.data();
      } else {
        debugPrint('No user found with UID: $uid');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user credential: $e');
      rethrow;
    }
  }

  /// Updates user fields in Firestore and local UserProfile
  Future<void> updateUserFields({
    required String uid,
    String? fullName,
    String? profilePhotoUrl,
    Uint8List? imageBytes,
    int? height,
    double? weight,
    int? age,
    String? gender,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (fullName != null) updates['fullName'] = fullName;
      if (profilePhotoUrl != null) updates['profilePhotoUrl'] = profilePhotoUrl;

      if (updates.isNotEmpty) {
        // Update Firestore
        await _firestore.collection('users').doc(uid).update(updates);
        debugPrint('User fields updated successfully in Firestore!');
      }

      if (fullName != null ||
          profilePhotoUrl != null ||
          imageBytes != null ||
          height != null ||
          weight != null ||
          age != null ||
          gender != null) {
        // Update local UserProfile
        final currentProfile = userProfileController.currentProfile.value;
        if (currentProfile != null) {
          final updatedProfile = UserProfile(
            userId: currentProfile.userId,
            firebaseUserUid: currentProfile.firebaseUserUid,
            fullName: fullName ?? currentProfile.fullName,
            email: currentProfile.email,
            profilePhoto: imageBytes ?? currentProfile.profilePhoto,
            height: height ?? currentProfile.height,
            weight: weight ?? currentProfile.weight,
            age: age ?? currentProfile.age,
            gender: gender ?? currentProfile.gender,
            createdAt: currentProfile.createdAt,
            updatedAt: DateTime.now(),
          );
          await userProfileController.updateUserProfile(updatedProfile);
        }
        debugPrint('User fields updated successfullylocally');
      }
    } catch (e) {
      debugPrint('Error updating user fields: $e');
      rethrow;
    }
  }

  /// Helper method to download profile photo
  Future<Uint8List?> downloadProfilePhoto(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      debugPrint('Error downloading profile photo: $e');
      return null;
    }
  }

  /// Updates user email in Firebase Auth, Firestore, and local UserProfile
  Future<void> updateUserEmail({
    required String uid,
    required String newEmail,
    required String password,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(newEmail);

      // Update local UserProfile email
      final currentProfile = userProfileController.currentProfile.value;
      if (currentProfile != null) {
        final updatedProfile = UserProfile(
          userId: currentProfile.userId,
          firebaseUserUid: currentProfile.firebaseUserUid,
          fullName: currentProfile.fullName,
          email: newEmail, // Update the email
          profilePhoto: currentProfile.profilePhoto,
          height: currentProfile.height,
          weight: currentProfile.weight,
          age: currentProfile.age,
          gender: currentProfile.gender,
          createdAt: currentProfile.createdAt,
          updatedAt: DateTime.now(),
        );
        await userProfileController.updateUserProfile(updatedProfile);
      }
      debugPrint('Successfully updated user email locally!');

      Get.snackbar(
        'Verification Required',
        'Please check your new email address for verification',
        backgroundColor: ColorPalette.beige,
        colorText: ColorPalette.darkGreen,
      );

      // Update in Firestore and Auth will be done after verification
      debugPrint('Pending for email verification by user...');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered';
          break;
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        case 'requires-recent-login':
          message = 'Please log in again before updating email';
          break;
        default:
          message = 'An error occurred: ${e.message}';
      }
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('Error updating user email: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error updating user email: $e');
      rethrow;
    }
  }

  /// Updates user profile photo
  Future<void> updateProfilePhoto({
    required String uid,
    required XFile image,
  }) async {
    try {
      // Get current user data to check for existing photo URL
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data();

      // Delete old photo if it exists
      if (userData != null && userData['profilePhotoUrl'] != null) {
        try {
          final oldPhotoRef = _storage.refFromURL(userData['profilePhotoUrl']);
          await oldPhotoRef.delete();
          debugPrint('Old profile photo deleted successfully');
        } catch (e) {
          debugPrint('Error deleting old profile photo: $e');
          // Continue with upload even if delete fails
        }
      }

      // Upload new photo to Firebase Storage
      final storageRef = _storage
          .ref()
          .child('profile_photos')
          .child('${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(File(image.path));
      final String photoUrl = await storageRef.getDownloadURL();
      final Uint8List imageBytes = await image.readAsBytes();

      // Update Firestore document with new photo URL
      await updateUserFields(
        uid: uid,
        profilePhotoUrl: photoUrl,
        imageBytes: imageBytes,
      );
    } catch (e) {
      debugPrint('Error updating profile photo: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Success',
        'Password reset email has been sent to $email',
        backgroundColor: ColorPalette.beige,
        colorText: ColorPalette.darkGreen,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        default:
          message = 'An error occurred: ${e.message}';
      }
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  /// Change password (when user knows current password)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      // Re-authenticate user before password change
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      Get.snackbar(
        'Success',
        'Password has been updated successfully',
        backgroundColor: ColorPalette.beige,
        colorText: ColorPalette.darkGreen,
      );

      debugPrint('Successfully updated user password!');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak';
          break;
        case 'requires-recent-login':
          message = 'Please log in again before changing password';
          break;
        case 'wrong-password':
          message = 'Current password is incorrect';
          break;
        default:
          message = 'An error occurred: ${e.message}';
      }
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  /// Delete user account and all associated data
  Future<void> deleteUserAccount({
    required String uid,
    required String password,
  }) async {
    try {
      // Get current user and re-authenticate
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Get user document to check for profile photo
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data();

      // Delete profile photo from Storage if it exists
      if (userData != null && userData['profilePhotoUrl'] != null) {
        try {
          final photoRef = _storage.refFromURL(userData['profilePhotoUrl']);
          await photoRef.delete();
          debugPrint('Profile photo deleted from Storage');
        } catch (e) {
          debugPrint('Error deleting profile photo: $e');
          // Continue with deletion even if photo deletion fails
        }
      }

      // Delete user document from Firestore
      await _firestore.collection('users').doc(uid).delete();
      debugPrint('User document deleted from Firestore');

      // Delete local data
      final currentProfile = userProfileController.currentProfile.value;
      if (currentProfile?.userId != null) {
        // Delete user nutrition data
        await userNutritionController
            .loadUserNutritions(currentProfile!.userId!);
        // Create a new list with the nutritions to delete
        final nutritionsToDelete =
            List<UserNutrition>.from(userNutritionController.userNutritions);

        // Delete each nutrition entry
        for (var nutrition in nutritionsToDelete) {
          if (nutrition.nutritionId != null) {
            await userNutritionController
                .deleteUserNutrition(nutrition.nutritionId!);
          }
        }
        debugPrint('User nutrition data deleted from local database');

        // Delete user profile
        await userProfileController.deleteUserProfile(currentProfile.userId!);
        debugPrint('User profile deleted from local database');
      }

      // Finally, delete the Firebase Auth account
      await user.delete();
      debugPrint('User account deleted from Firebase Auth');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'requires-recent-login':
          message = 'Please log in again before deleting your account';
          break;
        case 'wrong-password':
          message = 'Current password is incorrect';
          break;
        default:
          message = 'An error occurred: ${e.message}';
      }
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('FirebaseAuthException occurred: $message');
      rethrow;
    } catch (e) {
      debugPrint('Error deleting user account: $e');
      rethrow;
    }
  }
}
