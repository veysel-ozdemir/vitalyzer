import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/presentation/page/register_page.dart';
import 'package:vitalyzer/presentation/widget/user_info_container.dart';
import 'package:vitalyzer/util/extension.dart';

class UserInfoFillPage extends StatefulWidget {
  const UserInfoFillPage({super.key});

  @override
  State<UserInfoFillPage> createState() => _UserInfoFillPageState();
}

class _UserInfoFillPageState extends State<UserInfoFillPage> {
  String? selectedSex;
  int? selectedAge;
  int? selectedHeight;
  double? selectedWeight;
  int? dailyCalorieLimit;
  double? dailyWaterLimit;
  double? bodyMassIndexLevel;
  bool isSelectionComplete = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadSharedPrefs();
  }

  Future<void> _loadSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _saveDataToSharedPrefs() async {
    await prefs.setString('userSex', selectedSex!);
    await prefs.setInt('userAge', selectedAge!);
    await prefs.setInt('userHeight', selectedHeight!);
    await prefs.setDouble('userWeight', selectedWeight!);
    await prefs.setDouble(
        'dailyWaterLimit',
        dailyWaterLimit ??
            4.0); // todo: get the value from AI tool and remove the conditional statement afterwards
    await prefs.setInt(
        'dailyCalorieLimit',
        dailyCalorieLimit ??
            2020); // todo: get the value from AI tool and remove the conditional statement afterwards
    await prefs.setDouble(
        'bodyMassIndexLevel',
        bodyMassIndexLevel ??
            24.5); // todo: get the value from AI tool and remove the conditional statement afterwards
    await prefs.setInt('gainedCalories', 0);
    await prefs.setInt('drankWaterBottle', 0);
    await prefs.setBool('userHasFilledInfoForm', true);
  }

  void updateSelectionStatus() {
    setState(() {
      isSelectionComplete = (selectedSex != null &&
          selectedAge != null &&
          selectedHeight != null &&
          selectedWeight != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = context.deviceSize;

    return Scaffold(
      backgroundColor: ColorPalette.beige,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding:
            const EdgeInsets.only(top: 50, bottom: 25, right: 25, left: 25),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: ColorPalette.darkGreen,
                  ),
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorPalette.lightGreen.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorPalette.lightGreen,
                      width: 3,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.person,
                      color: ColorPalette.green,
                      size: 40,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    'About you',
                    style: TextStyle(
                      color: ColorPalette.darkGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  'This information will be used to calculate your target calories, will be stored on your device and will not be shared with third parties.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorPalette.darkGreen,
                  ),
                )
              ],
            ),
            const Spacer(flex: 1),
            UserInfoContainer(
              text: 'Sex',
              icon: Icons.people_alt,
              buttonText: selectedSex,
              unit: null,
              onTap: () => _showSexSelector(
                context: context,
                onSexSelected: (sex) {
                  setState(() {
                    selectedSex = sex;
                  });
                  updateSelectionStatus();
                },
              ),
            ),
            UserInfoContainer(
              text: 'Age',
              icon: Icons.cake,
              buttonText:
                  selectedAge != null ? selectedAge.toString() : selectedAge,
              unit: 'years',
              onTap: () => _showAgeSelector(
                context: context,
                onAgeSelected: (age) {
                  setState(() {
                    selectedAge = age;
                  });
                  updateSelectionStatus();
                },
              ),
            ),
            UserInfoContainer(
              text: 'Height',
              icon: Icons.height,
              buttonText: selectedHeight != null
                  ? selectedHeight.toString()
                  : selectedHeight,
              unit: 'cm',
              onTap: () => _showHeightSelector(
                context: context,
                onHeightSelected: (height) {
                  setState(() {
                    selectedHeight = height;
                  });
                  updateSelectionStatus();
                },
              ),
            ),
            UserInfoContainer(
              text: 'Weight',
              icon: Icons.scale,
              buttonText: selectedWeight != null
                  ? selectedWeight.toString()
                  : selectedWeight,
              unit: 'kg',
              onTap: () => _showWeightSelector(
                context: context,
                onWeightSelected: (weight) {
                  setState(() {
                    selectedWeight = weight;
                  });
                  updateSelectionStatus();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: ElevatedButton(
                onPressed: isSelectionComplete
                    ? () async {
                        _saveDataToSharedPrefs();
                        return await Get.off(() => const RegisterPage());
                      }
                    : null,
                style: ButtonStyle(
                  fixedSize: WidgetStatePropertyAll(
                      Size.fromWidth(deviceSize.width * 0.5)),
                  backgroundColor: isSelectionComplete
                      ? const WidgetStatePropertyAll(ColorPalette.green)
                      : WidgetStatePropertyAll(
                          ColorPalette.green.withOpacity(0.5)),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: ColorPalette.beige,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSexSelector({
    required BuildContext context,
    required void Function(String)
        onSexSelected, // Pass a callback to update the state
  }) {
    String? sex = selectedSex;

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
        return Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Sex",
                style: TextStyle(
                  color: ColorPalette.darkGreen,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                tileColor: ColorPalette.lightGreen.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      color: ColorPalette.lightGreen, width: 3),
                  borderRadius: BorderRadius.circular(15),
                ),
                leading: const Icon(Icons.male, color: ColorPalette.green),
                title: const Text(
                  "Male",
                  style: TextStyle(color: ColorPalette.darkGreen),
                ),
                onTap: () {
                  sex = "Male";
                  onSexSelected(sex!); // Call the callback
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
              const SizedBox(height: 5),
              ListTile(
                tileColor: ColorPalette.lightGreen.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      color: ColorPalette.lightGreen, width: 3),
                  borderRadius: BorderRadius.circular(15),
                ),
                leading: const Icon(Icons.female, color: ColorPalette.green),
                title: const Text(
                  "Female",
                  style: TextStyle(color: ColorPalette.darkGreen),
                ),
                onTap: () {
                  sex = "Female";
                  onSexSelected(sex!); // Call the callback
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAgeSelector({
    required BuildContext context,
    required void Function(int)
        onAgeSelected, // Pass a callback to update the state
  }) {
    // Initialize scroll controller with previously selected age or default to 35
    FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: selectedAge ?? 35);
    final deviceSize = context.deviceSize;

    // Set initial age only if it hasn't been set before
    int age = selectedAge ?? 35;

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
                    "Age",
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
                          CupertinoPicker(
                            scrollController: scrollController,
                            itemExtent: 40,
                            selectionOverlay: Container(
                              decoration: BoxDecoration(
                                color: ColorPalette.lightGreen.withOpacity(0.5),
                                border: Border.all(
                                  color: ColorPalette.lightGreen,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onSelectedItemChanged: (int index) {
                              setState(() {
                                age = index;
                              });
                            },
                            children: List.generate(
                              101,
                              (index) => Center(
                                child: Text(
                                  index.toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          // Fixed "years" text overlay
                          Positioned(
                            right: deviceSize.width * 0.25,
                            child: const Text(
                              'years',
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
                  age >= 18
                      ? ElevatedButton(
                          style: ButtonStyle(
                            fixedSize: WidgetStatePropertyAll(
                                Size.fromWidth(deviceSize.width * 0.5)),
                            backgroundColor: const WidgetStatePropertyAll(
                                ColorPalette.green),
                          ),
                          onPressed: () {
                            onAgeSelected(age); // Call the callback
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Select',
                            style: TextStyle(color: ColorPalette.beige),
                          ),
                        )
                      : const Text(
                          'You must be 18+ to use this app, as per market guidelines.',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHeightSelector({
    required BuildContext context,
    required void Function(int)
        onHeightSelected, // Callback to update the state
  }) {
    // Define the range for height
    const int minHeight = 120;
    const int maxHeight = 250;

    // Initialize scroll controller with the selected or default height (170 cm)
    FixedExtentScrollController scrollController = FixedExtentScrollController(
      initialItem: (selectedHeight ?? 170) - minHeight,
    );
    final deviceSize = context.deviceSize;

    // Set initial height only if it hasn't been set before
    int height = selectedHeight ?? 170;

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
                    "Height",
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
                          CupertinoPicker(
                            scrollController: scrollController,
                            itemExtent: 40,
                            selectionOverlay: Container(
                              decoration: BoxDecoration(
                                color: ColorPalette.lightGreen.withOpacity(0.5),
                                border: Border.all(
                                  color: ColorPalette.lightGreen,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onSelectedItemChanged: (int index) {
                              setState(() {
                                height = (index + minHeight);
                              });
                            },
                            children: List.generate(
                              maxHeight - minHeight + 1,
                              (index) => Center(
                                child: Text(
                                  "${index + minHeight}",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          // Fixed "cm" text overlay
                          Positioned(
                            right: deviceSize.width * 0.25,
                            child: const Text(
                              'cm',
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
                      onHeightSelected(height); // Call the callback
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

  void _showWeightSelector({
    required BuildContext context,
    required void Function(double)
        onWeightSelected, // Callback to update the state
  }) {
    // Define the range for weight
    const int minIntegerPart = 30;
    const int maxIntegerPart = 200;
    const int minFractionPart = 0;
    const int maxFractionPart = 9;

    // Extract integer and fractional parts of the selected weight
    int initialIntegerPart = selectedWeight?.floor() ?? 70;
    int initialFractionPart = ((selectedWeight ?? 70) * 10 % 10).toInt();

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

    // Set initial weight only if it hasn't been set before
    double weight =
        selectedWeight ?? initialIntegerPart + (initialFractionPart / 10.0);

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
                    "Weight",
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
                                      weight = initialIntegerPart +
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
                                      weight = initialIntegerPart +
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
                              'kg',
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
                      onWeightSelected(weight); // Call the callback
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
}
