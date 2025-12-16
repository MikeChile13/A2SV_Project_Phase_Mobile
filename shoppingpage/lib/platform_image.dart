import 'package:flutter/widgets.dart';
import 'platform_image_io.dart' if (dart.library.html) 'platform_image_web.dart' as impl;

Widget buildProductImage(String path, {double? height, double? width, BoxFit? fit}) {
	return impl.buildProductImage(path, height: height, width: width, fit: fit);
}
