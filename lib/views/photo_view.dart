import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart' as photo;
class PhotoView extends StatelessWidget {
  final String imageUrl;
  const PhotoView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: photo.PhotoView(imageProvider: NetworkImage(imageUrl,),)
      )),
    );
  }
}
