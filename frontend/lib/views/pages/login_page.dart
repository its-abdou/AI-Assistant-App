import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_providers.dart';
import 'package:frontend/utils/constants/colors.dart';
import 'package:frontend/utils/constants/image_strings.dart';
import 'package:frontend/utils/constants/size.dart';
import 'package:frontend/utils/constants/text_strings.dart';
import 'package:frontend/utils/themes/text_thems.dart';
import 'package:frontend/views/pages/chat_page.dart';

import 'package:iconsax/iconsax.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool? isChecked = false;
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerPass = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (controllerEmail.text.isEmpty || controllerPass.text.isEmpty) {
      setState(() {
        _errorMessage = "Please enter both email and password";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .login(controllerEmail.text.trim(), controllerPass.text);

      // On successful login, navigate to profile page
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ChatPage()),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Column(
                //logo , Header , subHeader
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(height: 150, image: AssetImage(TImages.logo)),
                  Text(
                    TTexts.loginTitle,
                    style: TTextTheme.darkTextTheme.headlineMedium,
                  ),
                  SizedBox(height: TSizes.sm),
                  Text(
                    TTexts.loginSubTitle,
                    style: TTextTheme.darkTextTheme.bodyMedium,
                  ),
                ],
              ),
              // Form
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: TSizes.spaceBtwSections,
                ),
                child: Form(
                  child: Column(
                    children: <Widget>[
                      // email
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
                      //password
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
                      SizedBox(height: TSizes.spaceBtwItems / 2),
                      // Remember ME
                      Row(
                        children: [
                          Checkbox(
                            value: isChecked,
                            activeColor: TColors.primary,
                            onChanged:
                                (bool? value) => setState(() {
                                  isChecked = value;
                                }),
                          ),
                          Text(TTexts.rememberMe),
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
                          onPressed: _isLoading ? null : _login,
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
                          child:
                              _isLoading
                                  ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(TTexts.signIn),
                        ),
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
