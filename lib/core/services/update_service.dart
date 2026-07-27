import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/app_constants.dart';

class UpdateService {
  Future<String?> getLatestVersion() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(AppConstants.versionCollection)
          .doc(AppConstants.versionDocument)
          .get();
      return doc.data()?[AppConstants.latestVersionField] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<String> getCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '0.0.0';
    }
  }

  Future<bool> isUpdateAvailable() async {
    try {
      final current = await getCurrentVersion();
      final latest = await getLatestVersion();
      if (latest == null) return false;
      return _compareVersions(latest, current) > 0;
    } catch (_) {
      return false;
    }
  }

  int _compareVersions(String a, String b) {
    try {
      final aParts = a.split(RegExp(r'[+\-]')).first.split('.').map(int.parse).toList();
      final bParts = b.split(RegExp(r'[+\-]')).first.split('.').map(int.parse).toList();
      for (int i = 0; i < 3; i++) {
        final aVal = aParts.length > i ? aParts[i] : 0;
        final bVal = bParts.length > i ? bParts[i] : 0;
        if (aVal != bVal) return aVal - bVal;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }
}
