import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/photo.dart';

class PhotoPreview extends StatelessWidget {
  const PhotoPreview({
    super.key,
    required this.photo,
  });

  final Photo photo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final imageUrl = photo.largeImageUrl.trim().isNotEmpty
        ? photo.largeImageUrl.trim()
        : photo.imageUrl.trim();

    final aspectRatio = photo.width > 0 && photo.height > 0
        ? (photo.width / photo.height).clamp(0.6, 2.0).toDouble()
        : 4 / 3;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: imageUrl.isEmpty
            ? const _ImageErrorView()
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const _ImageErrorView(),
              ),
      ),
    );
  }
}

class _ImageErrorView extends StatelessWidget {
  const _ImageErrorView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 52,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Image unavailable',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
