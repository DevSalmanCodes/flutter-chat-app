import 'package:flutter/material.dart';

import '../constants/color_constants.dart';
import '../constants/size_constants.dart';

class CustomButton extends StatelessWidget {
   final double? width;
  final double? height;
  final Widget child;
  final VoidCallback? onTap;
  const CustomButton({super.key, this.width, this.height, required this.child, this.onTap});
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(SizeConstants.smallPadding + 6.0),
        width: width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              SizeConstants.smallRadius,
            ),
            color: ColorConstants.whiteColor.withOpacity(0.8)),
        child: child
      ),
    );
  }
}
