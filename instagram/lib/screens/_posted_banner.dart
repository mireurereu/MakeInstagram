import 'package:flutter/material.dart';

class PostedBanner extends StatelessWidget {
  final String imagePath;
  final String message;
  final VoidCallback? onSend;

  const PostedBanner({super.key, required this.imagePath, required this.message, this.onSend});

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) return const SizedBox.shrink();

    final Widget image = imagePath.startsWith('http')
        ? Image.network(imagePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (c, e, s) => Container(color: Colors.grey[200]))
        : Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (c, e, s) => Container(color: Colors.grey[200]));

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            Positioned.fill(child: image),
            // translucent overlay at top with message and Send button
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(6)),
                      child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onSend,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1677FF)),
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
