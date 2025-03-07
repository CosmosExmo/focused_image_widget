import 'mobile_platform.dart' if (dart.library.html) 'web_platform.dart';
import 'platform_interface.dart';

PlatformInterface getPlatform() {
  return platformImplementation();
}
