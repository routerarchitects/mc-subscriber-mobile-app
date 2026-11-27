// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscriber_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriberLocation _$SubscriberLocationFromJson(Map<String, dynamic> json) =>
    SubscriberLocation(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'UNK',
      timezone: json['timezone'] as String?,
    );

Map<String, dynamic> _$SubscriberLocationToJson(SubscriberLocation instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': ?instance.name,
      'timezone': ?instance.timezone,
    };
