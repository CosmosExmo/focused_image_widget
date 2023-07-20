import 'package:flutter/material.dart';

class ImageHolderViewModel with ChangeNotifier {
  ImageHolderViewModel({required this.images});
  final List<DecorationImage> images;
  int currentIndex = 0;
  DecorationImage get currentImage => images.elementAt(currentIndex);

  bool get nextButtonEnabled => currentIndex < images.length - 1;
  bool get previousButtonEnabled => currentIndex > 0;

  next() {
    if (currentIndex < images.length - 1) {
      currentIndex++;
      notifyListeners();
    }
  }

  previous() {
    if (currentIndex > 0) {
      currentIndex--;
      notifyListeners();
    }
  }
}
