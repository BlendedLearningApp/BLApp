import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'welcome_to_blapp'.tr,
      description: 'onboarding_desc_1'.tr,
      imagePath: 'assets/images/logo.png',
      color: AppTheme.primaryColor,
    ),
    OnboardingPage(
      title: 'interactive_learning'.tr,
      description: 'onboarding_desc_2'.tr,
      icon: Icons.video_library,
      color: AppTheme.accentColor,
    ),
    OnboardingPage(
      title: 'track_progress'.tr,
      description: 'onboarding_desc_3'.tr,
      icon: Icons.analytics,
      color: AppTheme.secondaryColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () => Get.offNamed('/login'),
                  child: Text(
                    'skip'.tr,
                    style: TextStyle(
                      color: AppTheme.textColor.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_pages[index]);
                },
              ),
            ),
            
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildPageIndicator(index),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        'previous'.tr,
                        style: TextStyle(
                          color: AppTheme.textColor.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 80),
                  
                  // Next/Get Started button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Get.offNamed('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      _currentPage < _pages.length - 1
                          ? 'next'.tr
                          : 'get_started'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon or Image
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: page.imagePath != null
                ? ClipOval(
                    child: Image.asset(
                      page.imagePath!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  )
                : Icon(
                    page.icon!,
                    size: 80,
                    color: page.color,
                  ),
          ),
          
          const SizedBox(height: 50),
          
          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textColor.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppTheme.primaryColor
            : AppTheme.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData? icon;
  final String? imagePath;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    this.icon,
    this.imagePath,
    required this.color,
  }) : assert(icon != null || imagePath != null, 'Either icon or imagePath must be provided');
}
