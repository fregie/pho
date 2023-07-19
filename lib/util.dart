import 'package:path/path.dart';

bool isVideoByPath(String path) {
  switch (extension(path).toLowerCase()) {
    case ".mp4":
    case ".avi":
    case ".mov":
    case ".mkv":
    case ".flv":
    case ".rmvb":
    case ".rm":
    case ".3gp":
    case ".wmv":
    case ".mpeg":
    case ".mpg":
    case ".webm":
      return true;
  }
  return false;
}
