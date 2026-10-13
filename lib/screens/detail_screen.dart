import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:provider/provider.dart';

import '../models/photo.dart';
import '../providers/favorites_provider.dart';
import '../widgets/detail_download_button.dart';
import '../widgets/photo_info_card.dart';
import '../widgets/photo_preview.dart';

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
      _showMessage('Image URL is unavailable.', isError: true);
      return;
    }

    setState(() => _downloading = true);

    try {
      final response = await _dio.get<List<int>>(imageUrl);
      final data = response.data;

      if (data == null || data.isEmpty) {
        _showMessage('Image could not be downloaded.', isError: true);
        return;
      }

      var hasAccess = await Gal.hasAccess();

      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
      }

      if (!hasAccess) {
        _showMessage(
          'Gallery permission was denied. Allow access to save images.',
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
          'Request timed out. Please try again.',
        DioExceptionType.connectionError =>
          'Unable to connect. Check your internet connection.',
        DioExceptionType.badResponse => 'The image server returned an error.',
        _ => 'Image download failed. Please try again.',
      };

      _showMessage(message, isError: true);
    } on GalException catch (error) {
      _showMessage(error.type.message, isError: true);
    } catch (_) {
      _showMessage(
        'Unable to save the image. Please try again.',
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

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavorite(photo.id);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Details'),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: _favoriteActionInProgress ? null : _toggleFavorite,
            icon: _favoriteActionInProgress
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? theme.colorScheme.error : null,
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            PhotoPreview(photo: photo),
            const SizedBox(height: 20),
            PhotoInfoCard(photo: photo),
            const SizedBox(height: 20),
            DetailDownloadButton(
              isDownloading: _downloading,
              onPressed: _download,
            ),
            const SizedBox(height: 16),
            Text(
              'Image information is provided by Pixabay. '
              'Some details may not be available for every image.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
