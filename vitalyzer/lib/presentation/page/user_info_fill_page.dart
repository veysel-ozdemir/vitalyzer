import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
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
  double? selectedHeight;
  double? selectedWeight;

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
                },
              ),
            ),
            // UserInfoContainer(
            //   text: 'Height',
            //   icon: Icons.height,
            //   buttonText: selectedHeight != null
            //       ? selectedHeight.toString()
            //       : selectedHeight,
            // ),
            // UserInfoContainer(
            //   text: 'Weight',
            //   icon: Icons.scale,
            //   buttonText: selectedWeight != null
            //       ? selectedWeight.toString()
            //       : selectedWeight,
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: ElevatedButton(
                onPressed: () async =>
                    await Get.off(() => const RegisterPage()),
                style: ButtonStyle(
                  fixedSize: WidgetStatePropertyAll(
                      Size.fromWidth(deviceSize.width * 0.5)),
                  backgroundColor:
                      const WidgetStatePropertyAll(ColorPalette.green),
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
                  setState(() {
                    selectedSex = "Male";
                  });
                  onSexSelected(selectedSex!); // Call the callback
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
                  setState(() {
                    selectedSex = "Female";
                  });
                  onSexSelected(selectedSex!); // Call the callback
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
    selectedAge ??= 35;

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
                                selectedAge = index;
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
                  selectedAge != null && selectedAge! >= 18
                      ? ElevatedButton(
                          style: ButtonStyle(
                            fixedSize: WidgetStatePropertyAll(
                                Size.fromWidth(deviceSize.width * 0.5)),
                            backgroundColor: const WidgetStatePropertyAll(
                                ColorPalette.green),
                          ),
                          onPressed: () {
                            onAgeSelected(selectedAge!); // Call the callback
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Select',
                            style: TextStyle(color: ColorPalette.beige),
                          ),
                        )
                      : selectedAge != null
                          ? const Text(
                              'You must be 18+ to use this app, as per market guidelines.',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : Container(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
