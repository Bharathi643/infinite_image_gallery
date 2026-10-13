import 'package:flutter/material.dart';

import '../../models/photo.dart';
import 'favorite_tile.dart';

class FavoriteGrid extends StatelessWidget {
  const FavoriteGrid({
    super.key,
    required this.photos,
    required this.onPhotoTap,
    required this.onRemove,
  });

  final List<Photo> photos;
  final ValueChanged<Photo> onPhotoTap;
  final ValueChanged<Photo> onRemove;

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
          padding: const EdgeInsets.all(12),
          itemCount: photos.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.76,
          ),
          itemBuilder: (context, index) {
            final photo = photos[index];

            return FavoriteTile(
              key: ValueKey(photo.id),
              photo: photo,
              onTap: () => onPhotoTap(photo),
              onRemove: () => onRemove(photo),
            );
          },
        );
      },
    );
  }
}
