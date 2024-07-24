import 'package:chat_app/constants/color_constants.dart';
import 'package:chat_app/constants/fonts_constants.dart';
import 'package:flutter/material.dart';

class TextStyleConstants {
  static TextStyle boldTextStyle = const TextStyle(
      color: ColorConstants.whiteColor,
      fontFamily: FontsConstants.poppinsBold,
      fontSize: 18.0,
      fontWeight: FontWeight.bold);
  static TextStyle semiBoldTextStyle = const TextStyle(
      color: ColorConstants.whiteColor,
      fontFamily: FontsConstants.poppinsSemiBold,
      fontSize: 14.0,
      fontWeight: FontWeight.w600);

  static TextStyle mediumTextStyle = const TextStyle(
      color: ColorConstants.whiteColor,
      fontFamily: FontsConstants.poppinsMedium,
      fontSize: 14.0,
      fontWeight: FontWeight.w500);

  static TextStyle regularTextStyle = const TextStyle(
      color: ColorConstants.whiteColor,
      fontFamily: FontsConstants.poppinsRegular,
      fontSize: 14.0,
      fontWeight: FontWeight.w400);
}
