// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topology_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopologyInfo _$TopologyInfoFromJson(Map<String, dynamic> json) =>
    TopologyInfo(
        boardId: json['boardId'] as String?,
        nodes: (json['nodes'] as List<dynamic>?)
            ?.map((e) => Node.fromJson(e as Map<String, dynamic>))
            .toList(),
        historicalClients: (json['historicalClients'] as List<dynamic>?)
            ?.map((e) => Client.fromJson(e as Map<String, dynamic>))
            .toList(),
        timestamp: json['timestamp'] == null
            ? null
            : DateTime.parse(json['timestamp'] as String),
      )
      ..edges = json['edges'] == null
          ? null
          : Edges.fromJson(json['edges'] as Map<String, dynamic>);

Map<String, dynamic> _$TopologyInfoToJson(TopologyInfo instance) =>
    <String, dynamic>{
      'boardId': instance.boardId,
      'edges': instance.edges,
      'nodes': instance.nodes,
      'historicalClients': instance.historicalClients,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

Edges _$EdgesFromJson(Map<String, dynamic> json) => Edges(
  mesh: (json['mesh'] as List<dynamic>?)
      ?.map((e) => Mesh.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$EdgesToJson(Edges instance) => <String, dynamic>{
  'mesh': instance.mesh,
};

Mesh _$MeshFromJson(Map<String, dynamic> json) => Mesh(
  band: json['band'] as String?,
  channel: (json['channel'] as num?)?.toInt(),
  from: json['from'] as String?,
  to: json['to'] as String?,
  ssid: json['ssid'] as String?,
);

Map<String, dynamic> _$MeshToJson(Mesh instance) => <String, dynamic>{
  'band': instance.band,
  'channel': instance.channel,
  'from': instance.from,
  'to': instance.to,
  'ssid': instance.ssid,
};

Node _$NodeFromJson(Map<String, dynamic> json) => Node(
  aps: (json['aps'] as List<dynamic>?)
      ?.map((e) => AccessPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  serial: json['serial'] as String?,
  uptime: (json['uptime'] as num?)?.toInt(),
);

Map<String, dynamic> _$NodeToJson(Node instance) => <String, dynamic>{
  'aps': instance.aps,
  'serial': instance.serial,
  'uptime': instance.uptime,
};

AccessPoint _$AccessPointFromJson(Map<String, dynamic> json) => AccessPoint(
  band: json['band'] as String?,
  bssid: json['bssid'] as String?,
  channel: (json['channel'] as num?)?.toInt(),
  clients: (json['clients'] as List<dynamic>?)
      ?.map((e) => Client.fromJson(e as Map<String, dynamic>))
      .toList(),
  mode: json['mode'] as String?,
  ssid: json['ssid'] as String?,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$AccessPointToJson(AccessPoint instance) =>
    <String, dynamic>{
      'band': instance.band,
      'bssid': instance.bssid,
      'channel': instance.channel,
      'clients': instance.clients,
      'mode': instance.mode,
      'ssid': instance.ssid,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

Client _$ClientFromJson(Map<String, dynamic> json) => Client(
  connected: (json['connected'] as num?)?.toInt(),
  inactive: (json['inactive'] as num?)?.toInt(),
  rssi: (json['rssi'] as num?)?.toInt(),
  rxRateBitrate: (json['rx_rate_bitrate'] as num?)?.toInt(),
  rxRateChwidth: (json['rx_rate_chwidth'] as num?)?.toInt(),
  station: json['station'] as String?,
  txRateBitrate: (json['tx_rate_bitrate'] as num?)?.toInt(),
  fingerprint: json['fingerprint'] as String?,
  rxSpeed: (json['rx_speed'] as num?)?.toDouble() ?? 0,
  txSpeed: (json['tx_speed'] as num?)?.toDouble() ?? 0,
  blocked: json['blocked'] as String?,
);

Map<String, dynamic> _$ClientToJson(Client instance) => <String, dynamic>{
  'connected': instance.connected,
  'inactive': instance.inactive,
  'rssi': instance.rssi,
  'rx_rate_bitrate': instance.rxRateBitrate,
  'rx_rate_chwidth': instance.rxRateChwidth,
  'station': instance.station,
  'tx_rate_bitrate': instance.txRateBitrate,
  'fingerprint': instance.fingerprint,
  'rx_speed': instance.rxSpeed,
  'tx_speed': instance.txSpeed,
  'blocked': instance.blocked,
};
