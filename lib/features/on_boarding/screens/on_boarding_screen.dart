import 'package:flutter/material.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/features/auth/screens/signup_screen.dart';
import 'package:raising_india/models/on_boarding_item.dart';

import '../../../comman/elevated_button_style.dart';
import '../widgets/on_boarding_widget.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: first_on_boarding_title,
      description: first_on_boarding_description,
      icon: first_on_boarding_image_svg,
    ),
    OnboardingItem(
      title: second_on_boarding_title,
      description: second_on_boarding_description,
      icon: second_on_boarding_image_svg,
    ),
    OnboardingItem(
      title: third_on_boarding_title,
      description: third_on_boarding_description,
      icon: third_on_boarding_image_svg,
    ),
    OnboardingItem(
      title: fourth_on_boarding_title,
      description: fourth_on_boarding_description,
      icon: fourth_on_boarding_image_svg,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _onboardingItems.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return OnboardingPage(item: _onboardingItems[index]);
              },
            ),
          ),
          _buildPageIndicator(),
          _buildNavigationButtons(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingItems.length,
        (index) => Container(
          width: _currentPage == index ? 16 : 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentPage == index
                ? AppColour.primary
                : AppColour.lightGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    bool isLastPage = _currentPage == _onboardingItems.length - 1;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            style: elevated_button_style(),
            onPressed: () {
              isLastPage
                  ? Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                      (route) => false,
                    )
                  : _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
            },
            child: Text(
              isLastPage ? 'Get Started' : 'Next',
              style: TextStyle(fontSize: 16, color: AppColour.white),
            ),
          ),
          !isLastPage
              ? TextButton(
                  onPressed: () {
                    _pageController.jumpToPage(_onboardingItems.length - 1);
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(fontSize: 16, color: AppColour.lightGrey),
                  ),
                )
              : SizedBox(height: 50),
        ],
      ),
    );
  }
}
