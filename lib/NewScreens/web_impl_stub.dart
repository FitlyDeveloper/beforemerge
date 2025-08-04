// This is a stub implementation for non-web platforms
import 'dart:typed_data';

// Stub methods that aren't used on non-web platforms

Future<String> getWebImageBase64(String imageUrl) async {
  throw UnsupportedError(
      'getWebImageBase64 is only available on web platforms');
}

Future<Uint8List> resizeWebImage(Uint8List imageBytes, int targetWidth,
    {int? targetHeight, int quality = 90}) async {
  throw UnsupportedError('resizeWebImage is only available on web platforms');
}

Future<Uint8List> createTinyJpeg(Uint8List sourceBytes,
    {int width = 50, int quality = 70}) async {
  throw UnsupportedError('createTinyJpeg is only available on web platforms');
}

Future<Uint8List> getWebImageBytes(String imagePath) async {
  throw UnsupportedError('getWebImageBytes is only available on web platforms');
}
