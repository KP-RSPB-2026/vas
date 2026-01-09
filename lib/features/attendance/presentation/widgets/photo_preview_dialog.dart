import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PhotoPreviewDialog extends StatelessWidget {
  final File photoFile;
  final bool isLate;

  const PhotoPreviewDialog({
    super.key,
    required this.photoFile,
    required this.isLate,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Photo preview
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                photoFile,
                fit: BoxFit.cover,
                height: 300,
              ),
            ),
            const SizedBox(height: 16),

            // Message
            Text(
              'Pastikan data sudah benar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
