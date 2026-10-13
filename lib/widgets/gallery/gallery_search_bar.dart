import 'package:flutter/material.dart';

class GallerySearchBar extends StatelessWidget {
  const GallerySearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: SearchBar(
        controller: controller,
        hintText: 'Search images (e.g. cats, nature)',
        leading: const Icon(Icons.search),
        trailing: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => onSearch(controller.text),
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
        onSubmitted: onSearch,
      ),
    );
  }
}
