import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar(
    this.url, {
    Key? key,
    this.width = 30,
    this.height,
    this.fit,
    this.borderRadius,
  }) : super(key: key);
  final String url;
  final double width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    var placeholder = Image.asset(
      'imgs/avatar-default.png',
      width: width,
      height: height,
    );
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(2),
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (ctx, url) => placeholder,
        errorWidget: (ctx, url, err) => placeholder,
      ),
    );
  }
}
