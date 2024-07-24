import 'package:chat_app/constants/color_constants.dart';
import 'package:flutter/material.dart';

import '../constants/size_constants.dart';
import '../constants/text_style_constants.dart';

class ChatListTile extends StatelessWidget {
  const ChatListTile(
      {super.key,
      required this.title,
      required this.subtitleText,
      required this.profilePic,
      required this.isOnline,
      required this.onTap});
  final String title;
  final Widget subtitleText;
  final String profilePic;
  final bool isOnline;
  final Function()? onTap;

  static const largeRadius = SizeConstants.largeRadius;
  static const smallPadding = SizeConstants.smallPadding;
  static final regularTextStyle = TextStyleConstants.regularTextStyle;
  static final semiBoldTextStyle = TextStyleConstants.semiBoldTextStyle;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorConstants.scaffoldBackgroundColor.withOpacity(0.2),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
            vertical: smallPadding - 4.0, horizontal: smallPadding + 2.0),
        title: Text(title, style: semiBoldTextStyle),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: largeRadius + 6.0,
              backgroundImage: NetworkImage(profilePic),
            ),
            Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOnline ? Colors.green : Colors.grey),
                ))
          ],
        ),
        subtitle: subtitleText,
        trailing: Text(
          "5:20 pm",
          style: regularTextStyle,
        ),
      ),
    );
  }
}
