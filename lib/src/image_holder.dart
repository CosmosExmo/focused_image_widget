part of focused_image_widget;

class ImageHolder extends StatefulWidget {
  final List<DecorationImage> images;
  final Widget child;
  final bool closeOnTap;
  final void Function()? onEnd;
  final void Function()? onClose;

  const ImageHolder({
    Key? key,
    required this.child,
    required this.images,
    this.closeOnTap = false,
    this.onEnd,
    this.onClose,
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
  bool get closeOnTap => widget.closeOnTap;
  void Function()? get onEnd => widget.onEnd;
  void Function()? get onClose => widget.onClose;
  List<DecorationImage> get images => widget.images;


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
    return ChangeNotifierProvider(
        create: (context) => ImageHolderViewModel(images: images),
        builder: (context, _) {
          return GestureDetector(
            key: containerKey,
            onTap: () => openMenu(context),
            child: widget.child,
          );
        });
  }

  Future openMenu(BuildContext context) async {
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
              childOriginOffset: childOriginOffset,
              childEndOffset: childEndOffset,
              imageContainerSize: imageContainerSize,
              childSize: childSize,
              closeOnTap: closeOnTap,
              onEnd: onEnd,
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
  final Offset childOriginOffset;
  final Offset childEndOffset;
  final Size imageContainerSize;
  final Size childSize;
  final bool closeOnTap;
  final void Function()? onEnd;

  const _ImageHolderWidget({
    Key? key,
    required this.childOriginOffset,
    required this.childEndOffset,
    required this.imageContainerSize,
    required this.childSize,
    required this.closeOnTap,
    required this.onEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    popper() {
      Navigator.pop(context);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GestureDetector(
              onTap: closeOnTap ? () => popper() : null,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(color: Colors.black.withOpacity(0.7)),
              ),
            ),
            TweenAnimationBuilder<Offset>(
              tween: Tween(begin: childOriginOffset, end: childEndOffset),
              onEnd: onEnd,
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
                        child: GestureDetector(
                          onTap: () => popper(),
                          child: Container(
                            width: value1.width,
                            height: value1.height,
                            decoration: BoxDecoration(
                              image: context
                                  .watch<ImageHolderViewModel>()
                                  .currentImage,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Selector<ImageHolderViewModel, bool>(
                builder: (context, enabled, child) {
                  if (enabled) {
                    return Positioned(
                      bottom: 100,
                      right: 45,
                      child: InkWell(
                        onTap: () =>
                            context.read<ImageHolderViewModel>().next(),
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Icon(Icons.arrow_forward),
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
                selector: (_, model) => model.nextButtonEnabled),
            Selector<ImageHolderViewModel, bool>(
                builder: (context, enabled, child) {
                  if (enabled) {
                    return Positioned(
                      bottom: 100,
                      left: 45,
                      child: InkWell(
                        onTap: () =>
                            context.read<ImageHolderViewModel>().previous(),
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Icon(Icons.arrow_back),
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
                selector: (_, model) => model.previousButtonEnabled),
            Positioned(
              bottom: 45,
              right: 45,
              child: InkWell(
                onTap: () => popper(),
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
