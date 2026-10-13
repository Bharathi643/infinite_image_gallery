import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/photo.dart';
import '../providers/favorites_provider.dart';
import '../widgets/favorites/favorite_grid.dart';
import '../widgets/favorites/favorites_empty_state.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  void _openPhoto(BuildContext context, Photo photo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailScreen(photo: photo),
      ),
    );
  }

  Future<void> _removeFavorite(
    BuildContext context,
    Photo photo,
  ) async {
    final favorites = context.read<FavoritesProvider>();

    try {
      final success = await favorites.toggle(photo);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Removed from favorites.'
                  : favorites.errorMessage ?? 'Unable to update favorites.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update favorites.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final photos = favorites.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: false,
      ),
      body: photos.isEmpty
          ? const FavoritesEmptyState()
          : FavoriteGrid(
              photos: photos,
              onPhotoTap: (photo) => _openPhoto(context, photo),
              onRemove: (photo) => _removeFavorite(context, photo),
            ),
    );
  }
}
