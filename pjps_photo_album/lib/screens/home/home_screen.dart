import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryGold, AppColors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Logo
                // Circular Logo with PJPS text inside
                Container(
                  width: 120, // increased size
                  height: 120, // increased size
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white, // white circle background
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo image
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // PJPS text under the logo
                      const Text(
                        'PJPS',
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                const Text(
                  'Pope John Paul II Major Seminary, Photo Album',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Hero Image
//                Container(
//                  height: 200,
//                  margin: const EdgeInsets.symmetric(horizontal: 24),
//                  decoration: BoxDecoration(
//                    borderRadius: BorderRadius.circular(20),
//                    color: Colors.white.withOpacity(0.3),
//                  ),
//                  child: const Center(
//                    child: Icon(
//                      Icons.photo_library,
//                      size: 80,
//                      color: Colors.white70,
// /                   ),
//                  ),
//                ),
                Container(
                  height: 220,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/school_building.jpg',
                          fit: BoxFit.cover,
                        ),

                        // Dark gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // Optional label on image
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Text(
                            "Pope John Paul II Major Seminary",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black54,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Description
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Column(
                    children: [
                      Text(
                        'Digital Photo Album',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 12, 12, 12),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Access your class photos and staff directory all in one place.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(179, 12, 12, 12),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Login Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CustomButton(
                    text: 'Login to Continue',
                    onPressed: () {
                      context.push('/login');
                    },
                    gradient: const LinearGradient(
                      colors: [Colors.white, AppColors.primaryGoldLight],
                    ),
                    textColor: AppColors.black,
                  ),
                ),

                const SizedBox(height: 20),

                // Footer
                Text(
                  //'© 2024 PJPS',
                  '© ${DateTime.now().year} PJPS',
                  //'© final now = DateTime.now(); + now.year PJPS',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),

// Footer
                //               const Text(
                //'© 2024 PJPS',
                //               '© ${DateTime.now().year} PJPS',
                //'© final now = DateTime.now(); + now.year PJPS',
                //             style: TextStyle(
                //             fontSize: 12,
                //           color: Colors.white60,
                //       ),
                //   ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
