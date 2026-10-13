import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/main.dart';

void main() {
  testWidgets('Shows configuration error when configuration is unavailable',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ImageGalleryApp(configurationError: true),
    );

    expect(find.text('Configuration unavailable'), findsOneWidget);
    expect(find.text('Infinite Image Gallery'), findsOneWidget);
  });
}