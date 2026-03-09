import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/features/admin/pagination/main_screen_a.dart';
import 'package:raising_india/features/on_boarding/screens/welcome_screen.dart';
import 'package:raising_india/features/user/main_screen_u.dart';
import '../constant/ConPath.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _backgroundController;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    // 1. Setup Main Animation
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // CRITICAL FIX: Rebuild widget when animation finishes
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
      }
    });

    // 2. Setup Background Animation
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    // 3. Define Tweens
    _logoScale = CurvedAnimation(
      parent: _mainController,
      curve: Interval(0.0, 0.6, curve: Curves.bounceOut),
    );

    _textOpacity = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    ));

    _mainController.forward();

    // 4. Trigger Data Loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthService>();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Layer 1: Background
          _buildBaseGradient(),
          _buildFloatingShapes(),

          // Layer 2: Logic & Content
          Consumer<AuthService>(
            builder: (context, authService, _) {
              // CHECK: Is animation running OR is data still loading?
              // If EITHER is true, we stay on the Splash Screen.
              bool showSplash = _mainController.isAnimating || authService.isLoading;

              if (showSplash) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _logoScale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withOpacity(0.1),
                              ),
                            ),
                            Image.asset(appLogo, width: 140, height: 140),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      FadeTransition(
                        opacity: _textOpacity,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            children: [
                              Text(
                                'Rising Distributor',
                                style: simple_text_style().copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                  color: const Color(0xFF1A237E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 40,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Only reached when Animation is DONE AND Loading is DONE
              return _getDirectScreen(authService);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBaseGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Colors.white,
            Color(0xFFF0F7FF),
            Color(0xFFE3F2FD),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingShapes() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -50 + (_backgroundController.value * 30),
              left: -50 + (_backgroundController.value * 20),
              child: _circularBlur(200, Colors.blue.withOpacity(0.15)),
            ),
            Positioned(
              bottom: -20 - (_backgroundController.value * 40),
              right: -20 - (_backgroundController.value * 20),
              child: _circularBlur(250, Colors.blueAccent.withOpacity(0.1)),
            ),
          ],
        );
      },
    );
  }

  Widget _circularBlur(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _getDirectScreen(AuthService authService) {
    if (authService.isAdmin) return const MainScreenA();
    if (authService.isCustomer) return const MainScreenU();
    return const WelcomeScreen();
  }
}
