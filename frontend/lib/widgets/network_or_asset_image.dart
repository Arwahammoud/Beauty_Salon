import 'dart:convert';

import 'package:flutter/material.dart';

// Renders a backend-hosted photo — either a Cloudinary URL or a base64
// "data:" URI (e.g. user avatars, stored directly on the user document) —
// falling back to a bundled local asset otherwise. Covers "no photo set
// yet", "network image failed to load", and "not a valid data URI".
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
    if (path.startsWith('data:')) {
      final commaIndex = path.indexOf(',');
      if (commaIndex != -1) {
        try {
          final bytes = base64Decode(path.substring(commaIndex + 1));
          return Image.memory(
            bytes,
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
        } catch (_) {
          // Fall through to the asset fallback below.
        }
      }
      return Image.asset(fallbackAsset, width: width, height: height, fit: fit);
    }
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
