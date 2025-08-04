import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Convert a web image URL to base64
Future<String> getWebImageBase64(String imageUrl) async {
  try {
    if (imageUrl.startsWith('blob:')) {
      // Handle blob URL
      final bytes = await _fetchBlob(imageUrl);
      return base64Encode(bytes);
    } else if (imageUrl.startsWith('data:')) {
      // Handle data URL (already base64)
      final String base64String = imageUrl.split(',')[1];
      return base64String;
    } else {
      // Handle regular URL
      final bytes = await _fetchImageBytes(imageUrl);
      return base64Encode(bytes);
    }
  } catch (e) {
    print('Error converting web image to base64: $e');
    return '';
  }
}

// Fetch blob URL as bytes
Future<Uint8List> _fetchBlob(String blobUrl) async {
  final response = await html.HttpRequest.request(
    blobUrl,
    responseType: 'blob',
  );

  final blob = response.response as html.Blob;
  return _blobToBytes(blob);
}

// Convert blob to bytes
Future<Uint8List> _blobToBytes(html.Blob blob) {
  final reader = html.FileReader();
  final completer = Completer<Uint8List>();

  reader.onLoadEnd.listen((event) {
    if (reader.readyState == html.FileReader.DONE) {
      final Uint8List result = reader.result as Uint8List;
      completer.complete(result);
    }
  });

  reader.readAsArrayBuffer(blob);
  return completer.future;
}

// Fetch an image URL and return bytes
Future<Uint8List> _fetchImageBytes(String imageUrl) async {
  final response = await html.HttpRequest.request(
    imageUrl,
    responseType: 'blob',
  );

  final blob = response.response as html.Blob;
  return _blobToBytes(blob);
}

// Resize an image using HTML canvas
Future<Uint8List> resizeWebImage(Uint8List imageBytes, int targetWidth,
    {int? targetHeight, int quality = 90}) async {
  final completer = Completer<Uint8List>();

  // Create an image element
  final img = html.ImageElement();

  // Create a blob URL for the image
  final blob = html.Blob([imageBytes]);
  final url = html.Url.createObjectUrl(blob);

  // When the image is loaded, resize it using canvas
  img.onLoad.listen((_) {
    // Calculate height maintaining aspect ratio if not explicitly given
    final int height =
        targetHeight ?? (img.height! * targetWidth / img.width!).round();

    // Create a canvas
    final canvas = html.CanvasElement(width: targetWidth, height: height);
    final ctx = canvas.context2D;

    // Draw the image on the canvas
    ctx.drawImageScaled(img, 0, 0, targetWidth, height);

    // Convert the canvas to blob
    canvas.toBlob('image/jpeg', quality / 100).then((blob) {
      // Convert the blob to bytes
      _blobToBytes(blob).then((bytes) {
        // Clean up
        html.Url.revokeObjectUrl(url);
        completer.complete(bytes);
      });
    });
  });

  // Handle errors
  img.onError.listen((event) {
    html.Url.revokeObjectUrl(url);
    completer.completeError('Failed to load image');
  });

  // Set the source to start loading
  img.src = url;

  return completer.future;
}

// Create a very small JPEG thumbnail
Future<Uint8List> createTinyJpeg(Uint8List sourceBytes,
    {int width = 50, int quality = 70}) async {
  // Just use resizeWebImage with small dimensions
  return resizeWebImage(sourceBytes, width, quality: quality);
}

// Get bytes from a web image path (URL or base64)
Future<Uint8List> getWebImageBytes(String imagePath) async {
  try {
    if (imagePath.startsWith('data:')) {
      // It's a base64 image
      final base64String = imagePath.split(',')[1];
      return base64Decode(base64String);
    } else if (imagePath.startsWith('blob:')) {
      // It's a blob URL
      return _fetchBlob(imagePath);
    } else {
      // It's a regular URL
      return _fetchImageBytes(imagePath);
    }
  } catch (e) {
    print('Error getting web image bytes: $e');
    return Uint8List(0);
  }
}
