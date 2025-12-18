import 'package:photo_manager/photo_manager.dart';

Future<bool> requestMediaPermission() async {
  final PermissionState ps =
      await PhotoManager.requestPermissionExtend();

  if (!ps.hasAccess) {
    PhotoManager.openSetting();
    return false;
  }

  return true;
}
