import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit() : super(true) {
    _connectivity = Connectivity();
    _init();
  }

  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    emit(!result.contains(ConnectivityResult.none));
    _sub = _connectivity.onConnectivityChanged.listen((result) {
      emit(!result.contains(ConnectivityResult.none));
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
