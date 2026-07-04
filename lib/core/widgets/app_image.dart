import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Affiche une image depuis une URL ou une chaîne base64 (data:image/...).
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('data:')) {
      final parts = imageUrl.split(',');
      if (parts.length == 2) {
        final bytes = base64Decode(parts[1]);
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
          child: Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit ?? BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(context),
          ),
        );
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        placeholder: (_, __) => _placeholder(context),
        errorWidget: (_, __, ___) => _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Icon(Icons.apps),
    );
  }
}
