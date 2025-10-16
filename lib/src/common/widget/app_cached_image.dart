import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// {@template app_cached_image}
/// AppCachedImage widget.
/// {@endtemplate}
class AppCachedImage extends StatelessWidget {
  /// {@macro app_cached_image}
  const AppCachedImage(
    this.url, {
    super.key, // ignore: unused_element_parameter
    this.width,
    this.height,
    this.errorBuilder,
    this.progressIndicatorBuilder,
    this.borderRadius = BorderRadius.zero,
  });

  final String url;
  final double? width;
  final double? height;
  final BorderRadiusGeometry borderRadius;
  final LoadingErrorWidgetBuilder? errorBuilder;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: borderRadius,
    child: CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      progressIndicatorBuilder:
          progressIndicatorBuilder ?? (_, _, _) => const Center(child: CircularProgressIndicator()),
      errorWidget: errorBuilder ?? (_, _, _) => const Center(child: Icon(Icons.image_not_supported)),
    ),
  );
}
