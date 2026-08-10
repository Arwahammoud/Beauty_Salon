import 'package:flutter/material.dart';

// Renders a backend-hosted photo (Cloudinary URL) when present, falling back
// to a bundled local asset otherwise — covers both "no photo set yet" and
// "network image failed to load".
class NetworkOrAssetImage extends StatelessWidget {
  final String path;
  final String fallbackAsset;
  final double? width;
  final double? height;
  final BoxFit fit;

  const NetworkOrAssetImage({
    super.key,
    required this.path,
    required this.fallbackAsset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => Image.asset(
          fallbackAsset,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }
    return Image.asset(
      path.isEmpty ? fallbackAsset : path,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
