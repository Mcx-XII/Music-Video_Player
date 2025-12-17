import 'package:permission_handler/permission_handler.dart';

Future<bool> requestMediaPermission() async {
  final video = await Permission.videos.request();
  final audio = await Permission.audio.request();

  return video.isGranted && audio.isGranted;
}
