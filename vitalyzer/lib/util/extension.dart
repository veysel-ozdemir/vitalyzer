import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  Size get deviceSize => MediaQuery.sizeOf(this);
}
