import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // --- Onboarding Data ---
  final List<Map<String, String>> _pages = [
    {
      "title": "Welcome to Hydrobuddy",
      "subtext": "Your personalised water tracker.",
      "image": "assets/logo.png", // Replace with your asset
    },
    {
      "title": "Track Water",
      "subtext": "Monitor your daily hydration progress in real time.",
      "image": "assets/pg 1.png", // Replace with your asset
    },
    {
      "title": "Smart Goals",
      "subtext": "Personalized intake goals tailored to your lifestyle.",
      "image": "assets/pg 2.png", // Replace with your asset
    },
    {
      "title": "Stay Consistent",
      "subtext": "Quick logging and reminders to build healthy habits.",
      "image": "assets/pg3.png", // Replace with your asset
    },
  ];

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // On the last page, go to Sign Up
      Navigator.pushReplacementNamed(context, '/signup');
    }
  }

  void _onSkipPressed() {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- Top Skip Button ---
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: TextButton(
                  onPressed: _onSkipPressed,
                  child: Text(
                    "Skip",
                    style: TextStyle(color: primaryColor, fontSize: 16),
                  ),
                ),
              ),
            ),

            // --- Main Slider Content ---
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // IMAGE PLACEHOLDER
                        Expanded(
                          flex: 3,
                          child: Image.asset(
                            page["image"]!,
                            // If image is missing, this errorBuilder prevents a crash
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(Icons.image, size: 80, color: Colors.blue.shade200),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 5),
                        
                        // TITLE
                        Text(
                          page["title"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // SUBTEXT
                        Text(
                          page["subtext"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),

            // --- Bottom Navigation Section ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators (Dots)
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? primaryColor
                              : primaryColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next / Get Started Button
                  ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Row(
                      children: [
                        Text(_currentPage == _pages.length - 1 ? "Get Started" : "Next"),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}