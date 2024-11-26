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
  int drankWaterBottle = 0; // Count of bottles pressed
  List<bool> waterBottleItemStates = []; // Pressed states of items

  @override
  void initState() {
    super.initState();
    _loadData(); // Load persisted value when page initializes
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      drankWaterBottle = prefs.getInt('drankWaterBottle') ?? 0; // Default to 0

      // Default to 8 items if not found in SharedPreferences
      final savedStates = prefs.getStringList('waterBottleItemStates');
      waterBottleItemStates = savedStates != null
          ? savedStates.map((e) => e == 'true').toList()
          : List.filled(8, false); // Match `items.length`
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
    final items = List.generate(8, (index) => 'index $index');

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
                              '1.799 / 2.020\nkcal',
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
                            "${drankWaterBottle * 0.5} / 4.0 L",
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
