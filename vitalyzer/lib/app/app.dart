import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalyzer/config/global_bindings.dart';

class VitalyzerApp extends StatefulWidget {
  final Widget startingPage;

  const VitalyzerApp({super.key, required this.startingPage});

  @override
  State<VitalyzerApp> createState() => _VitalyzerAppState();
}

class _VitalyzerAppState extends State<VitalyzerApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.youngSerifTextTheme(),
      ),
      initialBinding: GlobalBindings(),
      home: widget.startingPage,
    );
  }
}
