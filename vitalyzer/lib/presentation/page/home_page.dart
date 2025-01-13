import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/controller/nutrition_controller.dart';
import 'package:vitalyzer/controller/user_profile_controller.dart';
import 'package:vitalyzer/model/user_profile.dart';
import 'package:vitalyzer/presentation/camera/camera_screen.dart';
import 'package:vitalyzer/presentation/page/analysis_page.dart';
import 'package:vitalyzer/presentation/page/food_drink_search_page.dart';
import 'package:vitalyzer/presentation/page/profile_page.dart';
import 'package:vitalyzer/presentation/widget/grid_item.dart';
import 'package:vitalyzer/presentation/widget/nutrient_bar_chart.dart';
import 'package:vitalyzer/presentation/widget/nutrient_pie_chart.dart';
import 'package:vitalyzer/util/extension.dart';
import 'package:intl/intl.dart';
import 'package:vitalyzer/service/nutrition_storage_service.dart';
import 'package:vitalyzer/util/scan_option.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int waterBottleItemCount = 0;
  int? currentUserProfileId;
  String? currentUserFirebaseUid;
  double? waterBottleCapacity;
  double? dailyWaterLimit;
  bool? exceededWaterLimit;
  int drankWaterBottle = 0;
  double dailyCalorieLimit = 0;
  double gainedCalories = 0;
  double? carbsCalorieLimit;
  double? proteinCalorieLimit;
  double? fatCalorieLimit;
  double? gainedCarbsCalorie;
  double? gainedProteinCalorie;
  double? gainedFatCalorie;
  double? carbsGramLimit;
  double? proteinGramLimit;
  double? fatGramLimit;
  double? gainedCarbsGram;
  double? gainedProteinGram;
  double? gainedFatGram;
  int? carbsCaloriePerGram;
  int? proteinCaloriePerGram;
  int? fatCaloriePerGram;
  List<bool> waterBottleItemStates = []; // Pressed states of items
  String? lastWaterDrinkingTime;
  int lastWaterDrinkingDay = -1;
  int lastWaterDrinkingHour = -1;
  int lastWaterDrinkingMin = -1;
  UserProfile? currentUserProfile;
  Uint8List? userProfilePhoto;
  String nameInitials = '';
  late SharedPreferences prefs;
  final NutritionController _nutritionController = Get.find();
  final UserProfileController _userProfileController = Get.find();
  final _scrollController = ScrollController();

  String greeting = '';
  late Timer timer;
  Timer? _dayCheckTimer;
  String? currentDay;
  final NutritionStorageService _nutritionStorage = NutritionStorageService();

  @override
  void initState() {
    super.initState();
    _loadSharedPrefsAndUserProfileData();
    _updateGreeting();
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateGreeting();
      _updateWaterReminder();
    });
    _startDayChangeCheck();
  }

  Future<void> _loadSharedPrefsAndUserProfileData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserProfileId = prefs.getInt('userProfileId');
      currentUserFirebaseUid = prefs.getString('userFirebaseUid');

      exceededWaterLimit = prefs.getBool('exceededWaterLimit');

      dailyWaterLimit = prefs.getDouble('dailyWaterLimit');
      waterBottleCapacity = prefs.getDouble('waterBottleCapacity');

      waterBottleItemCount = (dailyWaterLimit! / waterBottleCapacity!).toInt();

      lastWaterDrinkingTime = prefs.getString('lastWaterDrinkingTime');

      carbsCalorieLimit = prefs.getDouble('carbsCalorieLimit');
      proteinCalorieLimit = prefs.getDouble('proteinCalorieLimit');
      fatCalorieLimit = prefs.getDouble('fatCalorieLimit');

      dailyCalorieLimit =
          carbsCalorieLimit! + proteinCalorieLimit! + fatCalorieLimit!;

      carbsGramLimit = prefs.getDouble('carbsGramLimit');
      proteinGramLimit = prefs.getDouble('proteinGramLimit');
      fatGramLimit = prefs.getDouble('fatGramLimit');

      gainedCarbsCalorie = prefs.getDouble('gainedCarbsCalorie');
      gainedProteinCalorie = prefs.getDouble('gainedProteinCalorie');
      gainedFatCalorie = prefs.getDouble('gainedFatCalorie');

      gainedCalories =
          gainedCarbsCalorie! + gainedProteinCalorie! + gainedFatCalorie!;

      gainedCarbsGram = prefs.getDouble('gainedCarbsGram');
      gainedProteinGram = prefs.getDouble('gainedProteinGram');
      gainedFatGram = prefs.getDouble('gainedFatGram');

      drankWaterBottle = prefs.getInt('drankWaterBottle')!;

      final savedStates = prefs.getStringList('waterBottleItemStates');
      waterBottleItemStates = savedStates != null
          ? savedStates.map((e) => e == 'true').toList()
          : List.generate(waterBottleItemCount, (_) => false);

      carbsCaloriePerGram = prefs.getInt('carbsCaloriePerGram');
      proteinCaloriePerGram = prefs.getInt('proteinCaloriePerGram');
      fatCaloriePerGram = prefs.getInt('fatCaloriePerGram');

      currentDay = prefs.getString('currentDay');
    });

    // update water reminder
    _updateWaterReminder();

    // load current user profile
    await _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    debugPrint('Loading user profile from local database');

    await _userProfileController.loadUserProfile(currentUserFirebaseUid!);

    setState(() {
      currentUserProfile = _userProfileController.currentProfile.value;
    });

    if (currentUserProfile != null) {
      debugPrint(
          'Successfully loaded current user profile from local database');

      setState(() {
        userProfilePhoto = currentUserProfile!.profilePhoto;
        var splitted = currentUserProfile!.fullName.split(' ');
        int count;
        if (splitted.length == 1) {
          count = 1;
        } else {
          count = 2;
        }
        for (int i = 0; i < count; i++) {
          String split = splitted[i];
          nameInitials += split[0].toUpperCase();
        }
      });
    } else {
      debugPrint('Could not fetch current user profile from local database');
      debugPrint('currentUserFirebaseUid: $currentUserFirebaseUid');
    }
  }

  Future<void> _saveWaterData() async {
    setState(() {
      lastWaterDrinkingTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    });
    await prefs.setString('lastWaterDrinkingTime', lastWaterDrinkingTime!);
    await prefs.setInt('drankWaterBottle', drankWaterBottle);
    await prefs.setStringList('waterBottleItemStates',
        waterBottleItemStates.map((e) => e.toString()).toList());
  }

  void _updateWaterBottleCount(int index, bool isPressed) {
    setState(() {
      if (isPressed) {
        drankWaterBottle++;
      } else {
        drankWaterBottle--;
      }
      waterBottleItemStates[index] = isPressed; // Update state for this item
      _saveWaterData(); // Save updated value
    });
  }

  Future<void> _updateCalorieLimitData() async {
    await prefs.setDouble('gainedCarbsCalorie', gainedCarbsCalorie!);
    await prefs.setDouble('gainedProteinCalorie', gainedProteinCalorie!);
    await prefs.setDouble('gainedFatCalorie', gainedFatCalorie!);
    await prefs.setDouble('gainedCarbsGram', gainedCarbsGram!);
    await prefs.setDouble('gainedProteinGram', gainedProteinGram!);
    await prefs.setDouble('gainedFatGram', gainedFatGram!);

    await prefs.setDouble('carbsCalorieLimit', carbsCalorieLimit!);
    await prefs.setDouble('proteinCalorieLimit', proteinCalorieLimit!);
    await prefs.setDouble('fatCalorieLimit', fatCalorieLimit!);

    await prefs.setDouble('carbsGramLimit', carbsGramLimit!);
    await prefs.setDouble('proteinGramLimit', proteinGramLimit!);
    await prefs.setDouble('fatGramLimit', fatGramLimit!);
  }

  Future<void> _updateWaterLimitData() async {
    await prefs.remove('lastWaterDrinkingTime');
    await prefs.setDouble('dailyWaterLimit', dailyWaterLimit!);
    await prefs.setInt('drankWaterBottle', drankWaterBottle);
    await prefs.setStringList('waterBottleItemStates',
        waterBottleItemStates.map((e) => e.toString()).toList());
    await prefs.setBool('exceededWaterLimit', exceededWaterLimit!);
  }

  void _updateGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    String newGreeting;

    if (hour >= 5 && hour < 12) {
      newGreeting = 'Good Morning,';
    } else if (hour == 12) {
      newGreeting = 'Good Noon,';
    } else if (hour > 12 && hour < 17) {
      newGreeting = 'Good Afternoon,';
    } else if (hour >= 17 && hour < 21) {
      newGreeting = 'Good Evening,';
    } else {
      newGreeting = 'Good Night,';
    }

    if (newGreeting != greeting) {
      setState(() {
        greeting = newGreeting;
      });
    }
  }

  void _updateWaterReminder() {
    if (lastWaterDrinkingTime != null) {
      // Last water drinking time
      DateTime last = DateTime.parse(lastWaterDrinkingTime!);
      // Get the current date and time
      DateTime now = DateTime.now();

      // Calculate the difference
      Duration difference = now.difference(last);

      // Extract days, hours, and minutes
      setState(() {
        lastWaterDrinkingDay = difference.inDays;
        lastWaterDrinkingHour = difference.inHours % 24;
        lastWaterDrinkingMin = difference.inMinutes % 60;
      });
    }
  }

  void _startDayChangeCheck() {
    // Check every minute
    _dayCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final newDay = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (newDay != currentDay) {
        debugPrint('Day has changed');

        await _nutritionStorage.storeCurrentDayNutrition(currentDay!);

        debugPrint('Stored nutrition data of current day: $currentDay');

        setState(() {
          currentDay = newDay;
        });
        await prefs.setString('currentDay', currentDay!);

        debugPrint('New day: $currentDay');
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _dayCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = context.deviceSize;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorPalette.beige,
      body: waterBottleItemStates.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: ColorPalette.lightGreen),
            ) // Show a loader
          : Padding(
              padding: const EdgeInsets.only(
                  top: 50, bottom: 25, right: 20, left: 20),
              child: LayoutBuilder(
                builder: (context, constraints) => Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      greeting,
                                      style: TextStyle(
                                        color: ColorPalette.darkGreen
                                            .withOpacity(0.75),
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(
                                      width: Get.width * 0.5,
                                      child: Text(
                                        (currentUserProfile != null)
                                            ? '${currentUserProfile!.fullName}!'
                                            : 'Friend!',
                                        style: TextStyle(
                                          color: ColorPalette.darkGreen
                                              .withOpacity(0.75),
                                          fontSize: 36,
                                        ),
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () async => await Get.to(() =>
                                      ProfilePage(nameInitials: nameInitials)),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: Get.width * 0.3,
                                      width: Get.width * 0.3,
                                      decoration: BoxDecoration(
                                        color: ColorPalette.lightGreen
                                            .withOpacity(0.5),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: ColorPalette.darkGreen,
                                          width: 3,
                                        ),
                                      ),
                                      child: (userProfilePhoto != null)
                                          ? ClipOval(
                                              child: Image.memory(
                                                userProfilePhoto!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Center(
                                              child: TextButton(
                                                onPressed: null,
                                                child: Text(
                                                  nameInitials,
                                                  style: const TextStyle(
                                                    color: ColorPalette.green,
                                                    fontSize: 35,
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => _openNutritionSettings(
                                    context: context,
                                    onNutritionLimitUpdate:
                                        (calorieLimit) async {
                                      await _nutritionController
                                          .getMacroDistribution(calorieLimit);

                                      setState(() {
                                        dailyCalorieLimit = calorieLimit;
                                        gainedCalories = 0.0;
                                        gainedCarbsCalorie = 0.0;
                                        gainedProteinCalorie = 0.0;
                                        gainedFatCalorie = 0.0;
                                        gainedCarbsGram = 0.0;
                                        gainedProteinGram = 0.0;
                                        gainedFatGram = 0.0;
                                        // set the calorie limits of each macronutrient
                                        carbsCalorieLimit = _nutritionController
                                            .carbsCalories.value;
                                        proteinCalorieLimit =
                                            _nutritionController
                                                .proteinCalories.value;
                                        fatCalorieLimit = _nutritionController
                                            .fatCalories.value;
                                        // calculate the gram limits of each macronutrient
                                        carbsGramLimit = carbsCalorieLimit! /
                                            carbsCaloriePerGram!;
                                        proteinGramLimit =
                                            proteinCalorieLimit! /
                                                proteinCaloriePerGram!;
                                        fatGramLimit = fatCalorieLimit! /
                                            fatCaloriePerGram!;
                                      });

                                      await _updateCalorieLimitData();
                                    },
                                  ),
                                  child: Text(
                                    '...',
                                    style: TextStyle(
                                      color: ColorPalette.darkGreen
                                          .withOpacity(0.75),
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 25, left: 10),
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 10),
                                      height: Get.width * 0.4,
                                      width: Get.width * 0.4,
                                      child: Stack(
                                        children: [
                                          (gainedCalories > 0.0)
                                              ? NutrientPieChart(
                                                  carbs: gainedCarbsCalorie!,
                                                  proteins:
                                                      gainedProteinCalorie!,
                                                  fats: gainedFatCalorie!,
                                                )
                                              : NutrientPieChart(
                                                  carbs: carbsCalorieLimit!,
                                                  proteins:
                                                      proteinCalorieLimit!,
                                                  fats: fatCalorieLimit!,
                                                  opacity: 0.3,
                                                ),
                                          Center(
                                            child: Text(
                                              '${gainedCalories.floor()} / ${dailyCalorieLimit.floor()}\nkcal',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: ColorPalette.darkGreen
                                                    .withOpacity(0.75),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 25),
                                    child: SizedBox(
                                      width: Get.width * 0.35,
                                      child: NutrientBarChart(
                                        carbs: gainedCarbsGram!,
                                        proteins: gainedProteinGram!,
                                        fats: gainedFatGram!,
                                        carbsMaxGram: carbsGramLimit!,
                                        proteinsMaxGram: proteinGramLimit!,
                                        fatsMaxGram: fatGramLimit!,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Water Counter',
                                      style: TextStyle(
                                        color: ColorPalette.darkGreen
                                            .withOpacity(0.75),
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      "${drankWaterBottle * waterBottleCapacity!} / $dailyWaterLimit L",
                                      style: TextStyle(
                                        color: ColorPalette.darkGreen
                                            .withOpacity(0.75),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () async => await Get.to(
                                        () => const CameraScreen(
                                          scanOption:
                                              ScanOption.waterBottleScan,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.camera,
                                        color: ColorPalette.green,
                                        size: 30,
                                      ),
                                      tooltip: 'Scan Water Bottle',
                                    ),
                                    Column(
                                      children: [
                                        TextButton(
                                          onPressed: () =>
                                              _openWaterCounterSettings(
                                            context: context,
                                            onWaterLimitUpdate:
                                                (waterLimit) async {
                                              setState(() {
                                                drankWaterBottle = 0;
                                                dailyWaterLimit = waterLimit;
                                                waterBottleItemCount =
                                                    (dailyWaterLimit! /
                                                            waterBottleCapacity!)
                                                        .toInt();
                                                waterBottleItemStates =
                                                    List.generate(
                                                  waterBottleItemCount,
                                                  (_) => false,
                                                );
                                                exceededWaterLimit = false;
                                                lastWaterDrinkingTime = null;
                                              });

                                              await _updateWaterLimitData();
                                            },
                                          ),
                                          child: Text(
                                            '...',
                                            style: TextStyle(
                                              color: ColorPalette.darkGreen
                                                  .withOpacity(0.75),
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10)
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color:
                                      ColorPalette.lightGreen.withOpacity(0.5),
                                  border: Border.all(
                                      color: ColorPalette.lightGreen, width: 3),
                                ),
                                width: Get.width,
                                child: Scrollbar(
                                  controller: _scrollController,
                                  scrollbarOrientation:
                                      ScrollbarOrientation.right,
                                  trackVisibility: true,
                                  interactive: true,
                                  thickness: 6,
                                  radius: const Radius.circular(30),
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [_waterTextWidget()],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: SizedBox(
                                height: deviceSize.height * 0.15,
                                child: (exceededWaterLimit != true)
                                    ? GridView.builder(
                                        padding: EdgeInsets.zero,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              6, // Number of items per row
                                          crossAxisSpacing:
                                              2, // Space between items horizontally
                                          mainAxisSpacing:
                                              5, // Space between rows
                                        ),
                                        itemCount: waterBottleItemCount,
                                        itemBuilder: (context, index) =>
                                            GridItem(
                                          index: index,
                                          isPressed:
                                              waterBottleItemStates[index],
                                          onToggle: (isPressed) =>
                                              _updateWaterBottleCount(
                                                  index, isPressed),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25, bottom: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Spacer(flex: 1),
                          InkWell(
                            onTap: () async =>
                                await Get.to(() => const FoodDrinkSearchPage()),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(5),
                              height: deviceSize.height * 0.075,
                              width: deviceSize.height * 0.075,
                              child: Image.asset(
                                  'assets/illustrations/checklist.png'),
                            ),
                          ),
                          const Spacer(flex: 3),
                          InkWell(
                            onTap: () async => await Get.to(
                              () => const CameraScreen(
                                scanOption: ScanOption.mealScan,
                              ),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              height: deviceSize.height * 0.075,
                              width: deviceSize.height * 0.075,
                              child: Image.asset(
                                  'assets/illustrations/camera.png'),
                            ),
                          ),
                          const Spacer(flex: 3),
                          InkWell(
                            onTap: () async =>
                                Get.to(() => const AnalysisPage()),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(5),
                              height: deviceSize.height * 0.075,
                              width: deviceSize.height * 0.075,
                              child: Image.asset(
                                  'assets/illustrations/analytics.png'),
                            ),
                          ),
                          const Spacer(flex: 1),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _waterTextWidget() {
    if (exceededWaterLimit != true) {
      if (lastWaterDrinkingTime != null) {
        if (lastWaterDrinkingMin <= 0 &&
            lastWaterDrinkingHour <= 0 &&
            lastWaterDrinkingDay <= 0) {
          // Pass
        } else if (lastWaterDrinkingDay == 0 && lastWaterDrinkingHour == 0) {
          // Show only minutes
          return Text(
            "You haven't been hydrated since $lastWaterDrinkingMin minutes. Don't forget your daily intake!",
            textAlign: TextAlign.center,
            style: const TextStyle(color: ColorPalette.green),
          );
        } else if (lastWaterDrinkingDay == 0) {
          // Show hours and minutes
          return Text(
            "You haven't been hydrated since $lastWaterDrinkingHour hours and $lastWaterDrinkingMin minutes. Don't forget your daily intake!",
            textAlign: TextAlign.center,
            style: const TextStyle(color: ColorPalette.green),
          );
        } else {
          return Text(
            "You haven't been hydrated since $lastWaterDrinkingDay days, $lastWaterDrinkingHour hours, and $lastWaterDrinkingMin minutes. Don't forget your daily intake!",
            textAlign: TextAlign.center,
            style: const TextStyle(color: ColorPalette.green),
          );
        }
      }
      return const Text(
        "A well-hydrated body is the key to clear thinking and boundless energy — don't forget your daily water intake!",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: ColorPalette.green,
        ),
      );
    } else {
      return const Text(
        "You have exceeded your daily water intake limit!",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: ColorPalette.green,
        ),
      );
    }
  }

  void _openNutritionSettings({
    required BuildContext context,
    required void Function(double) onNutritionLimitUpdate,
  }) {
    const int minIntegerPart = 1200;
    const int maxIntegerPart = 3500;
    const int minFractionPart = 0;
    const int maxFractionPart = 9;

    int initialIntegerPart = dailyCalorieLimit.floor();
    int initialFractionPart = (dailyCalorieLimit * 10 % 10).toInt();

    // Scroll controllers for the two pickers
    FixedExtentScrollController integerPartController =
        FixedExtentScrollController(
      initialItem: initialIntegerPart - minIntegerPart,
    );
    FixedExtentScrollController fractionPartController =
        FixedExtentScrollController(
      initialItem: initialFractionPart,
    );

    final deviceSize = context.deviceSize;

    double calorieLimit = dailyCalorieLimit;

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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Customize Calorie Limit",
                    style: TextStyle(
                      color: ColorPalette.darkGreen,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          pickerTextStyle:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: ColorPalette.darkGreen,
                                  ),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(flex: 1),
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: integerPartController,
                                  itemExtent: 40,
                                  selectionOverlay: Container(
                                    decoration: BoxDecoration(
                                      color: ColorPalette.lightGreen
                                          .withOpacity(0.5),
                                      border: const Border(
                                        left: BorderSide(
                                          color: ColorPalette.lightGreen,
                                          width: 3,
                                        ),
                                        top: BorderSide(
                                          color: ColorPalette.lightGreen,
                                          width: 3,
                                        ),
                                        bottom: BorderSide(
                                          color: ColorPalette.lightGreen,
                                          width: 3,
                                        ),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                  onSelectedItemChanged: (int index) {
                                    setState(() {
                                      initialIntegerPart =
                                          index + minIntegerPart;
                                      calorieLimit = initialIntegerPart +
                                          initialFractionPart / 10.0;
                                    });
                                  },
                                  children: List.generate(
                                    maxIntegerPart - minIntegerPart + 1,
                                    (index) => Center(
                                      child: Text(
                                        "${index + minIntegerPart}",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: fractionPartController,
                                  itemExtent: 40,
                                  selectionOverlay: Container(
                                    decoration: BoxDecoration(
                                      color: ColorPalette.lightGreen
                                          .withOpacity(0.5),
                                      border: const Border(
                                        right: BorderSide(
                                          color: ColorPalette.lightGreen,
                                          width: 3,
                                        ),
                                        top: BorderSide(
                                          color: ColorPalette.lightGreen,
                                          width: 3,
                                        ),
                                        bottom: BorderSide(
                                          color: ColorPalette.lightGreen,
                                          width: 3,
                                        ),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                  onSelectedItemChanged: (int index) {
                                    setState(() {
                                      initialFractionPart = index;
                                      calorieLimit = initialIntegerPart +
                                          initialFractionPart / 10.0;
                                    });
                                  },
                                  children: List.generate(
                                    maxFractionPart - minFractionPart + 1,
                                    (index) => Center(
                                      child: Text(
                                        "$index",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(flex: 1),
                            ],
                          ),
                          const Center(
                            child: Text(
                              '.',
                              style: TextStyle(
                                color: ColorPalette.darkGreen,
                              ),
                            ),
                          ),
                          Positioned(
                            right: deviceSize.width * 0.1,
                            child: const Text(
                              'kcal',
                              style: TextStyle(
                                color: ColorPalette.darkGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: WidgetStatePropertyAll(
                        Size.fromWidth(deviceSize.width * 0.5),
                      ),
                      backgroundColor:
                          const WidgetStatePropertyAll(ColorPalette.green),
                    ),
                    onPressed: () {
                      onNutritionLimitUpdate(calorieLimit); // Call the callback
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Select',
                      style: TextStyle(color: ColorPalette.beige),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openWaterCounterSettings({
    required BuildContext context,
    required void Function(double) onWaterLimitUpdate,
  }) {
    const int minIntegerPart = 0;
    const int maxIntegerPart = 4;
    const int fractionPartRange = 5;

    int initialIntegerPart = dailyWaterLimit!.floor();
    int initialFractionPart = (dailyWaterLimit! * 10 % 10).toInt();

    // Scroll controllers for the two pickers
    FixedExtentScrollController integerPartController =
        FixedExtentScrollController(
      initialItem: initialIntegerPart - minIntegerPart,
    );
    FixedExtentScrollController fractionPartController =
        FixedExtentScrollController(
      initialItem: initialFractionPart,
    );

    final deviceSize = context.deviceSize;

    double waterLimit = dailyWaterLimit!;

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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Customize Water Limit",
                    style: TextStyle(
                      color: ColorPalette.darkGreen,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          pickerTextStyle:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: ColorPalette.darkGreen,
                                  ),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(flex: 1),
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: integerPartController,
                                  itemExtent: 40,
                                  selectionOverlay: Container(
                                    decoration: BoxDecoration(
                                      color: ColorPalette.lightGreen
                                          .withOpacity(0.5),
                                      border: const Border(
                                        left: BorderSide(
                                          color: ColorPalette.lightGreen,
                                          width: 3,
                                        ),
                                        top: BorderSide(
                                          color: ColorPalette.lightGreen,
                                          width: 3,
                                        ),
                                        bottom: BorderSide(
                                          color: ColorPalette.lightGreen,
                                          width: 3,
                                        ),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                  onSelectedItemChanged: (int index) {
                                    setState(() {
                                      initialIntegerPart =
                                          index + minIntegerPart;
                                      waterLimit = initialIntegerPart +
                                          initialFractionPart / 10.0;
                                    });
                                  },
                                  children: List.generate(
                                    maxIntegerPart - minIntegerPart + 1,
                                    (index) => Center(
                                      child: Text(
                                        "${index + minIntegerPart}",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: fractionPartController,
                                  itemExtent: 40,
                                  selectionOverlay: Container(
                                    decoration: BoxDecoration(
                                      color: ColorPalette.lightGreen
                                          .withOpacity(0.5),
                                      border: const Border(
                                        right: BorderSide(
                                          color: ColorPalette.lightGreen,
                                          width: 3,
                                        ),
                                        top: BorderSide(
                                          color: ColorPalette.lightGreen,
                                          width: 3,
                                        ),
                                        bottom: BorderSide(
                                          color: ColorPalette.lightGreen,
                                          width: 3,
                                        ),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                  onSelectedItemChanged: (int index) {
                                    setState(() {
                                      initialFractionPart =
                                          index * fractionPartRange;
                                      waterLimit = initialIntegerPart +
                                          initialFractionPart / 10.0;
                                    });
                                  },
                                  children: List.generate(
                                    2,
                                    (index) => Center(
                                      child: Text(
                                        "${index * fractionPartRange}",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(flex: 1),
                            ],
                          ),
                          const Center(
                            child: Text(
                              '.',
                              style: TextStyle(
                                color: ColorPalette.darkGreen,
                              ),
                            ),
                          ),
                          Positioned(
                            right: deviceSize.width * 0.1,
                            child: const Text(
                              'L',
                              style: TextStyle(
                                color: ColorPalette.darkGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  waterLimit != 0.0
                      ? ElevatedButton(
                          style: ButtonStyle(
                            fixedSize: WidgetStatePropertyAll(
                              Size.fromWidth(deviceSize.width * 0.5),
                            ),
                            backgroundColor: const WidgetStatePropertyAll(
                                ColorPalette.green),
                          ),
                          onPressed: () {
                            onWaterLimitUpdate(waterLimit); // Call the callback
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Select',
                            style: TextStyle(color: ColorPalette.beige),
                          ),
                        )
                      : const Text(
                          "The limit can't be zero.",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
