import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vitalyzer/presentation/page/landing_page.dart';

class VitalyzerApp extends StatefulWidget {
  const VitalyzerApp({super.key});

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
      home: LandingPage(),
    );
  }
}
