import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';
import '../../utils/constants/text_strings.dart';
import '../../utils/themes/text_thems.dart';

class FormDivider extends StatelessWidget {
  const FormDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center ,children: [
      Flexible(child: Divider(color: TColors.darkGrey, thickness: 0.7, indent: 60, endIndent: 5,)),
      Text(TTexts.orSignInWith,style: TTextTheme.darkTextTheme.labelMedium ),
      Flexible(child: Divider(color: TColors.darkGrey, thickness: 0.7, indent: 5, endIndent: 60,)),
    ],);
  }
}
