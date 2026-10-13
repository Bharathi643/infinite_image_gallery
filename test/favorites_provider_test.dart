import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infinite_image_gallery/models/photo.dart';
import 'package:infinite_image_gallery/providers/favorites_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FavoritesProvider provider;

  const photo = Photo(
    id: 101,
    previewUrl: 'https://example.com/preview.jpg',
    imageUrl: 'https://example.com/photo.jpg',
    largeImageUrl: 'https://example.com/large.jpg',
    tags: 'nature, landscape',
    user: 'test_user',
    likes: 10,
    views: 100,
    width: 800,
    height: 600,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    provider = FavoritesProvider();
    await provider.load();
  });

  group('FavoritesProvider', () {
    test('starts with no favorites', () {
      expect(provider.count, 0);
      expect(provider.favorites, isEmpty);
      expect(provider.isFavorite(photo.id), isFalse);
    });

    test('adds a photo to favorites', () async {
      final result = await provider.toggle(photo);

      expect(result, isTrue);
      expect(provider.count, 1);
      expect(provider.isFavorite(photo.id), isTrue);
      expect(provider.favorites.single.id, photo.id);
    });

    test('removes a favorite when toggled again', () async {
      await provider.toggle(photo);

      final result = await provider.toggle(photo);

      expect(result, isTrue);
      expect(provider.count, 0);
      expect(provider.isFavorite(photo.id), isFalse);
    });

    test('persists favorites across provider instances', () async {
      await provider.toggle(photo);

      final anotherProvider = FavoritesProvider();
      await anotherProvider.load();

      expect(anotherProvider.count, 1);
      expect(anotherProvider.isFavorite(photo.id), isTrue);
      expect(anotherProvider.favorites.single.tags, photo.tags);
    });

    test('rejects a photo with an invalid ID', () async {
      const invalidPhoto = Photo(
        id: 0,
        previewUrl: 'https://example.com/preview.jpg',
        imageUrl: 'https://example.com/photo.jpg',
        largeImageUrl: 'https://example.com/large.jpg',
        tags: 'nature',
        user: 'test_user',
        likes: 0,
        views: 0,
        width: 800,
        height: 600,
      );

      final result = await provider.toggle(invalidPhoto);

      expect(result, isFalse);
      expect(provider.count, 0);
      expect(provider.errorMessage, isNotNull);
    });

    test('removing a nonexistent favorite succeeds', () async {
      final result = await provider.remove(999);

      expect(result, isTrue);
      expect(provider.count, 0);
    });

    test('clearError clears an existing error', () async {
      const invalidPhoto = Photo(
        id: 0,
        previewUrl: '',
        imageUrl: '',
        largeImageUrl: '',
        tags: '',
        user: 'test_user',
        likes: 0,
        views: 0,
        width: 0,
        height: 0,
      );

      await provider.toggle(invalidPhoto);
      expect(provider.errorMessage, isNotNull);

      provider.clearError();

      expect(provider.errorMessage, isNull);
    });
  });
}
