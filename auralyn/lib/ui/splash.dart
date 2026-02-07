import 'package:auralyn/core/app_colors.dart';
import 'package:auralyn/core/app_fonts.dart';
import 'package:auralyn/ui/home.dart';
import 'package:flutter/material.dart';
import '../core/images.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15), // start slightly lower
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppImages.splash, fit: BoxFit.cover),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 300,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF0B021A),
                    const Color(0xFF1A063F),
                    const Color(0xFF1A063F).withOpacity(0.7),
                    const Color(0xFF1A063F).withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // ✅ Animate only this group
          Positioned(
            left: 15,
            right: 15,
            bottom: 70,
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Welcome to",
                      style: AppFonts.barlowCondensed.copyWith(
                        color: AppColors.whiteColor,
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                        height: 0.95,
                      ),
                    ),
                    Text(
                      "Auralyn",
                      style: AppFonts.barlowCondensed.copyWith(
                        color: AppColors.greenColor,
                        fontSize: 70,
                        fontWeight: FontWeight.bold, height: 0.95,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Your personal space for sound",
                      style: AppFonts.barlowCondensed.copyWith(
                        color: AppColors.whiteColor,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.withAlpha(200),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Start Listening',
                          style: AppFonts.poppins.copyWith(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
