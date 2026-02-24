import 'package:json_annotation/json_annotation.dart';
part 'topology_info.g.dart';

@JsonSerializable()
class TopologyInfo {
  String? boardId;
  Edges? edges;
  List<Node>? nodes;
  List<Client>? historicalClients;
  DateTime? timestamp;

  TopologyInfo({
    this.boardId,
    this.nodes,
    this.historicalClients,
    this.timestamp,
  });

  factory TopologyInfo.fromJson(Map<String, dynamic> json) =>
      _$TopologyInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TopologyInfoToJson(this);
}

@JsonSerializable()
class Edges {
  List<Mesh>? mesh;

  Edges({this.mesh});

  factory Edges.fromJson(Map<String, dynamic> json) => _$EdgesFromJson(json);
  Map<String, dynamic> toJson() => _$EdgesToJson(this);
}

@JsonSerializable()
class Mesh {
  String? band;
  int? channel;
  String? from;
  String? to;
  String? ssid;

  Mesh({this.band, this.channel, this.from, this.to, this.ssid});

  factory Mesh.fromJson(Map<String, dynamic> json) => _$MeshFromJson(json);
  Map<String, dynamic> toJson() => _$MeshToJson(this);
}

@JsonSerializable()
class Node {
  List<AccessPoint>? aps;
  String? serial;
  int? uptime;

  Node({this.aps, this.serial, this.uptime});

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);
  Map<String, dynamic> toJson() => _$NodeToJson(this);
}

@JsonSerializable()
class AccessPoint {
  String? band;
  String? bssid;
  int? channel;
  List<Client>? clients;
  String? mode;
  String? ssid;
  DateTime? timestamp;

  AccessPoint({
    this.band,
    this.bssid,
    this.channel,
    this.clients,
    this.mode,
    this.ssid,
    this.timestamp,
  });

  factory AccessPoint.fromJson(Map<String, dynamic> json) =>
      _$AccessPointFromJson(json);
  Map<String, dynamic> toJson() => _$AccessPointToJson(this);
}

@JsonSerializable()
class Client {
  int? connected;
  int? inactive;
  int? rssi;
  @JsonKey(name: 'rx_rate_bitrate')
  int? rxRateBitrate;
  @JsonKey(name: 'rx_rate_chwidth')
  int? rxRateChwidth;
  String? station;
  @JsonKey(name: 'tx_rate_bitrate')
  int? txRateBitrate;
  String? fingerprint;
  @JsonKey(name: 'rx_speed', defaultValue: 0)
  final double rxSpeed;
  @JsonKey(name: 'tx_speed', defaultValue: 0)
  final double txSpeed;
  String? blocked;

  Client({
    this.connected,
    this.inactive,
    this.rssi,
    this.rxRateBitrate,
    this.rxRateChwidth,
    this.station,
    this.txRateBitrate,
    this.fingerprint,
    this.rxSpeed = 0,
    this.txSpeed = 0,
    this.blocked,
  });

  get isBlocked => blocked == '1';

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
  Map<String, dynamic> toJson() => _$ClientToJson(this);
}
