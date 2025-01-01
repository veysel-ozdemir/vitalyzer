import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/controller/scan_controller.dart';
import 'package:vitalyzer/presentation/page/home_page.dart';

class ScanResultPage extends GetView<ScanController> {
  final _scrollController = ScrollController();

  ScanResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.beige,
      appBar: AppBar(
        backgroundColor: ColorPalette.beige,
        foregroundColor: ColorPalette.green,
        title: const Text('Analysis Result'),
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
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: ColorPalette.lightGreen.withOpacity(0.5),
                        border: Border.all(
                            color: ColorPalette.lightGreen, width: 3),
                      ),
                      height: Get.height * 0.5,
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
                              Text(
                                controller.analysisResult.value,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: ColorPalette.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // todo: replace the following evelated button with the commented widgets
                    Center(
                      child: ElevatedButton(
                        onPressed: () async =>
                            await Get.offAll(() => const HomePage()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.green,
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
                            Text('Home Page',
                                style: TextStyle(
                                    color: ColorPalette.beige, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    // todo: here below are the widgets to be replaced later
                    // const Text(
                    //   'Have you eaten this meal?',
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //     color: ColorPalette.green,
                    //   ),
                    // ),
                    // const SizedBox(height: 20),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: [
                    //     ElevatedButton(
                    //       onPressed: () async {
                    //         // todo: handle 'no' response
                    //         await Get.offAll(() => const HomePage());
                    //       },
                    //       style: ElevatedButton.styleFrom(
                    //         fixedSize: Size.fromWidth(Get.width * 0.3),
                    //         backgroundColor: ColorPalette.beige,
                    //         shape: const RoundedRectangleBorder(
                    //           side: BorderSide(
                    //               color: ColorPalette.green, width: 2),
                    //           borderRadius:
                    //               BorderRadius.all(Radius.circular(30)),
                    //         ),
                    //       ),
                    //       child: const Text('No',
                    //           style: TextStyle(
                    //               color: ColorPalette.green, fontSize: 16)),
                    //     ),
                    //     ElevatedButton(
                    //       onPressed: () async {
                    //         // todo: handle 'yes' response
                    //         await Get.offAll(() => const HomePage());
                    //       },
                    //       style: ElevatedButton.styleFrom(
                    //         fixedSize: Size.fromWidth(Get.width * 0.3),
                    //         backgroundColor: ColorPalette.green,
                    //         shape: const RoundedRectangleBorder(
                    //           side: BorderSide(
                    //               color: ColorPalette.green, width: 2),
                    //           borderRadius:
                    //               BorderRadius.all(Radius.circular(30)),
                    //         ),
                    //       ),
                    //       child: const Text('Yes',
                    //           style: TextStyle(
                    //               color: ColorPalette.beige, fontSize: 16)),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
      ),
    );
  }
}
