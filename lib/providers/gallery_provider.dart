import 'package:flutter/foundation.dart';

import '../models/photo.dart';
import '../services/pixabay_service.dart';

class GalleryProvider extends ChangeNotifier {
  GalleryProvider(this._service);

  final PixabayService _service;
  final List<Photo> _photos = [];
  final Set<int> _photoIds = {};

  int _page = 1;
  static const int _pageSize = 20;

  String _query = 'nature';
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isRefreshing = false;
  String? _error;

  List<Photo> get photos => List.unmodifiable(_photos);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasMore => _hasMore;
  bool get hasError => _error != null;
  String? get error => _error;
  String get query => _query;
  bool get isEmpty => _photos.isEmpty && !_isLoading;

  Future<void> fetchFirstPage({String? query}) async {
    final nextQuery = query?.trim() ?? _query;
    _query = nextQuery;
    _page = 1;
    _hasMore = true;
    _error = null;
    _isRefreshing = _photos.isNotEmpty;

    _photos.clear();
    _photoIds.clear();

    notifyListeners();

    await fetchNextPage();
  }

  Future<void> fetchNextPage() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.fetchPhotos(
        page: _page,
        query: _query,
        perPage: _pageSize,
      );

      var addedCount = 0;

      for (final photo in result) {
        if (photo.id <= 0 || photo.imageUrl.trim().isEmpty) {
          continue;
        }

        if (_photoIds.add(photo.id)) {
          _photos.add(photo);
          addedCount++;
        }
      }

      if (result.length < _pageSize || addedCount == 0) {
        _hasMore = false;
      } else {
        _page++;
      }
    } catch (e) {
      _error = _friendlyError(e);
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchFirstPage(query: _query);
  }

  Future<void> search(String query) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery == _query) return;

    await fetchFirstPage(query: normalizedQuery);
  }

  Future<void> retry() async {
    if (_photos.isEmpty) {
      await fetchFirstPage(query: _query);
    } else {
      await fetchNextPage();
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();

    if (message.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    return message;
  }
}
