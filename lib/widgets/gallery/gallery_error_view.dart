import 'package:flutter/material.dart';

class GalleryErrorView extends StatelessWidget {
  const GalleryErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  String _friendlyMessage() {
    if (message.contains('API_KEY_MISSING')) {
      return 'Add your Pixabay API key to the .env file.';
    }
    if (message.contains('API_KEY_INVALID')) {
      return 'The Pixabay API key is invalid. Check your .env file.';
    }
    if (message.contains('RATE_LIMIT')) {
      return 'Too many requests. Please try again later.';
    }
    if (message.contains('NETWORK_ERROR')) {
      return 'Check your internet connection and try again.';
    }
    return 'Unable to load images. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _friendlyMessage(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
