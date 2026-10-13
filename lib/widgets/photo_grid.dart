import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/photo.dart';

class PhotoGrid extends StatelessWidget {
  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onTap,
    this.controller,
    this.footer,
  });

  final List<Photo> photos;
  final ValueChanged<Photo> onTap;
  final ScrollController? controller;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = switch (width) {
          >= 1200 => 6,
          >= 1000 => 5,
          >= 700 => 4,
          >= 450 => 3,
          _ => 2,
        };

        return GridView.builder(
          controller: controller,
          padding: const EdgeInsets.all(12),
          itemCount: photos.length + (footer == null ? 0 : 1),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            if (index >= photos.length) {
              return footer ?? const SizedBox.shrink();
            }

            final photo = photos[index];

            return _PhotoTile(
              key: ValueKey(photo.id),
              photo: photo,
              onTap: () => onTap(photo),
            );
          },
        );
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    super.key,
    required this.photo,
    required this.onTap,
  });

  final Photo photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = photo.previewUrl.trim().isNotEmpty
        ? photo.previewUrl.trim()
        : photo.imageUrl.trim();

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ColoredBox(
                  color: Color(0xFFE8EAF0),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const ColoredBox(
                  color: Color(0xFFE8EAF0),
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 36,
                    ),
                  ),
                ),
              )
            else
              const ColoredBox(
                color: Color(0xFFE8EAF0),
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 36,
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                  child: Text(
                    photo.tags.trim().isEmpty
                        ? 'Untitled image'
                        : photo.tags.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}