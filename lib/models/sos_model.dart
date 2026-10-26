class DroneInfo {
  final String droneId;
  final String model;
  final String battery;
  final double etaMinutes;
  final String payloadType;
  final double speedKmh;
  final double? telemetryLat;
  final double? telemetryLng;

  DroneInfo({
    required this.droneId,
    required this.model,
    required this.battery,
    required this.etaMinutes,
    required this.payloadType,
    required this.speedKmh,
    this.telemetryLat,
    this.telemetryLng,
  });

  factory DroneInfo.fromJson(Map<String, dynamic> json) {
    return DroneInfo(
      droneId: json['drone_id'] ?? 'DRONE-AERO-07',
      model: json['model'] ?? 'HexaRotor Lifesaver Pro X1',
      battery: json['battery'] ?? '96%',
      etaMinutes: (json['eta_minutes'] is num) ? (json['eta_minutes'] as num).toDouble() : 3.5,
      payloadType: json['payload_type'] ?? 'Emergency Kit',
      speedKmh: (json['speed_kmh'] is num) ? (json['speed_kmh'] as num).toDouble() : 68.0,
      telemetryLat: (json['telemetry_lat'] is num) ? (json['telemetry_lat'] as num).toDouble() : null,
      telemetryLng: (json['telemetry_lng'] is num) ? (json['telemetry_lng'] as num).toDouble() : null,
    );
  }
}

class StatusHistoryItem {
  final String status;
  final String timestamp;
  final String tamilLabel;
  final String englishLabel;
  final String description;

  StatusHistoryItem({
    required this.status,
    required this.timestamp,
    required this.tamilLabel,
    required this.englishLabel,
    required this.description,
  });

  factory StatusHistoryItem.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>? ?? {};
    return StatusHistoryItem(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] ?? '',
      tamilLabel: meta['ta'] ?? '',
      englishLabel: meta['en'] ?? '',
      description: meta['desc'] ?? '',
    );
  }
}

class SosModel {
  final String sosId;
  final String phoneNumber;
  final String requesterName;
  final String emergencyType;
  final double latitude;
  final double longitude;
  final String notes;
  final double accuracyM;
  final String status;
  final String createdAt;
  final DroneInfo? droneAssigned;
  final Map<String, dynamic>? fleetResponse;
  final List<StatusHistoryItem> history;

  SosModel({
    required this.sosId,
    required this.phoneNumber,
    required this.requesterName,
    required this.emergencyType,
    required this.latitude,
    required this.longitude,
    required this.notes,
    required this.accuracyM,
    required this.status,
    required this.createdAt,
    this.droneAssigned,
    this.fleetResponse,
    this.history = const [],
  });

  factory SosModel.fromJson(Map<String, dynamic> json) {
    DroneInfo? drone;
    if (json['drone_assigned'] != null) {
      drone = DroneInfo.fromJson(json['drone_assigned']);
    }

    List<StatusHistoryItem> hist = [];
    if (json['history'] is List) {
      hist = (json['history'] as List)
          .map((item) => StatusHistoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return SosModel(
      sosId: json['sos_id'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      requesterName: json['requester_name'] ?? '',
      emergencyType: json['emergency_type'] ?? 'MEDICAL',
      latitude: (json['latitude'] is num) ? (json['latitude'] as num).toDouble() : 13.0827,
      longitude: (json['longitude'] is num) ? (json['longitude'] as num).toDouble() : 80.2707,
      notes: json['notes'] ?? '',
      accuracyM: (json['accuracy_m'] is num) ? (json['accuracy_m'] as num).toDouble() : 12.0,
      status: json['status'] ?? 'SOS_RECEIVED',
      createdAt: json['created_at'] ?? '',
      droneAssigned: drone,
      fleetResponse: json['fleet_response'] as Map<String, dynamic>?,
      history: hist,
    );
  }
}
