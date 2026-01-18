import 'package:flutter/material.dart';

class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akses ditolak')),
      body: const Center(
        child: Text(
          'Anda tidak memiliki akses ke halaman ini.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
