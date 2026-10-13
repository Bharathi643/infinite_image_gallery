import 'package:flutter/material.dart';

import '../models/photo.dart';

class PhotoInfoCard extends StatelessWidget {
  const PhotoInfoCard({
    super.key,
    required this.photo,
  });

  final Photo photo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tags = photo.tags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tags.isNotEmpty ? tags.first : 'Untitled Image',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (tags.length > 1) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.skip(1).take(8).map((tag) {
                  return Chip(
                    label: Text(tag),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 20),
            _DetailRow(
              icon: Icons.person_outline,
              label: 'Photographer',
              value: photo.user.trim().isEmpty ? 'Unknown' : photo.user,
            ),
            _DetailRow(
              icon: Icons.photo_size_select_large_outlined,
              label: 'Resolution',
              value: photo.width > 0 && photo.height > 0
                  ? '${photo.width} × ${photo.height}'
                  : 'Not available',
            ),
            _DetailRow(
              icon: Icons.favorite_border,
              label: 'Likes',
              value: photo.likes.toString(),
            ),
            _DetailRow(
              icon: Icons.visibility_outlined,
              label: 'Views',
              value: photo.views.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 21,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
