class PauseDurationInfoModel {
  PauseDurationInfoModel({
    required this.label,
    this.duration,
    this.isSelected = false,
  });

  final String label;
  final int? duration;
  bool isSelected;

  PauseDurationInfoModel copyWith({
    String? label,
    int? duration,
    bool? isSelected,
  }) {
    return PauseDurationInfoModel(
      label: label ?? this.label,
      duration: duration ?? this.duration,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
