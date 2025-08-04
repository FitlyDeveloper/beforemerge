// Stub implementation for web platforms to avoid having to include flutter_image_compress
import 'dart:typed_data';

// Dummy class to mimic FlutterImageCompress
class FlutterImageCompress {
  static Future<Uint8List> compressWithList(
    Uint8List list, {
    int quality = 80,
    int minWidth = 800,
    int minHeight = 800,
  }) async {
    // On web platforms, this is never called - we use web-specific methods instead
    throw UnsupportedError(
        'FlutterImageCompress is not supported on this platform');
  }
}
