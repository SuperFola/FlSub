import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CoverArtLeading extends StatelessWidget {
  final String imageUrl;
  final String? cacheKey;

  const CoverArtLeading({
    super.key,
    required this.imageUrl,
    this.cacheKey,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: SizedBox.square(
        dimension: 56,
        child: CachedNetworkImage(
          fadeInCurve: Curves.fastLinearToSlowEaseIn,
          cacheKey: cacheKey ?? imageUrl,
          maxHeightDiskCache: 128,
          imageUrl: imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
