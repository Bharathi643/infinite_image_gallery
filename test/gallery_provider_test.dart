import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/models/photo.dart';
import 'package:infinite_image_gallery/providers/gallery_provider.dart';
import 'package:infinite_image_gallery/services/pixabay_service.dart';

class FakePixabayService implements PixabayService {
  FakePixabayService(this.onFetch);

  final Future<List<Photo>> Function({
    required int page,
    required String query,
    required int perPage,
  }) onFetch;

  @override
  Future<List<Photo>> fetchPhotos({
    required int page,
    required String query,
    int perPage = 20,
  }) {
    return onFetch(
      page: page,
      query: query,
      perPage: perPage,
    );
  }

  @override
  void dispose() {}
}

Photo makePhoto(int id) {
  return Photo(
    id: id,
    previewUrl: 'https://example.com/preview_$id.jpg',
    imageUrl: 'https://example.com/photo_$id.jpg',
    largeImageUrl: 'https://example.com/large_$id.jpg',
    tags: 'nature',
    user: 'test_user',
    likes: 10,
    views: 100,
    width: 800,
    height: 600,
  );
}

List<Photo> makePhotos(int count, {int startId = 1}) {
  return List.generate(count, (index) => makePhoto(startId + index));
}

void main() {
  group('GalleryProvider', () {
    test('loads the first page successfully', () async {
      final service = FakePixabayService(({
        required int page,
        required String query,
        required int perPage,
      }) async {
        expect(page, 1);
        expect(query, 'nature');
        expect(perPage, 20);
        return makePhotos(20);
      });

      final provider = GalleryProvider(service);

      await provider.fetchFirstPage();

      expect(provider.photos.length, 20);
      expect(provider.query, 'nature');
      expect(provider.hasMore, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);

      provider.dispose();
    });

    test('loads the next page when more photos are available', () async {
      final service = FakePixabayService(({
        required int page,
        required String query,
        required int perPage,
      }) async {
        if (page == 1) {
          return makePhotos(20, startId: 1);
        }

        return makePhotos(2, startId: 21);
      });

      final provider = GalleryProvider(service);

      await provider.fetchFirstPage();
      await provider.fetchNextPage();

      expect(provider.photos.length, 22);
      expect(provider.hasMore, isFalse);
      expect(provider.isLoading, isFalse);

      provider.dispose();
    });

    test('does not add duplicate photos', () async {
      final firstPage = makePhotos(20);

      final service = FakePixabayService(({
        required int page,
        required String query,
        required int perPage,
      }) async {
        if (page == 1) {
          return firstPage;
        }

        // Return existing photos again.
        return firstPage;
      });

      final provider = GalleryProvider(service);

      await provider.fetchFirstPage();
      await provider.fetchNextPage();

      expect(provider.photos.length, 20);
      expect(provider.hasMore, isFalse);

      provider.dispose();
    });

    test('search resets the gallery and trims the query', () async {
      final service = FakePixabayService(({
        required int page,
        required String query,
        required int perPage,
      }) async {
        if (query == 'nature') {
          return makePhotos(20, startId: 1);
        }

        if (query == 'cats') {
          return makePhotos(3, startId: 100);
        }

        return <Photo>[];
      });

      final provider = GalleryProvider(service);

      await provider.fetchFirstPage();
      expect(provider.photos.length, 20);

      await provider.search('  cats  ');

      expect(provider.query, 'cats');
      expect(provider.photos.length, 3);
      expect(provider.photos.first.id, 100);
      expect(provider.hasMore, isFalse);

      provider.dispose();
    });

    test('sets an error when fetching fails', () async {
      final service = FakePixabayService(({
        required int page,
        required String query,
        required int perPage,
      }) async {
        throw Exception('Network unavailable');
      });

      final provider = GalleryProvider(service);

      await provider.fetchFirstPage();

      expect(provider.hasError, isTrue);
      expect(provider.error, contains('Network unavailable'));
      expect(provider.isLoading, isFalse);
      expect(provider.photos, isEmpty);

      provider.dispose();
    });

    test('retry reloads the first page after an initial failure', () async {
      var callCount = 0;

      final service = FakePixabayService(({
        required int page,
        required String query,
        required int perPage,
      }) async {
        callCount++;

        if (callCount == 1) {
          throw Exception('Temporary error');
        }

        return makePhotos(2);
      });

      final provider = GalleryProvider(service);

      await provider.fetchFirstPage();

      expect(provider.hasError, isTrue);

      await provider.retry();

      expect(callCount, 2);
      expect(provider.hasError, isFalse);
      expect(provider.photos.length, 2);
      expect(provider.isLoading, isFalse);

      provider.dispose();
    });

    test('refresh reloads the current query', () async {
      final requestedQueries = <String>[];

      final service = FakePixabayService(({
        required int page,
        required String query,
        required int perPage,
      }) async {
        requestedQueries.add(query);

        if (query == 'birds') {
          return makePhotos(2, startId: requestedQueries.length * 100);
        }

        return <Photo>[];
      });

      final provider = GalleryProvider(service);

      await provider.fetchFirstPage(query: 'birds');
      await provider.refresh();

      expect(requestedQueries, ['birds', 'birds']);
      expect(provider.query, 'birds');
      expect(provider.photos.length, 2);

      provider.dispose();
    });
  });
}
