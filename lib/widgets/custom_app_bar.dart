// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/constants/color_constants.dart';

import '../constants/text_style_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final String title;
  final double? fontSize;
  final List<Widget>? actionItemsList;
  final String? lastSeen;
  const CustomAppBar({
    Key? key,
    this.leading,
    required this.title,
    this.fontSize,
    this.actionItemsList,
    this.lastSeen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        leading: leading,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        backgroundColor: ColorConstants.scaffoldBackgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyleConstants.semiBoldTextStyle.copyWith(
                        fontSize: fontSize ?? 25.0,
                        fontWeight: FontWeight.bold)),
                if (lastSeen != null)
                  Text(
                    lastSeen!,
                    style: TextStyleConstants.regularTextStyle,
                  )
              ],
            ),
          ],
        ),
        actions: actionItemsList);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
