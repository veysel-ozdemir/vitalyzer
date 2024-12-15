import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:vitalyzer/const/color_palette.dart';

class BMIGauge extends StatelessWidget {
  final double bmiValue;

  const BMIGauge({super.key, required this.bmiValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 10,
              maximum: 50,
              ranges: <GaugeRange>[
                GaugeRange(
                  startValue: 10,
                  endValue: 18.5,
                  color: Colors.blue,
                  label: '',
                  labelStyle: const GaugeTextStyle(fontSize: 15),
                ),
                GaugeRange(
                  startValue: 18.5,
                  endValue: 24.99,
                  color: Colors.green,
                  label: '',
                  labelStyle: const GaugeTextStyle(fontSize: 15),
                ),
                GaugeRange(
                  startValue: 25,
                  endValue: 29.99,
                  color: Colors.yellow,
                  label: '',
                  labelStyle: const GaugeTextStyle(fontSize: 15),
                ),
                GaugeRange(
                  startValue: 30,
                  endValue: 39.99,
                  color: Colors.orange,
                  label: '',
                  labelStyle: const GaugeTextStyle(fontSize: 15),
                ),
                GaugeRange(
                  startValue: 40,
                  endValue: 50,
                  color: Colors.red,
                  label: '',
                  labelStyle: const GaugeTextStyle(fontSize: 15),
                ),
              ],
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: bmiValue,
                  enableAnimation: true,
                ),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Text(
                    'BMI: $bmiValue',
                    style: const TextStyle(
                      color: ColorPalette.darkGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  angle: 90,
                  positionFactor: 0.5,
                ),
                GaugeAnnotation(
                  widget: Text(
                    _bmiCategory(bmiValue),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _bmiColor(bmiValue),
                    ),
                  ),
                  angle: 90,
                  positionFactor: 0.75,
                ),
              ],
            ),
          ],
        ),
      ],
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
