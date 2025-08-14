import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> isOnline() async {
  try {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  } catch (e) {
    print("Connectivity check failed: $e");
    return false; // assume offline if it fails
  }
}
