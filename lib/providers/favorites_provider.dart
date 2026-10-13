import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/photo.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _storageKey = 'favorite_photos_v1';

  final Map<int, Photo> _favorites = {};

  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  List<Photo> get favorites => List<Photo>.unmodifiable(_favorites.values);

  int get count => _favorites.length;

  bool isFavorite(int id) => _favorites.containsKey(id);

  Future<void> load() async {
    if (_isLoading || _hasLoaded) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      _favorites.clear();

      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);

        if (decoded is List) {
          for (final item in decoded) {
            if (item is! Map) continue;

            final json = Map<String, dynamic>.from(item);
            final photo = Photo.fromJson(json);

            if (photo.id > 0 && photo.imageUrl.isNotEmpty) {
              _favorites[photo.id] = photo;
            }
          }
        } else {
          _errorMessage = 'Saved favorites data is invalid.';
        }
      }

      _hasLoaded = true;
    } catch (_) {
      _errorMessage = 'Could not load saved favorites.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggle(Photo photo) async {
    if (photo.id <= 0 || photo.imageUrl.isEmpty) {
      _errorMessage = 'This image cannot be saved as a favorite.';
      notifyListeners();
      return false;
    }

    final wasFavorite = _favorites.containsKey(photo.id);

    if (wasFavorite) {
      _favorites.remove(photo.id);
    } else {
      _favorites[photo.id] = photo;
    }

    _errorMessage = null;
    notifyListeners();

    final saved = await _save();

    if (!saved) {
      if (wasFavorite) {
        _favorites[photo.id] = photo;
      } else {
        _favorites.remove(photo.id);
      }

      _errorMessage = 'Could not save changes. Please try again.';
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<bool> remove(int id) async {
    final photo = _favorites.remove(id);
    if (photo == null) return true;

    _errorMessage = null;
    notifyListeners();

    final saved = await _save();

    if (!saved) {
      _favorites[id] = photo;
      _errorMessage = 'Could not remove favorite. Please try again.';
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<bool> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(
        _favorites.values.map((photo) => photo.toJson()).toList(),
      );

      final success = await prefs.setString(_storageKey, raw);

      if (!success) {
        _errorMessage = 'Could not save favorites to this device.';
        return false;
      }

      return true;
    } catch (_) {
      _errorMessage = 'A storage error occurred while saving favorites.';
      return false;
    }
  }

  void clearError() {
    if (_errorMessage == null) return;

    _errorMessage = null;
    notifyListeners();
  }
}
