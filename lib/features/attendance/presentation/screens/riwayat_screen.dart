import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat'),
      ),
      body: const Center(
        child: Text('Riwayat Screen - Coming Soon'),
      ),
    );
  }
}
