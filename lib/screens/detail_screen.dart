import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:provider/provider.dart';

import '../models/photo.dart';
import '../providers/favorites_provider.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.photo,
  });

  final Photo photo;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final Dio _dio;
  bool _downloading = false;
  bool _favoriteActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 15),
        responseType: ResponseType.bytes,
      ),
    );
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  Future<void> _download() async {
    if (_downloading) return;

    final photo = widget.photo;
    final imageUrl = photo.largeImageUrl.trim().isNotEmpty
        ? photo.largeImageUrl.trim()
        : photo.imageUrl.trim();

    if (imageUrl.isEmpty) {
      _showMessage('The image URL is unavailable.', isError: true);
      return;
    }

    setState(() => _downloading = true);

    try {
      final response = await _dio.get<List<int>>(imageUrl);
      final data = response.data;

      if (data == null || data.isEmpty) {
        _showMessage('The image could not be downloaded.', isError: true);
        return;
      }

      var hasAccess = await Gal.hasAccess();

      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
      }

      if (!hasAccess) {
        _showMessage(
          'Gallery access is required to save images.',
          isError: true,
        );
        return;
      }

      await Gal.putImageBytes(
        Uint8List.fromList(data),
        name: 'pixabay_${photo.id}',
      );

      _showMessage('Image saved to your gallery.');
    } on DioException catch (error) {
      final message = switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'The request timed out. Please try again.',
        DioExceptionType.connectionError =>
          'Unable to connect. Check your internet connection.',
        DioExceptionType.badResponse =>
          'The image server returned an error.',
        _ => 'The image could not be downloaded. Please try again.',
      };

      _showMessage(message, isError: true);
    } catch (_) {
      _showMessage(
        'Unable to save the image. Please check gallery permissions.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _downloading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_favoriteActionInProgress) return;

    setState(() => _favoriteActionInProgress = true);

    try {
      final favorites = context.read<FavoritesProvider>();
      final wasFavorite = favorites.isFavorite(widget.photo.id);
      final success = await favorites.toggle(widget.photo);

      if (!mounted) return;

      if (success) {
        _showMessage(
          wasFavorite ? 'Removed from favorites.' : 'Added to favorites.',
        );
      } else {
        _showMessage(
          favorites.errorMessage ?? 'Unable to update favorites.',
          isError: true,
        );
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to update favorites.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _favoriteActionInProgress = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? Theme.of(context).colorScheme.error
              : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavorite(photo.id);
    final imageUrl = photo.largeImageUrl.trim().isNotEmpty
        ? photo.largeImageUrl.trim()
        : photo.imageUrl.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Details'),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: _favoriteActionInProgress ? null : _toggleFavorite,
            icon: _favoriteActionInProgress
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: photo.width > 0 && photo.height > 0
                  ? photo.width / photo.height
                  : 4 / 3,
              child: imageUrl.isEmpty
                  ? const Center(
                      child: Icon(Icons.broken_image_outlined, size: 48),
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _downloading ? null : _download,
            icon: _downloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(
              _downloading ? 'Downloading...' : 'Download Image',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            photo.tags.trim().isEmpty ? 'Untitled Image' : photo.tags,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.person_outline,
            label: 'Uploaded by',
            value: photo.user,
          ),
          _DetailRow(
            icon: Icons.photo_size_select_large_outlined,
            label: 'Resolution',
            value: photo.width > 0 && photo.height > 0
                ? '${photo.width} × ${photo.height}'
                : 'Not available',
          ),
          _DetailRow(
            icon: Icons.favorite_border,
            label: 'Likes',
            value: photo.likes.toString(),
          ),
          _DetailRow(
            icon: Icons.visibility_outlined,
            label: 'Views',
            value: photo.views.toString(),
          ),
          const SizedBox(height: 12),
          Text(
            'Image information is provided by the Pixabay API. Some details may not be available for every image.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}