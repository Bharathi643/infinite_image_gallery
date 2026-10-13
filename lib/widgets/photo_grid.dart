import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/photo.dart';

class PhotoGrid extends StatelessWidget {
  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onTap,
    this.footer,
    this.controller,
  });

  final List<Photo> photos;
  final ValueChanged<Photo> onTap;
  final Widget? footer;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1000
            ? 5
            : width >= 700
                ? 4
                : width >= 450
                    ? 3
                    : 2;

        return GridView.builder(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: photos.length + (footer == null ? 0 : 1),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            if (index >= photos.length) return footer!;

            final photo = photos[index];
            final imageUrl = photo.imageUrl.trim().isNotEmpty
                ? photo.imageUrl.trim()
                : photo.previewUrl.trim();

            return Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onTap(photo),
                child: imageUrl.isEmpty
                    ? const Center(
                        child: Icon(Icons.broken_image_outlined),
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
