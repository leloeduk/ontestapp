import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Écran de démarrage affiché tant que l'état d'authentification est inconnu.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.verified_user_outlined, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'OnTestApp',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
