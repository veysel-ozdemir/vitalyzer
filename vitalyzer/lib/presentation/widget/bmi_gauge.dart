import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/presentation/widget/bmi_gauge_painter.dart';

class BMIGauge extends StatefulWidget {
  final double bmiValue;

  const BMIGauge({super.key, required this.bmiValue});

  @override
  State<BMIGauge> createState() => _BMIGaugeState();
}

class _BMIGaugeState extends State<BMIGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 10, end: widget.bmiValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 15),
      height: Get.height * 0.35,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: BMIGaugePainter(bmiValue: _animation.value),
                child: const SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(flex: 6),
                Text(
                  'BMI: ${widget.bmiValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: ColorPalette.darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _bmiCategory(widget.bmiValue),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _bmiColor(widget.bmiValue),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Healthy';
    } else if (bmi < 30) {
      return 'Overweight';
    } else if (bmi < 40) {
      return 'Obesity';
    } else {
      return 'Severe Obesity';
    }
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi < 25) {
      return Colors.green;
    } else if (bmi < 30) {
      return Colors.yellow;
    } else if (bmi < 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
