import 'package:chat_app/constants/color_constants.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
    final String labelText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool? obsecureText;
  final VoidCallback? onPressed;
  const CustomTextField(
      {super.key,
      required this.labelText,
      required this.controller,
      this.validator, this.obsecureText, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obsecureText ?? false,
      validator: validator,
      controller: controller,
      style: const TextStyle(color: ColorConstants.whiteColor),
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: ColorConstants.whiteColor),
        suffixIcon: IconButton(onPressed:onPressed,icon: Icon(obsecureText ?? false ? Icons.visibility : Icons.visibility_off)),
        border: const OutlineInputBorder(),
        labelText: labelText,
      ),
    );
  }
}
