
class Photo {
  const Photo({
    required this.id,
    required this.previewUrl,
    required this.imageUrl,
    required this.largeImageUrl,
    required this.tags,
    required this.user,
    required this.likes,
    required this.views,
    required this.width,
    required this.height,
  });

  final int id;
  final String previewUrl;
  final String imageUrl;
  final String largeImageUrl;
  final String tags;
  final String user;
  final int likes;
  final int views;
  final int width;
  final int height;

  factory Photo.fromJson(Map<String, dynamic> json) {
    String readString(Object? value, {String fallback = ''}) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      return fallback;
    }

    int readInt(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final webformatUrl = readString(json['webformatURL']);
    final largeUrl = readString(
      json['largeImageURL'],
      fallback: webformatUrl,
    );

    return Photo(
      id: readInt(json['id']),
      previewUrl: readString(
        json['previewURL'],
        fallback: webformatUrl,
      ),
      imageUrl: webformatUrl,
      largeImageUrl: largeUrl,
      tags: readString(json['tags']),
      user: readString(json['user'], fallback: 'Unknown'),
      likes: readInt(json['likes']),
      views: readInt(json['views']),
      width: readInt(json['imageWidth']),
      height: readInt(json['imageHeight']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'previewURL': previewUrl,
      'webformatURL': imageUrl,
      'largeImageURL': largeImageUrl,
      'tags': tags,
      'user': user,
      'likes': likes,
      'views': views,
      'imageWidth': width,
      'imageHeight': height,
    };
  }
}
