import 'package:flutter/material.dart';
import 'package:vitalyzer/const/color_palette.dart';

class NutrientBarChart extends StatelessWidget {
  final double carbs;
  final double proteins;
  final double fats;
  final double carbsMaxGram;
  final double proteinsMaxGram;
  final double fatsMaxGram;

  const NutrientBarChart({
    super.key,
    required this.carbs,
    required this.proteins,
    required this.fats,
    required this.carbsMaxGram,
    required this.proteinsMaxGram,
    required this.fatsMaxGram,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBar("Carbs", carbs, carbsMaxGram,
            ColorPalette.darkGreen.withOpacity(0.75)),
        _buildBar("Protein", proteins, proteinsMaxGram,
            ColorPalette.green.withOpacity(0.75)),
        _buildBar("Fat", fats, fatsMaxGram,
            ColorPalette.lightGreen.withOpacity(0.75)),
      ],
    );
  }

  Widget _buildBar(String label, double value, double maxValue, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: ColorPalette.darkGreen.withOpacity(0.75),
                ),
              ),
              Text(
                "${value.toStringAsFixed(0)}/${maxValue.toStringAsFixed(0)} g",
                style: TextStyle(
                  fontSize: 14,
                  color: ColorPalette.darkGreen.withOpacity(0.75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: ColorPalette.lightGreen.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: (value / maxValue).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
