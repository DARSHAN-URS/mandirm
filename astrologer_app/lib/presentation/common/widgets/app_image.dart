import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class AppImage extends StatelessWidget {
  final String? assetPath;
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? color;
  final BlendMode? colorBlendMode;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Alignment alignment;

  const AppImage({
    super.key,
    this.assetPath,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.color,
    this.colorBlendMode,
    this.placeholder,
    this.errorWidget,
    this.alignment = Alignment.center,
  }) : assert(assetPath != null || imageUrl != null, 'Either assetPath or imageUrl must be provided');

  const AppImage.asset(
    String path, {
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Color? color,
    BlendMode? colorBlendMode,
    Widget? placeholder,
    Widget? errorWidget,
    Alignment alignment = Alignment.center,
  }) : this(
          key: key,
          assetPath: path,
          width: width,
          height: height,
          fit: fit,
          borderRadius: borderRadius,
          color: color,
          colorBlendMode: colorBlendMode,
          placeholder: placeholder,
          errorWidget: errorWidget,
          alignment: alignment,
        );

  const AppImage.network(
    String url, {
    Key? key,
    String? fallbackAsset,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Color? color,
    BlendMode? colorBlendMode,
    Widget? placeholder,
    Widget? errorWidget,
    Alignment alignment = Alignment.center,
  }) : this(
          key: key,
          imageUrl: url,
          assetPath: fallbackAsset,
          width: width,
          height: height,
          fit: fit,
          borderRadius: borderRadius,
          color: color,
          colorBlendMode: colorBlendMode,
          placeholder: placeholder,
          errorWidget: errorWidget,
          alignment: alignment,
        );

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    final targetUrl = _resolveUrl();

    if (AppConstants.enableCdnImages && targetUrl != null && targetUrl.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: targetUrl,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        color: color,
        colorBlendMode: colorBlendMode,
        placeholder: (context, url) =>
            placeholder ??
            Container(
              width: width,
              height: height,
              color: const Color(0xFFF7F2E8),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD97706)),
                ),
              ),
            ),
        errorWidget: (context, url, error) {
          if (assetPath != null) {
            return Image.asset(
              assetPath!,
              width: width,
              height: height,
              fit: fit,
              alignment: alignment,
              color: color,
              colorBlendMode: colorBlendMode,
              errorBuilder: (_, __, ___) => _defaultErrorWidget(),
            );
          }
          return errorWidget ?? _defaultErrorWidget();
        },
      );
    } else if (assetPath != null) {
      imageWidget = Image.asset(
        assetPath!,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        color: color,
        colorBlendMode: colorBlendMode,
        errorBuilder: (_, __, ___) => errorWidget ?? _defaultErrorWidget(),
      );
    } else {
      imageWidget = _defaultErrorWidget();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  String? _resolveUrl() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl;
    }
    if (assetPath != null && assetPath!.isNotEmpty) {
      return AppConstants.cdnUrl(assetPath!);
    }
    return null;
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF7F2E8),
      child: const Icon(
        Icons.auto_awesome,
        color: Color(0xFFD97706),
        size: 24,
      ),
    );
  }
}
