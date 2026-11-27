import 'package:json_annotation/json_annotation.dart';
part 'subscriber_location.g.dart';

@JsonSerializable(includeIfNull: false)
class SubscriberLocation {
  String? id;

  @JsonKey(defaultValue: 'UNK')
  String? name;

  String? timezone;

  SubscriberLocation({
    this.id,
    this.name = 'UNK',
    this.timezone,
  });

  factory SubscriberLocation.fromJson(Map<String, dynamic> json) =>
      _$SubscriberLocationFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriberLocationToJson(this);
}
