import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:http/http.dart' as http;

import '../assets/app_data.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Widgets'])
@Summary('An image loader widget that displays a fallbackImage after a timer expires for the original image to load')
class ImageLoader extends StatefulWidget {
  final String imageUrl;
  final Duration timeoutDuration;
  final Widget fallbackImage;

  const ImageLoader({
    required this.imageUrl,
    required this.timeoutDuration,
    required this.fallbackImage,
  });

  @override
  _ImageLoaderState createState() => _ImageLoaderState();
}

class _ImageLoaderState extends State<ImageLoader> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Start loading the image
    _loadImage();
  }

  void _loadImage() async {
    try {
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Transform.scale(
            scale: 0.5,
            child: LoadingIndicator(indicatorType: Indicator.ballBeat, colors: [primarySwatch.shade500, primarySwatch.shade300]),
          )
        : _hasError
            ? widget.fallbackImage
            : Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Transform.scale(
                    scale: 0.5,
                    child: const LoadingIndicator(indicatorType: Indicator.ballBeat, colors: [primarySwatch]),
                  );
                },
                errorBuilder: (context, error, stackTrace) => widget.fallbackImage,
              );
  }
}

