import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_sync/features/landing/widgets/features_section.dart';
import 'package:health_sync/features/landing/widgets/hero_section.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();
    // Trigger animation after a short delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _startAnimation = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final size = MediaQuery.of(context).size;

    // Logo Dimensions
    final double initialSize = size.width * 0.6;
    const double finalSize = 40.0;

    // Positions
    final double initialTop = size.height / 2 - initialSize / 2;
    final double initialLeft = size.width / 2 - initialSize / 2;

    const double finalTop = 50.0; // SafeArea equivalent
    const double finalLeft = 24.0; // Padding

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          // Main Content (Fades in)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 800),
            opacity: _startAnimation ? 1.0 : 0.0,
            curve: Curves.easeIn,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 100), // Space for navbar/logo
              child: Column(
                children: const [
                  HeroSection(),
                  FeaturesSection(),
                  SizedBox(height: 48), // Footer padding
                ],
              ),
            ),
          ),

          // Animated Logo
          AnimatedPositioned(
            duration: const Duration(milliseconds: 2000),
            curve: Curves.easeInOutCubic,
            top: _startAnimation ? finalTop : initialTop,
            left: _startAnimation ? finalLeft : initialLeft,
            width: _startAnimation ? finalSize : initialSize,
            height: _startAnimation ? finalSize : initialSize,
            child: Image.asset('assets/logo/logo.png', fit: BoxFit.contain),
          ),

          // Animated Text (HealthSync)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 2000),
            curve: Curves.easeInOutCubic,
            top: finalTop + 4, // Align roughly with logo center vertically
            left: _startAnimation
                ? finalLeft + finalSize + 12
                : size.width / 2 + initialSize, // Start off-screen or faded
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _startAnimation ? 1.0 : 0.0,
              child: Text(
                'HealthSync',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          // Navbar Actions (Fade in with content)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            top: 40,
            right: 24,
            child: AnimatedOpacity(
              opacity: _startAnimation ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: IconButton(
                onPressed: () => context.push('/login'),
                icon: Icon(
                  Icons.login_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
