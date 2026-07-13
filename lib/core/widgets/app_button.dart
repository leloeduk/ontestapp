import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/connectivity_cubit.dart';

/// Bouton principal réutilisable, avec état de chargement optionnel.
/// Vérifie la connexion avant d'exécuter [onPressed].
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final isConnected = context.watch<ConnectivityCubit>().state;
        return FilledButton(
          onPressed: isLoading
              ? null
              : () {
                  if (!isConnected) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text('Connectez-vous à internet'),
                        ),
                      );
                    return;
                  }
                  onPressed?.call();
                },
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(label),
                  ],
                ),
        );
      },
    );
  }
}
