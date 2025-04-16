// lib/views/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_providers.dart';
import 'package:frontend/utils/constants/image_strings.dart';
import 'package:frontend/utils/themes/text_thems.dart';
import 'package:frontend/views/pages/welcome_page.dart';
import 'package:frontend/views/widgets/profile_menu.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/constants/size.dart';
import '../../utils/constants/text_strings.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool isNetworkImage = false;
  String image = TImages.user;
  bool _isUpdating = false;

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading profile: ${error.toString()}'),
              ElevatedButton(
                onPressed: () => ref.read(authProvider.notifier).refreshUserProfile(),
                child: Text('Retry'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomePage()),
                        (route) => false,
                  );
                },
                child: Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          // User is not authenticated, redirect to welcome page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
                  (route) => false,
            );
          });
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is authenticated, display profile
        if (user.profileImage != null && user.profileImage!.isNotEmpty) {
          isNetworkImage = true;
          image = user.profileImage!;
        }

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
                          backgroundImage: isNetworkImage
                              ? NetworkImage(image) as ImageProvider
                              : AssetImage(image),
                        ),
                        SizedBox(height: TSizes.sm),
                        TextButton(
                            onPressed: _isUpdating ? null : () {

                            },
                            child: Text(TTexts.changePfp)
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: TSizes.spaceBtwItems),
                  Divider(),
                  SizedBox(height: TSizes.spaceBtwItems),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Profile Information",
                        style: TTextTheme.darkTextTheme.headlineSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                  SizedBox(height: TSizes.spaceBtwItems),
                  ProfileMenu(
                    onPressed: () {},
                    title: "User ID",
                    value: user.id,
                    icon: Iconsax.copy,
                  ),
                  ProfileMenu(
                    onPressed: () {},
                    title: "Full Name",
                    value: user.fullName,
                  ),
                  ProfileMenu(
                    onPressed: () {},
                    title: "Email",
                    value: user.email,
                  ),
                  SizedBox(height: TSizes.spaceBtwSections),
                  Center(
                    child: TextButton(
                      onPressed: _isUpdating ? null : () async {
                        setState(() {
                          _isUpdating = true;
                        });

                        await ref.read(authProvider.notifier).logout();

                        if (mounted) {
                          setState(() {
                            _isUpdating = false;
                          });

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => WelcomePage()),
                                (route) => false,
                          );
                        }
                      },
                      child: _isUpdating
                          ? CircularProgressIndicator(color: Colors.red)
                          : Text(
                        TTexts.logout,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}