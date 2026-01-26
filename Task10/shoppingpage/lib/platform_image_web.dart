import 'package:flutter/widgets.dart';

Widget buildProductImage(String path, {double? height, double? width, BoxFit? fit}) {
  return Image.network(path, height: height, width: width, fit: fit);
}
