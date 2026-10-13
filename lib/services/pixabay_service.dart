import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/photo.dart';

class PixabayService {
  PixabayService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://pixabay.com/api/';
  static const int _defaultPageSize = 20;
  static const Duration _requestTimeout = Duration(seconds: 20);

  final http.Client _client;

  String get _apiKey {
    final key = dotenv.env['PIXABAY_API_KEY']?.trim() ?? '';

    if (key.isEmpty) {
      throw const PixabayException(
        'Pixabay API key is missing. Check your environment configuration.',
      );
    }

    return key;
  }

  Future<List<Photo>> fetchPhotos({
    required int page,
    required String query,
    int perPage = _defaultPageSize,
  }) async {
    if (page < 1) {
      throw const PixabayException('The page number must be greater than zero.');
    }

    if (perPage < 3 || perPage > 200) {
      throw const PixabayException(
        'The page size must be between 3 and 200.',
      );
    }

    final normalizedQuery = query.trim().isEmpty ? 'nature' : query.trim();

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'key': _apiKey,
        'q': normalizedQuery,
        'image_type': 'photo',
        'safesearch': 'true',
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );

    late final http.Response response;

    try {
      response = await _client.get(uri).timeout(_requestTimeout);
    } on TimeoutException {
      throw const PixabayException(
        'The request timed out. Please check your connection and try again.',
      );
    } on http.ClientException {
      throw const PixabayException(
        'Unable to connect to Pixabay. Check your internet connection.',
      );
    } catch (_) {
      throw const PixabayException(
        'An unexpected network error occurred. Please try again.',
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const PixabayException(
        'Pixabay rejected the request. Check your API key and usage limits.',
      );
    }

    if (response.statusCode == 429) {
      throw const PixabayException(
        'Pixabay request limit reached. Please wait and try again.',
      );
    }

    if (response.statusCode != 200) {
      throw PixabayException(
        'Pixabay request failed with status code ${response.statusCode}.',
      );
    }

    late final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const PixabayException(
        'Pixabay returned an invalid response. Please try again later.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const PixabayException(
        'Pixabay returned an unexpected response format.',
      );
    }

    final hits = decoded['hits'];

    if (hits is! List) {
      throw const PixabayException(
        'The image list could not be retrieved from Pixabay.',
      );
    }

    final photos = <Photo>[];

    for (final hit in hits) {
      if (hit is! Map<String, dynamic>) continue;

      try {
        final photo = Photo.fromJson(hit);

        if (photo.id > 0 && photo.imageUrl.trim().isNotEmpty) {
          photos.add(photo);
        }
      } catch (_) {
        continue;
      }
    }

    return photos;
  }

  void dispose() {
    _client.close();
  }
}

class PixabayException implements Exception {
  const PixabayException(this.message);

  final String message;

  @override
  String toString() => message;
}