import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/controller/scan_controller.dart';
import 'package:vitalyzer/presentation/page/home_page.dart';

class WaterBottleScanResultPage extends StatefulWidget {
  const WaterBottleScanResultPage({super.key});

  @override
  State<WaterBottleScanResultPage> createState() =>
      _WaterWaterBottleScanResultPageState();
}

class _WaterWaterBottleScanResultPageState
    extends State<WaterBottleScanResultPage> {
  final ScanController controller = Get.find();
  final _scrollController = ScrollController();

  late SharedPreferences prefs;
  late int drankWaterBottle;
  late double waterBottleCapacity;
  late double dailyWaterLimit;

  @override
  void initState() {
    super.initState();
    _loadSharedPrefs();
  }

  Future<void> _loadSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      drankWaterBottle = prefs.getInt('drankWaterBottle')!;
      waterBottleCapacity = prefs.getDouble('waterBottleCapacity')!;
      dailyWaterLimit = prefs.getDouble('dailyWaterLimit')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.beige,
      appBar: AppBar(
        backgroundColor: ColorPalette.beige,
        foregroundColor: ColorPalette.green,
        title: const Text('Water Bottle Analysis Result'),
      ),
      body: Obx(
        () => controller.isAnalyzing.value
            ? const Center(
                child: CircularProgressIndicator(
                  color: ColorPalette.lightGreen,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: Get.height * 0.5),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: ColorPalette.lightGreen.withOpacity(0.5),
                          border: Border.all(
                              color: ColorPalette.lightGreen, width: 3),
                        ),
                        width: Get.width,
                        child: Scrollbar(
                          controller: _scrollController,
                          scrollbarOrientation: ScrollbarOrientation.right,
                          trackVisibility: true,
                          interactive: true,
                          thickness: 6,
                          radius: const Radius.circular(30),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MarkdownBody(
                                  data: controller.analysisResult.value,
                                  styleSheet: MarkdownStyleSheet(
                                    p: const TextStyle(
                                      fontSize: 16,
                                      color: ColorPalette.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async => await _parseResult(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: const RoundedRectangleBorder(
                                side: BorderSide(
                                    color: ColorPalette.green, width: 2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.done, color: ColorPalette.beige),
                                SizedBox(width: 10),
                                Text(
                                  'Accept',
                                  style: TextStyle(
                                      color: ColorPalette.beige, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async =>
                                await Get.offAll(() => const HomePage()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: const RoundedRectangleBorder(
                                side: BorderSide(
                                    color: ColorPalette.green, width: 2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.close, color: ColorPalette.beige),
                                SizedBox(width: 10),
                                Text(
                                  'Reject',
                                  style: TextStyle(
                                      color: ColorPalette.beige, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async =>
                            await _openWaterSelector(context: context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.green.withOpacity(0.75),
                          shape: const RoundedRectangleBorder(
                            side:
                                BorderSide(color: ColorPalette.green, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_forward,
                                color: ColorPalette.beige),
                            SizedBox(width: 10),
                            Text(
                              'Select Manually',
                              style: TextStyle(
                                  color: ColorPalette.beige, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _parseResult() async {
    String result = controller.analysisResult.value;

    final parsedPart = result.split(':');
    final parsedData = parsedPart[1].trim();
    final numPart = parsedData.split('L');
    final data = double.tryParse(numPart[0].trim()) ?? 0.0;

    debugPrint('The estimated amount drunk: $data');
    await _saveWaterData(data: data);
  }

  Future<void> _openWaterSelector({required BuildContext context}) async {
    const int minIntegerPart = 0;
    const int maxIntegerPart = 4;
    const int fractionPartRange = 5;

    int initialIntegerPart = 1; // 1
    int initialFractionPart = 1 * fractionPartRange; // 5

    // Scroll controllers for the two pickers
    FixedExtentScrollController integerPartController =
        FixedExtentScrollController(
      initialItem: initialIntegerPart - minIntegerPart,
    );
    FixedExtentScrollController fractionPartController =
        FixedExtentScrollController(
      initialItem: initialFractionPart,
    );

    double selection = initialIntegerPart + (initialFractionPart / 10.0); // 1.5

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
                    "Select Amount You Drunk",
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
                                      selection = initialIntegerPart +
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
                                      selection = initialIntegerPart +
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
                            right: Get.width * 0.1,
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
                  selection != 0.0
                      ? ElevatedButton(
                          style: ButtonStyle(
                            fixedSize: WidgetStatePropertyAll(
                              Size.fromWidth(Get.width * 0.5),
                            ),
                            backgroundColor: const WidgetStatePropertyAll(
                                ColorPalette.green),
                          ),
                          onPressed: () async =>
                              await _saveWaterData(data: selection),
                          child: const Text(
                            'Select',
                            style: TextStyle(color: ColorPalette.beige),
                          ),
                        )
                      : const Text(
                          "The amount can't be zero.",
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

  Future<void> _saveWaterData({required double data}) async {
    debugPrint('The drank water amount to be saved: $data');

    int bottleCount = (data / waterBottleCapacity).toInt();

    debugPrint('The drank water bottle count to be added: $bottleCount');

    setState(() {
      drankWaterBottle += bottleCount;
    });
    await prefs.setInt('drankWaterBottle', drankWaterBottle);

    debugPrint('New drank water bottle count: $drankWaterBottle');

    final waterBottleItemCount =
        (dailyWaterLimit / waterBottleCapacity).toInt();

    int count = drankWaterBottle;
    await prefs.setStringList(
      'waterBottleItemStates',
      List.generate(waterBottleItemCount, (_) {
        if ((count--) > 0) {
          return true;
        }
        return false;
      }).map((e) => e.toString()).toList(),
    );
    if (drankWaterBottle <= waterBottleItemCount) {
      await prefs.setBool('exceededWaterLimit', false);
    } else {
      debugPrint('Daily water limit exceeded!');
      await prefs.setBool('exceededWaterLimit', true);
    }

    await prefs.setString('lastWaterDrinkingTime',
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));

    await Get.offAll(() => const HomePage());
  }
}
