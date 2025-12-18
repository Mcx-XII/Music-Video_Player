import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestMediaPermission() async {
  if (Platform.isAndroid) {
    final video = await Permission.videos.request();
    final audio = await Permission.audio.request();
    return video.isGranted && audio.isGranted;
  }

  if (Platform.isIOS) {
    final PermissionState ps =
        await PhotoManager.requestPermissionExtend();

    if (!ps.hasAccess) {
      PhotoManager.openSetting();
      return false;
    }
    return true;
  }

  return false;
}
