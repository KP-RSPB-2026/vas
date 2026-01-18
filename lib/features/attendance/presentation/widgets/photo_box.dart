import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final _photoCacheManager = CacheManager(
  Config(
    'photo-cache',
    stalePeriod: const Duration(days: 15),
    maxNrOfCacheObjects: 60,
  ),
);

class PhotoBox extends StatelessWidget {
  final String label;
  final String? imageUrl;

  const PhotoBox({
    super.key,
    required this.label,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return GestureDetector(
      onTap: hasImage ? () => _showPreview(context) : null,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: const Color(0xFFD7D7D7),
            child: hasImage
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    cacheManager: _photoCacheManager,
                    fadeInDuration: const Duration(milliseconds: 200),
                    placeholder: (context, _) => const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, _, __) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.broken_image, color: Colors.black45),
                          SizedBox(height: 4),
                          Text('Gagal memuat', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _showPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.contain,
                      cacheManager: _photoCacheManager,
                      fadeInDuration: const Duration(milliseconds: 200),
                      placeholder: (context, _) => const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, _, __) => const Icon(Icons.broken_image, size: 120, color: Colors.white70),
                    )
                  : const Icon(Icons.image, size: 120, color: Colors.white),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
