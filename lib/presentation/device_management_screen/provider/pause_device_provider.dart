import 'package:family_wifi/presentation/device_management_screen/models/pause_duration_info_model.dart';
import 'package:flutter/foundation.dart';

class PauseDeviceProvider extends ChangeNotifier {
  final List<PauseDurationInfoModel> pauseDurationOptions = [
    PauseDurationInfoModel(label: '30 minutes', duration: 30, isSelected: true),
    PauseDurationInfoModel(label: '1 hour', duration: 60),
    PauseDurationInfoModel(label: '2 hours', duration: 120),
    PauseDurationInfoModel(label: '4 hours', duration: 240),
    PauseDurationInfoModel(label: '8 hours', duration: 480),
    PauseDurationInfoModel(label: 'Infinite', duration: 0),
  ];

  handleNewDurationSelection(int? duration) {
    pauseDurationOptions.forEach((element) {
      element.isSelected = element.duration == duration;
    });
    notifyListeners();
  }

  int? selectedDuration() {
    return pauseDurationOptions
        .firstWhere((element) => element.isSelected)
        .duration;
  }
}
