// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configure_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfigurePayload _$ConfigurePayloadFromJson(Map<String, dynamic> json) =>
    ConfigurePayload(
      editNetworkItem: json['ssid'] == null
          ? null
          : EditNetworkItem.fromJson(json['ssid'] as Map<String, dynamic>),
      clientItems: (json['client'] as List<dynamic>?)
          ?.map((e) => ClientItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ConfigurePayloadToJson(ConfigurePayload instance) =>
    <String, dynamic>{
      'ssid': ?instance.editNetworkItem,
      'client': ?instance.clientItems,
    };

EditNetworkItem _$EditNetworkItemFromJson(Map<String, dynamic> json) =>
    EditNetworkItem(
      name: json['name'] as String?,
      password: json['password'] as String?,
    );

Map<String, dynamic> _$EditNetworkItemToJson(EditNetworkItem instance) =>
    <String, dynamic>{'name': instance.name, 'password': instance.password};

ClientItem _$ClientItemFromJson(Map<String, dynamic> json) =>
    ClientItem(mac: json['mac'] as String?, access: json['access'] as String?);

Map<String, dynamic> _$ClientItemToJson(ClientItem instance) =>
    <String, dynamic>{'mac': instance.mac, 'access': instance.access};
