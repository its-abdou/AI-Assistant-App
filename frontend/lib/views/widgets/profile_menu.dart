import 'package:flutter/material.dart';
import 'package:frontend/utils/themes/text_thems.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/constants/size.dart';

class ProfileMenu extends StatefulWidget {
  const ProfileMenu({super.key, required this.onPressed, required this.title, required this.value ,  this.icon = Iconsax.arrow_right_34});

  final IconData icon;
  final VoidCallback onPressed;
  final String title , value;


  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems),
        child: Row(
          children: [
            Expanded(flex: 3,child: Text(widget.title, style:  TTextTheme.darkTextTheme.bodySmall,overflow: TextOverflow.ellipsis,)),
            Expanded(flex: 5,child: Text(widget.value, style:  TTextTheme.darkTextTheme.bodyMedium,overflow: TextOverflow.ellipsis,)),
            Expanded(child: Icon(widget.icon, size: 18,)),
          ],
        ),
      ),
    );
  }
}
