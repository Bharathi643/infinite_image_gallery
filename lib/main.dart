import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/favorites_provider.dart';
import 'providers/gallery_provider.dart';
import 'screens/gallery_screen.dart';
import 'services/pixabay_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var configurationError = false;

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    configurationError = true;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GalleryProvider(PixabayService())
            ..fetchFirstPage(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider()..load(),
        ),
      ],
      child: ImageGalleryApp(
        configurationError: configurationError,
      ),
    ),
  );
}

class ImageGalleryApp extends StatelessWidget {
  const ImageGalleryApp({
    super.key,
    this.configurationError = false,
  });

  final bool configurationError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite Image Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
        ),
        cardTheme: const CardThemeData(
          elevation: 1,
        ),
      ),
      home: configurationError
          ? const _ConfigurationErrorScreen()
          : const GalleryScreen(),
    );
  }
}

class _ConfigurationErrorScreen extends StatelessWidget {
  const _ConfigurationErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Image Gallery'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.settings_outlined,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                'Configuration unavailable',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Unable to load the application configuration. '
                'Verify that the .env file exists and is included '
                'in the Flutter assets.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => const _ConfigurationErrorScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}