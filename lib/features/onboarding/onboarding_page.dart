import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      icon: Icons.local_pharmacy,
      iconColor: Color(0xFF007BFF), // Trust Blue
      title: 'Find Medicines Nearby',
      description:
          'Search for medicines and find nearby pharmacies with real-time availability. We help you locate what you need quickly.',
    ),
    OnboardingSlide(
      icon: Icons.access_time,
      iconColor: Color(0xFF4CAF50), // Healthy Green
      title: 'Save Time & Effort',
      description:
          'No more visiting multiple pharmacies. Check availability, get directions, and call directly from the app.',
    ),
    OnboardingSlide(
      icon: Icons.notifications_active,
      iconColor: Color(0xFFFF9800), // Warning Orange
      title: 'Get Notified',
      description:
          'Request medicines that are out of stock. We\'ll notify you when they become available at nearby pharmacies.',
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/role-select');
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: EdgeInsets.all(isWide ? 24.0 : 16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _buildSlide(_slides[index], isWide);
                },
              ),
            ),

            // Page Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => _buildDot(index),
                ),
              ),
            ),

            // Next/Get Started Button
            Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 48.0 : 24.0,
                0,
                isWide ? 48.0 : 24.0,
                isWide ? 48.0 : 32.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _nextPage,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF), // Trust Blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(
                    _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide, bool isWide) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 48.0 : 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon/Illustration
          Container(
            padding: EdgeInsets.all(isWide ? 48 : 40),
            decoration: BoxDecoration(
              color: slide.iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              slide.icon,
              size: isWide ? 120 : 100,
              color: slide.iconColor,
            ),
          ),

          SizedBox(height: isWide ? 56 : 48),

          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
              fontSize: isWide ? 32 : 28,
              height: 1.2,
            ),
          ),

          SizedBox(height: isWide ? 24 : 20),

          // Description
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF6B7280),
              fontSize: isWide ? 20 : 18,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: isActive ? 32 : 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF007BFF) // Trust Blue
            : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingSlide {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const OnboardingSlide({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}
