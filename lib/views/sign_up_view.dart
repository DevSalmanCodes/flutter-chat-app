import 'dart:io';

import 'package:chat_app/constants/validation_constants.dart';
import 'package:chat_app/providers/general_providers.dart';
import 'package:chat_app/utils/routes/route_names.dart';
import 'package:chat_app/utils/methods.dart';
import 'package:chat_app/view_models.dart/auth_view_model.dart';
import 'package:chat_app/widgets/loader.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/size_constants.dart';
import '../constants/text_style_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _file;

  void _onSignUp() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (_formKey.currentState!.validate()) {
      if (username.isEmpty || password.isEmpty || password.isEmpty) {
        showSnackBar(context, "Please fill all the fields");
      } else {
        ref.read(authViewModelProvider.notifier).signUp(
              username,
              email,
              password,
              _file == null ? null : File(_file!.path),
              context,
            );
      }
    }
  }

  _pickImage() async {
    final file = await pickImage(context);
    setState(() {
      _file = file;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isObsecure=ref.watch(obsecureProvider);
    final isLoading = ref.watch(authViewModelProvider);
    final width = SizeConstants.width(context);
    final height = SizeConstants.height(context);

    return Scaffold(
        body: SafeArea(
            child: SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: SizeConstants.smallPadding + 4.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.1,
                      ),
                      Text(
                        'Sign Up',
                        style: TextStyleConstants.boldTextStyle
                            .copyWith(fontSize: 25),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      CircleAvatar(
                        backgroundImage: _file == null
                            ? null
                            : Image.file(File(_file!.path)).image,
                        radius: 45,
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextButton(
                        onPressed: _pickImage,
                        child: Text(
                          "Upload Profile Picture",
                          style: TextStyleConstants.boldTextStyle,
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      CustomTextField(
                        labelText: 'Username',
                        controller: _usernameController,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      CustomTextField(
                          labelText: 'Email',
                          controller: _emailController,
                          validator: ValidationConstants.isValidEmail),
                      const SizedBox(
                        height: 20.0,
                      ),
                      CustomTextField(
                          labelText: 'Password',
                          controller: _passwordController,
                          validator: ValidationConstants.isValidPassword,
                        obsecureText: isObsecure,
                       onPressed: ()=> ref.read(obsecureProvider.notifier).state=!isObsecure,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      CustomButton(
                        onTap: _onSignUp,
                        width: width,
                        child: isLoading
                            ? const Loader()
                            : Text(
                                'SignUp',
                                style: TextStyleConstants.boldTextStyle
                                    .copyWith(color: Colors.black),
                              ),
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                      RichText(
                          text: TextSpan(
                              text: "Already have an account?",
                              style: TextStyleConstants.semiBoldTextStyle
                                  .copyWith(color: Colors.white),
                              children: [
                            TextSpan(
                              text: " Login",
                              style: TextStyleConstants.boldTextStyle
                                  .copyWith(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.pushNamed(
                                    context, RouteNames.login),
                            )
                          ])),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )));
  }
}
