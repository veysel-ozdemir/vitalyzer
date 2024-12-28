import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/presentation/widget/svg_badge.dart';

class NutrientPieChart extends StatelessWidget {
  final double carbs;
  final double proteins;
  final double fats;
  final double? opacity;

  const NutrientPieChart({
    super.key,
    required this.carbs,
    required this.proteins,
    required this.fats,
    this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: carbs,
            color: ColorPalette.darkGreen.withOpacity(opacity ?? 0.75),
            radius: 40,
            title: '',
            badgeWidget: SvgBadge(
              svgAsset: 'assets/icons/wheat.svg',
              size: 45,
              borderColor: ColorPalette.darkGreen.withOpacity(0.75),
            ),
            badgePositionPercentageOffset: 1,
          ),
          PieChartSectionData(
            value: proteins,
            color: ColorPalette.green.withOpacity(opacity ?? 0.75),
            radius: 40,
            title: '',
            badgeWidget: SvgBadge(
              svgAsset: 'assets/icons/steak.svg',
              size: 45,
              borderColor: ColorPalette.green.withOpacity(0.75),
            ),
            badgePositionPercentageOffset: 1,
          ),
          PieChartSectionData(
            value: fats,
            color: ColorPalette.lightGreen.withOpacity(opacity ?? 0.75),
            radius: 40,
            title: '',
            badgeWidget: SvgBadge(
              svgAsset: 'assets/icons/cooking-oil.svg',
              size: 45,
              borderColor: ColorPalette.lightGreen.withOpacity(0.75),
            ),
            badgePositionPercentageOffset: 1,
          ),
        ],
        centerSpaceRadius: 50,
        sectionsSpace: 2,
      ),
    );
  }
}
