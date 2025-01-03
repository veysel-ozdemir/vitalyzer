import 'package:get/get.dart';
import 'package:vitalyzer/dao/user_profile_dao.dart';
import 'package:vitalyzer/model/user_profile.dart';

class UserProfileController extends GetxController {
  final UserProfileDao _userProfileDao = UserProfileDao();
  final Rx<UserProfile?> currentProfile = Rx<UserProfile?>(null);

  Future<void> createUserProfile(UserProfile userProfile) async {
    await _userProfileDao.insertUserProfile(userProfile);
    currentProfile.value = userProfile;
  }

  Future<void> loadUserProfile(String firebaseUid) async {
    currentProfile.value =
        await _userProfileDao.getUserProfileByFirebaseUid(firebaseUid);
  }

  Future<void> updateUserProfile(UserProfile userProfile) async {
    await _userProfileDao.updateUserProfile(userProfile);
    currentProfile.value = userProfile;
  }

  Future<void> deleteUserProfile(int userId) async {
    await _userProfileDao.deleteUserProfile(userId);
    currentProfile.value = null;
  }
}
