// lib/views/pages/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/constants/image_strings.dart';
import 'package:frontend/views/pages/login_page.dart';
import 'package:frontend/views/pages/profile_page.dart';
import 'package:frontend/views/pages/signUp_page.dart';
import 'package:frontend/views/widgets/build_dot.dart';
import 'package:frontend/providers/auth_providers.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  @override
  void initState() {
    FlutterNativeSplash.remove();

    // Check if user is already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });

    super.initState();
  }

  Future<void> _checkAuthentication() async {
    final authRepo = ref.read(authRepositoryProvider);
    final isAuthenticated = await authRepo.isAuthenticated();

    if (isAuthenticated && mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background dots
          Positioned(
            top: 150,
            left: 30,
            child: BuildDot(color:Colors.deepPurple.shade200,size: 20),
          ),
          Positioned(
            top: 200,
            right: 60,
            child: BuildDot(color:Colors.purple, size:  15),
          ),
          Positioned(
            bottom: 250,
            right: 40,
            child: BuildDot(color:Colors.teal, size:18),
          ),
          Positioned(
            bottom: 180,
            left: 60,
            child: BuildDot(color:Colors.yellow, size:  16),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 200),

                  // App logo
                  Image(height: 160, image: AssetImage(TImages.logo)),

                  // Headline text
                  FittedBox(
                    child: Text(
                      'Explore',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  FittedBox(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'infinite\ncapabilities\n',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade300,
                            ),
                          ),
                          TextSpan(
                            text: 'of AI',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Login button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage())
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Register button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupPage())
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}