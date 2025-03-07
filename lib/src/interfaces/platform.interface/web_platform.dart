import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as html;

import 'platform_interface.dart';

class WebPlatform implements PlatformInterface {
  @override
  void openUrl(String url, String title) {
    html.window.open(url, title);
  }

  @override
  void openPdf(dynamic data, String title, [bool? isBlob]) {
    if (isBlob == true) {
      final blobParts = JSArray<html.BlobPart>();
      blobParts.add((data as Uint8List).toJS);
      final blob =
          html.Blob(blobParts, html.BlobPropertyBag(type: 'application/pdf'));
      final url = html.URL.createObjectURL(blob);
      html.window.open(url, '_blank');
      return;
    }

    html.window.open(data, title);
  }
}

PlatformInterface platformImplementation() => WebPlatform();
