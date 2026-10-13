import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/photo.dart';
import '../providers/gallery_provider.dart';
import '../screens/detail_screen.dart';
import '../screens/favorites_screen.dart';
import '../widgets/photo_grid.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.extentAfter < 500) {
      context.read<GalleryProvider>().fetchNextPage();
    }
  }

  Future<void> _searchImages([String? value]) async {
    final query = (value ?? _searchController.text).trim();

    FocusScope.of(context).unfocus();

    await context.read<GalleryProvider>().search(query);
  }

  Future<void> _refreshGallery() async {
    await context.read<GalleryProvider>().refresh();
  }

  void _openPhoto(Photo photo) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(photo: photo),
      ),
    );
  }

  void _openFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FavoritesScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gallery = context.watch<GalleryProvider>();

    if (_searchController.text != gallery.query &&
        !_searchController.selection.isValid) {
      _searchController.value = TextEditingValue(
        text: gallery.query,
        selection: TextSelection.collapsed(
          offset: gallery.query.length,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery'),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            onPressed: _openFavorites,
            icon: const Icon(Icons.favorite_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search images, such as nature or cats',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      _searchImages('');
                    },
                    icon: const Icon(Icons.close),
                  ),
                IconButton(
                  tooltip: 'Search images',
                  onPressed: () => _searchImages(),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
              onSubmitted: _searchImages,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshGallery,
              child: _buildGalleryContent(gallery),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryContent(GalleryProvider gallery) {
    if (gallery.photos.isEmpty && gallery.isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 320,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (gallery.photos.isEmpty && gallery.error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 320,
            child: _ErrorView(
              message: gallery.error!,
              onRetry: () => gallery.retry(),
            ),
          ),
        ],
      );
    }

    if (gallery.photos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 320,
            child: _EmptyGalleryView(
              query: gallery.query,
              onRetry: () => gallery.fetchFirstPage(),
            ),
          ),
        ],
      );
    }

    return PhotoGrid(
      photos: gallery.photos,
      controller: _scrollController,
      onTap: _openPhoto,
      footer: _buildFooter(gallery),
    );
  }

  Widget _buildFooter(GalleryProvider gallery) {
    if (gallery.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (gallery.error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                gallery.error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: gallery.retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Load More'),
              ),
            ],
          ),
        ),
      );
    }

    if (!gallery.hasMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text('You have reached the end of the gallery.'),
        ),
      );
    }

    return const SizedBox(height: 16);
  }
}

class _EmptyGalleryView extends StatelessWidget {
  const _EmptyGalleryView({
    required this.query,
    required this.onRetry,
  });

  final String query;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_search_outlined,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty ? 'No images found' : 'No matching images found',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try another search term or refresh the gallery.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Unable to load images',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}