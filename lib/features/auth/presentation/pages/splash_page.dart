import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/connectivity_cubit.dart';
import '../../../../core/widgets/offline_banner.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BlocBuilder<ConnectivityCubit, bool>(
            builder: (context, isConnected) {
              if (!isConnected) return const OfflineBanner();
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/ontestapps.png',
                    width: 210,
                    height: 180,
                  ),
                  const SizedBox(height: 30),
                  const CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
