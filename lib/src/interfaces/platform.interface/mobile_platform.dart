// mobile_platform.dart
import 'platform_interface.dart';

class MobilePlatform implements PlatformInterface {
  @override
  void openUrl(String url, String title) {
    throw UnimplementedError("This method is not implemented on mobile");
  }

  @override
  void openPdf(dynamic data, String title, [bool? isBlob]) {
    throw UnimplementedError("This method is not implemented on mobile");
  }
}

PlatformInterface platformImplementation() => MobilePlatform();
