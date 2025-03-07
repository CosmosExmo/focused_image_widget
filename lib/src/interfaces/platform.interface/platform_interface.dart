abstract class PlatformInterface {
  void openUrl(String url, String title);
  void openPdf(dynamic data, String title, [bool? isBlob]);
}
