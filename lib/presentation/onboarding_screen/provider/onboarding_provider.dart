import 'package:family_wifi/presentation/onboarding_screen/repository/onboarding_repository.dart';

import '../../../core/app_export.dart';
import '../models/onboarding_model.dart';

class OnboardingProvider {
  late final OnboardingRepository _repository;
  OnboardingModel onboardingModel = OnboardingModel();

  OnboardingProvider(this._repository);

  Future<void> initialize() async {
    onboardingModel = OnboardingModel(currentPage: 0, totalPages: 3);

    bool autoLogin = await _repository.shouldAutoLogin();

    if (autoLogin) {
      Future.delayed(Duration(seconds: 1), () {
        navigateToHomeScreen();
      });
    } else {
      Future.delayed(Duration(seconds: 3), () {
        navigateToNextScreen();
      });
    }
  }

  void navigateToNextScreen() {
    NavigatorService.pushNamedAndRemoveUntil(AppRoutes.networkWelcomeScreen);
  }

  void navigateToHomeScreen() {
    NavigatorService.pushNamedAndRemoveUntil(AppRoutes.homeScreen);
  }

  void dispose() {
    // Clean up any resources here
  }
}
