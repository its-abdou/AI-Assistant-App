import 'package:flutter/material.dart';
import 'package:frontend/utils/constants/colors.dart';
import 'package:frontend/utils/constants/image_strings.dart';
import 'package:frontend/utils/constants/size.dart';
import 'package:frontend/utils/constants/text_strings.dart';
import 'package:frontend/utils/themes/text_thems.dart';
import 'package:frontend/views/widgets/form_divider.dart';
import 'package:iconsax/iconsax.dart';

import '../widgets/google_sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool? isChecked = false;
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: TSizes.appBarHeight,
            left: TSizes.defaultSpace,
            right: TSizes.defaultSpace,
            bottom: TSizes.defaultSpace,
          ),
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
                            onChanged:
                                (bool? value) => setState(() {
                                  isChecked = value;
                                }),
                          ),
                          Text(TTexts.rememberMe),
                        ],
                      ),
                      SizedBox(height: TSizes.spaceBtwSections),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
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
                          child: Text(TTexts.signIn),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //Divider
              FormDivider(),// Your "or sign in with" text
              SizedBox(height: TSizes.spaceBtwSections),
              GoogleSignInButton(
                onPressed: () {
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
