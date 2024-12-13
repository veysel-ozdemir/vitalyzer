// calculate the body mass index (BMI) in kg & cm
double calculateBodyMassIndex({
  required double kgWeight,
  required int cmHeight,
}) {
  double mHeight = cmHeight / 100;
  double result = (kgWeight / (mHeight * mHeight));
  String precisioned = result.toStringAsPrecision(4);
  return double.parse(precisioned);
}
