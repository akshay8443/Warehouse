
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';


class NetworkConnectionService with ChangeNotifier {
  final _connectivity = Connectivity();
  final _connectionStatusController = BehaviorSubject<bool>();

  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  NetworkConnectionService() {
    _connectivity.onConnectivityChanged.listen((connectivityResult) {
      _connectionStatusController.add(connectivityResult != ConnectivityResult.none);
    });
  }
}