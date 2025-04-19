// lib/views/pages/signUp_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_providers.dart';
import 'package:frontend/utils/constants/colors.dart';
import 'package:frontend/utils/constants/size.dart';
import 'package:frontend/utils/constants/text_strings.dart';
import 'package:frontend/utils/themes/text_thems.dart';
import 'package:frontend/views/pages/chat_page.dart';
import 'package:frontend/views/pages/previous_chats_page.dart';
import 'package:frontend/views/pages/profile_page.dart';
import 'package:iconsax/iconsax.dart';

import '../widgets/form_divider.dart';
import '../widgets/google_sign_in_button.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerPass = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  bool? isChecked = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPass.dispose();
    controllerName.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (controllerName.text.isEmpty ||
        controllerEmail.text.isEmpty ||
        controllerPass.text.isEmpty) {
      setState(() {
        _errorMessage = "Please fill all fields";
      });
      return;
    }

    if (isChecked != true) {
      setState(() {
        _errorMessage = "Please accept the terms and conditions";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).signup(
        controllerName.text.trim(),
        controllerEmail.text.trim(),
        controllerPass.text,
      );

      // On successful signup, navigate to profile page
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatPage(),
          ),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: TSizes.spaceBtwSections),
              // Title
              Text(
                TTexts.signupTitle,
                style: TTextTheme.darkTextTheme.headlineMedium,
              ),
              SizedBox(height: TSizes.spaceBtwSections),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: TSizes.spaceBtwSections,
                ),
                child: Form(
                  child: Column(
                    children: [
                      //fullName
                      TextField(
                        controller: controllerName,
                        decoration: InputDecoration(
                          hintText: TTexts.fullName,
                          prefixIcon: Icon(Iconsax.user),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: TSizes.spaceBtwItems),

                      TextField(
                        controller: controllerEmail,
                        decoration: InputDecoration(
                          hintText: TTexts.email,
                          prefixIcon: Icon(Iconsax.direct_right),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: TSizes.spaceBtwItems),

                      TextField(
                        obscureText: true,
                        controller: controllerPass,
                        decoration: InputDecoration(
                          hintText: TTexts.password,
                          prefixIcon: Icon(Iconsax.password_check),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: TSizes.spaceBtwSections),

                      Row(
                        children: [
                          SizedBox(
                            width:24,
                            height: 24,
                            child:  Checkbox(
                              value: isChecked,
                              activeColor: TColors.primary,
                              onChanged:
                                  (bool? value) => setState(() {
                                isChecked = value;
                              }),
                            ),
                          ),
                          SizedBox(width: TSizes.spaceBtwItems),
                          Text.rich(
                              TextSpan(children: [
                                TextSpan(text: '${TTexts.iAgreeTo} ', style: TTextTheme.darkTextTheme.bodySmall),
                                TextSpan(text: '${TTexts.privacyPolicy}', style: TTextTheme.darkTextTheme.bodyMedium!.apply(color: TColors.white, decoration: TextDecoration.underline, decorationColor: TColors.white)),

                                TextSpan(text: '  ${TTexts.and} ', style: TTextTheme.darkTextTheme.bodySmall),
                                TextSpan(text: '${TTexts.termsOfUse}', style: TTextTheme.darkTextTheme.bodyMedium!.apply(color: TColors.white, decoration: TextDecoration.underline, decorationColor: TColors.white)),
                              ])
                          ),
                        ],
                      ),
                      // Error message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(height: TSizes.spaceBtwSections),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            foregroundColor: TColors.light,
                            backgroundColor: TColors.primary,
                            side: const BorderSide(color: TColors.primary),
                            padding: const EdgeInsets.symmetric(
                              vertical: TSizes.buttonHeight,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              color: TColors.textWhite,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                TSizes.buttonRadius,
                              ),
                            ),

                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(TTexts.createAccount),
                        ),
                      ),
                      SizedBox(height: TSizes.spaceBtwSections),
                      FormDivider(),
                      SizedBox(height: TSizes.spaceBtwSections),
                      GoogleSignInButton(
                        onPressed: () {
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}