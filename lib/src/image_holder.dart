part of focused_image_widget;

class ImageHolder extends StatefulWidget {
  final DecorationImage? image;
  final Widget child;
  final String? imageUrl;

  const ImageHolder({
    Key? key,
    required this.child,
    this.image,
    this.imageUrl,
  }) : super(key: key);

  @override
  _ImageHolderState createState() => _ImageHolderState();
}

class _ImageHolderState extends State<ImageHolder> {
  GlobalKey containerKey = GlobalKey();
  Offset childOriginOffset = Offset(0, 0);
  Offset childEndOffset = Offset(0, 0);
  late Size imageContainerSize;
  late Size childSize;

  void _getOffset() {
    RenderBox childRenderBox =
        containerKey.currentContext!.findRenderObject() as RenderBox;
    Size childSize = childRenderBox.size;
    Offset childOffset = childRenderBox.localToGlobal(Offset.zero);

    final windowsSize = MediaQuery.of(context).size;

    final screenWidth = windowsSize.width;
    final screenHeight = windowsSize.height;

    final imageContainerSize = Size(screenWidth * 0.9, screenHeight * 0.9);

    final horizontalCenter = (screenWidth / 2) - (imageContainerSize.width / 2);
    final verticalCenter = (screenHeight / 2) - (imageContainerSize.height / 2);

    final centerOffset = Offset(horizontalCenter, verticalCenter);

    setState(() {
      this.childOriginOffset = childOffset;
      this.childEndOffset = centerOffset;
      this.imageContainerSize = imageContainerSize;
      this.childSize = childSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: containerKey,
      onTap: widget.image != null ? () => openMenu(context) : null,
      child: widget.child,
    );
  }

  Future openMenu(BuildContext context) async {
    if (kIsWeb && widget.imageUrl != null) {
      final _imageName = DateTime.now().millisecondsSinceEpoch;
      html.window.open(widget.imageUrl!, _imageName.toString());
      return null;
    }

    _getOffset();
    return await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 100),
        pageBuilder: (context, animation, secondaryAnimation) {
          animation = Tween(begin: 0.0, end: 1.0).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: _ImageHolderWidget(
              image: widget.image,
              childOriginOffset: childOriginOffset,
              childEndOffset: childEndOffset,
              imageContainerSize: imageContainerSize,
              childSize: childSize,
            ),
          );
        },
        fullscreenDialog: true,
        opaque: false,
      ),
    );
  }
}

class _ImageHolderWidget extends StatelessWidget {
  final DecorationImage? image;
  final Offset childOriginOffset;
  final Offset childEndOffset;
  final Size imageContainerSize;
  final Size childSize;

  const _ImageHolderWidget({
    Key? key,
    required this.image,
    required this.childOriginOffset,
    required this.childEndOffset,
    required this.imageContainerSize,
    required this.childSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(color: Colors.black.withOpacity(0.7)),
              ),
            ),
            TweenAnimationBuilder<Offset>(
              tween: Tween(begin: childOriginOffset, end: childEndOffset),
              duration: Duration(milliseconds: 200),
              builder: (context, value, _) {
                return Positioned(
                  top: value.dy,
                  left: value.dx,
                  child: TweenAnimationBuilder<Size>(
                    duration: const Duration(milliseconds: 200),
                    tween: Tween(begin: childSize, end: imageContainerSize),
                    builder: (context, value1, _) {
                      return InteractiveViewer(
                        boundaryMargin: EdgeInsets.all(20),
                        minScale: 0.1,
                        maxScale: 3.0,
                        child: Container(
                          width: value1.width,
                          height: value1.height,
                          decoration: BoxDecoration(
                            image: image,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Positioned(
              top: 45,
              right: 60,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(Icons.close),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
