import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Écran de démarrage affiché tant que l'état d'authentification est inconnu.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/ontestapps.png',
              width: 210,
              height: 180,
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
