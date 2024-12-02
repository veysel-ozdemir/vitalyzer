import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/presentation/widget/grid_item.dart';
import 'package:vitalyzer/util/extension.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int waterBottleItemCount = 0;
  final double waterBottleCapacity = 0.5;

  double? dailyWaterLimit;
  int? gainedCalories;
  int? dailyCalorieLimit;
  int drankWaterBottle = 0;
  List<bool> waterBottleItemStates = []; // Pressed states of items
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadSharedPrefs(); // Load persisted value when page initializes
  }

  Future<void> _loadSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyWaterLimit = prefs.getDouble('dailyWaterLimit');
      waterBottleItemCount =
          8; // todo: assign to this later => (dailyWaterLimit / waterBottleCapacity).toInt();
      gainedCalories = prefs.getInt('gainedCalories');
      dailyCalorieLimit = prefs.getInt('dailyCalorieLimit');
      drankWaterBottle = prefs.getInt('drankWaterBottle')!;

      final savedStates = prefs.getStringList('waterBottleItemStates');
      waterBottleItemStates = savedStates != null
          ? savedStates.map((e) => e == 'true').toList()
          : List.filled(waterBottleItemCount, false);
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('drankWaterBottle', drankWaterBottle); // Persist value
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
      _saveData(); // Save updated value
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = context.deviceSize;
    final items =
        List.generate(waterBottleItemCount, (index) => 'index $index');

    return Scaffold(
      backgroundColor: ColorPalette.beige,
      body: waterBottleItemStates.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Show a loader
          : Padding(
              padding: const EdgeInsets.only(
                  top: 50, bottom: 25, right: 25, left: 25),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning,',
                            style: TextStyle(
                              color: ColorPalette.darkGreen.withOpacity(0.75),
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Leonardo!',
                            style: TextStyle(
                              color: ColorPalette.darkGreen.withOpacity(0.75),
                              fontSize: 36,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ColorPalette.darkGreen,
                                width: 3,
                              ),
                            ),
                            child: FlutterLogo(
                              size: deviceSize.height * 0.05,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),
                  Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(10),
                                height: deviceSize.height * 0.25,
                                width: deviceSize.height * 0.25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ColorPalette.green,
                                    width: 3,
                                  ),
                                ),
                                child: const Text('Pie Chart'),
                              ),
                            ),
                            Text(
                              '$gainedCalories / $dailyCalorieLimit\nkcal',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ColorPalette.darkGreen.withOpacity(0.75),
                                fontSize: 14,
                              ),
                            )
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            '...',
                            style: TextStyle(
                              color: ColorPalette.darkGreen.withOpacity(0.75),
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                              color: ColorPalette.darkGreen.withOpacity(0.75),
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            "${drankWaterBottle * waterBottleCapacity} / $dailyWaterLimit L",
                            style: TextStyle(
                              color: ColorPalette.darkGreen.withOpacity(0.75),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              '...',
                              style: TextStyle(
                                color: ColorPalette.darkGreen.withOpacity(0.75),
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20)
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      height: deviceSize.height * 0.15,
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6, // Number of items per row
                          crossAxisSpacing:
                              2, // Space between items horizontally
                          mainAxisSpacing: 5, // Space between rows
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) => GridItem(
                          index: index,
                          isPressed: waterBottleItemStates[index],
                          onToggle: (isPressed) =>
                              _updateWaterBottleCount(index, isPressed),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Spacer(flex: 1),
                        InkWell(
                          onTap: () {},
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
                          onTap: () {},
                          child: Container(
                            alignment: Alignment.center,
                            height: deviceSize.height * 0.075,
                            width: deviceSize.height * 0.075,
                            child:
                                Image.asset('assets/illustrations/camera.png'),
                          ),
                        ),
                        const Spacer(flex: 3),
                        InkWell(
                          onTap: () {},
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
    );
  }
}
