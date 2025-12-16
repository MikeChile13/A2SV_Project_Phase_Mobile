import 'package:flutter/widgets.dart';
import 'dart:io';

Widget buildProductImage(String path, {double? height, double? width, BoxFit? fit}) {
  return Image.file(File(path), height: height, width: width, fit: fit);
}
