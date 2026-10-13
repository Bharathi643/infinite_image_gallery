import 'package:flutter/material.dart';

class DetailDownloadButton extends StatelessWidget {
  const DetailDownloadButton({
    super.key,
    required this.isDownloading,
    required this.onPressed,
  });

  final bool isDownloading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: isDownloading ? null : onPressed,
        icon: isDownloading
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.download_rounded),
        label: Text(
          isDownloading ? 'Downloading image...' : 'Download Image',
        ),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
