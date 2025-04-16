import 'package:flutter/material.dart';
import 'package:frontend/utils/constants/image_strings.dart';
import 'package:frontend/utils/themes/text_thems.dart';
import 'package:frontend/views/pages/login_page.dart';
import 'package:frontend/views/widgets/profile_menu.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/constants/size.dart';
import '../../utils/constants/text_strings.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isNetworkImage = false;
  String image = TImages.user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: isNetworkImage? NetworkImage(image): AssetImage(image),
                      ),
                      SizedBox(height: TSizes.sm,),
                      TextButton(onPressed: (){}, child: Text(TTexts.changePfp)),
                    ],
                  ),
                ),
                SizedBox(height: TSizes.spaceBtwItems,),
                Divider(),
                SizedBox(height: TSizes.spaceBtwItems,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Profile Information", style: TTextTheme.darkTextTheme.headlineSmall,maxLines: 1, overflow: TextOverflow.ellipsis,)
                  ],
                ),
                SizedBox(height: TSizes.spaceBtwItems,),
                ProfileMenu(onPressed: (){}, title: "User ID", value: "1", icon: Iconsax.copy,),
                ProfileMenu(onPressed: (){}, title: "Full Name", value: "Habchi Abdennour"),
                ProfileMenu(onPressed: (){}, title: "email", value: "exemple@gmail.com"),
                SizedBox(height: TSizes.spaceBtwSections,),
                Center(
                  child:   TextButton(onPressed: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                  }, child: Text(TTexts.logout, style: TextStyle(color: Colors.red),)),
                )


              ],
            ),
          ),
        ),
      );
  }
}
