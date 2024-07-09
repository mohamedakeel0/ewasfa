import 'dart:io';
import 'package:ewasfa/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../assets/app_data.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Screens'])
@Summary('The Screen through which the user can zoom on a selected image')
class ZoomableImageScreen extends StatefulWidget {
  static const routeName = '/zoomable_image_screen';
  String? assetImagePath;
  String? networkImageUrl;
  String? filePath;
  ZoomableImageSourceType? sourceType;

  ZoomableImageScreen({
    super.key,
    this.assetImagePath,
    this.networkImageUrl,
    this.filePath,
    this.sourceType,
  });

  @override
  _ZoomableImageScreenState createState() => _ZoomableImageScreenState();
}

class _ZoomableImageScreenState extends State<ZoomableImageScreen> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  bool imageLoaded = false;

  ImageProvider getImageProvider() {
    if (widget.sourceType == ZoomableImageSourceType.asset &&
        widget.assetImagePath != null) {
      return AssetImage(widget.assetImagePath!);
    } else if (widget.sourceType == ZoomableImageSourceType.network &&
        widget.networkImageUrl != null) {
      return NetworkImage(widget.networkImageUrl!);
    } else if (widget.sourceType == ZoomableImageSourceType.file &&
        widget.filePath != null) {
      return FileImage(File(widget.filePath!));
    }
    return const AssetImage(
        "lib/assets/images/not_found.png"); // Default placeholder image
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var argsList = ModalRoute.of(context)!.settings.arguments as List;
    if (argsList[0] == ZoomableImageSourceType.network) {
      widget.sourceType = ZoomableImageSourceType.network;
      widget.networkImageUrl = argsList[1];
    }
    else if (argsList[0] == ZoomableImageSourceType.asset) {
      widget.sourceType = ZoomableImageSourceType.asset;
      widget.assetImagePath = argsList[1];
    }
    else if (argsList[0] == ZoomableImageSourceType.file) {
      widget.sourceType = ZoomableImageSourceType.file;
      widget.filePath = argsList[1];
    }
    imageLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    return imageLoaded? Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        pageTitle: 'Zoomable Image',
      ),
      body: Container(
        margin: EdgeInsets.only(top: query.size.height * 0.15),
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20.0),
          minScale: 0.5,
          maxScale: 4.0,
          onInteractionStart: (details) {
            _previousScale = _scale;
          },
          onInteractionUpdate: (details) {
            setState(() {
              _scale = _previousScale * details.scale;
            });
          },
          onInteractionEnd: (details) {
            setState(() {
              _previousScale = 1.0;
              _scale = 1.0;
            });
          },
          child: Center(
            child: Transform.scale(
              scale: _scale,
              child: Image(
                image: getImageProvider(),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    ): Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  LoadingIndicator(
                      indicatorType: Indicator.ballBeat,
                      colors: [primarySwatch]),
                ],
              ),
            ),
          );;
  }
}

enum ZoomableImageSourceType {
  asset,
  network,
  file,
}
