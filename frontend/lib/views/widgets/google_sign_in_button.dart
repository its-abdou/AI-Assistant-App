import 'package:flutter/material.dart';
import 'package:frontend/utils/constants/size.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const GoogleSignInButton({
    Key? key,
    required this.onPressed,
    this.text = 'Sign in with Google',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Image.asset(
          'assets/images/google_logo.png', // Make sure to add this image to your assets
          height: 24,
          width: 24,
        ),
        label: Text(text),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: TSizes.buttonHeight /1.5),
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TSizes.buttonRadius),
          ),
        ),
      ),
    );
  }
}