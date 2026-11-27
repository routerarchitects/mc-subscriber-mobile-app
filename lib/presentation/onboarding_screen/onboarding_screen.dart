import 'package:family_wifi/core/network/api_helper.dart';
import 'package:family_wifi/core/utils/shared_preferences_helper.dart';
import 'package:family_wifi/presentation/onboarding_screen/repository/onboarding_repository.dart';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_image_view.dart';
import './provider/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<OnboardingRepository>(
          create: (_) => OnboardingRepository(
            context.read<ApiHelper>(),
            context.read<SharedPreferencesHelper>(),
          ),
        ),
        Provider<OnboardingProvider>(
          create: (lCtx) =>
              OnboardingProvider(lCtx.read<OnboardingRepository>()),
          dispose: (_, provider) => provider.dispose(),
        ),
      ],
      child: const OnboardingScreen(),
    );
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingProvider controller;

  @override
  void initState() {
    super.initState();
    controller = Provider.of<OnboardingProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray_900,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 16.h, left: 16.h, right: 16.h),
                child: CustomImageView(
                  imagePath: ImageConstant.imgDepth4Frame0536x358,
                  width: double.infinity,
                  height: 536.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 36.h),
              Text(
                'HomeConnect',
                style: TextStyleHelper.instance.headline28BoldInter,
              ),
              SizedBox(height: 18.h),
              Text(
                'Connecting your home, simplifying your life.',
                style: TextStyleHelper.instance.body14RegularInter,
              ),
              SizedBox(height: 114.h),
              _buildPagerIndicator(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagerIndicator() {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          controller.onboardingModel.totalPages ?? 3,
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 4.h),
            height: 8.h,
            width: 8.h,
            decoration: BoxDecoration(
              color: index == (controller.onboardingModel.currentPage ?? 0)
                  ? Color(0xFF1172D3)
                  : appTheme.blue_gray_700,
              borderRadius: BorderRadius.circular(4.h),
            ),
          ),
        ),
      ),
    );
  }
}
