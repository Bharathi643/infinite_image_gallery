import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/photo.dart';
import '../providers/gallery_provider.dart';
import '../widgets/gallery/gallery_empty_state.dart';
import '../widgets/gallery/gallery_error_view.dart';
import '../widgets/gallery/gallery_search_bar.dart';
import '../widgets/photo_grid.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

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

  void _search(String query) {
    FocusScope.of(context).unfocus();
    context.read<GalleryProvider>().fetchFirstPage(query: query);
  }

  void _openPhoto(Photo photo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailScreen(photo: photo),
      ),
    );
  }

  void _openFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute(
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery'),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            onPressed: _openFavorites,
            icon: const Icon(Icons.favorite_border_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          GallerySearchBar(
            controller: _searchController,
            onSearch: _search,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: gallery.refresh,
              child: gallery.photos.isNotEmpty
                  ? PhotoGrid(
                      controller: _scrollController,
                      photos: gallery.photos,
                      onTap: _openPhoto,
                      footer: gallery.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : gallery.error != null
                              ? TextButton(
                                  onPressed: gallery.fetchNextPage,
                                  child: const Text('Retry loading images'),
                                )
                              : const SizedBox.shrink(),
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.6,
                          child: gallery.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : gallery.error != null
                                  ? GalleryErrorView(
                                      message: gallery.error!,
                                      onRetry: () => gallery.fetchFirstPage(),
                                    )
                                  : const GalleryEmptyState(),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
