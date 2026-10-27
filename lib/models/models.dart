enum ValidationStatus {
  accepted,
  alreadyUsed,
  notFound,
  wrongMatch,
  cancelled,
  error,
}

class UserProfile {
  final String id;
  final String? email;
  final String? phone;
  final String fullName;
  final String role; // 'admin', 'controller', 'supervisor'
  final bool isActive;

  UserProfile({
    required this.id,
    this.email,
    this.phone,
    required this.fullName,
    required this.role,
    this.isActive = true,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String? ?? 'Agent',
      role: json['role'] as String? ?? 'controller',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class MatchModel {
  final String id;
  final String title;
  final String teamA;
  final String teamB;
  final String stadium;
  final DateTime matchDate;
  final String status; // 'scheduled', 'live', 'finished', 'cancelled'

  MatchModel({
    required this.id,
    required this.title,
    required this.teamA,
    required this.teamB,
    required this.stadium,
    required this.matchDate,
    required this.status,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '${json['team_a']} vs ${json['team_b']}',
      teamA: json['team_a'] as String? ?? '',
      teamB: json['team_b'] as String? ?? '',
      stadium: json['stadium'] as String? ?? 'Stade de Fouta',
      matchDate: json['match_date'] != null
          ? DateTime.parse(json['match_date'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'scheduled',
    );
  }
}

class ZoneModel {
  final String id;
  final String matchId;
  final String name;
  final double price;
  final int capacity;

  ZoneModel({
    required this.id,
    required this.matchId,
    required this.name,
    required this.price,
    required this.capacity,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id'] as String,
      matchId: json['match_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Populaire',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
    );
  }
}

class TicketModel {
  final String id;
  final String matchId;
  final String? zoneId;
  final String ticketCode;
  final String supporterName;
  final String status; // 'valid', 'used', 'cancelled'
  final DateTime? scannedAt;
  final String? scannedBy;

  TicketModel({
    required this.id,
    required this.matchId,
    this.zoneId,
    required this.ticketCode,
    required this.supporterName,
    required this.status,
    this.scannedAt,
    this.scannedBy,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      matchId: json['match_id'] as String? ?? '',
      zoneId: json['zone_id'] as String?,
      ticketCode: json['ticket_code'] as String? ?? '',
      supporterName: json['supporter_name'] as String? ?? 'Supporter',
      status: json['status'] as String? ?? 'valid',
      scannedAt: json['scanned_at'] != null
          ? DateTime.parse(json['scanned_at'] as String)
          : null,
      scannedBy: json['scanned_by'] as String?,
    );
  }
}

class ScanLogModel {
  final String id;
  final String ticketCode;
  final String result; // 'accepted', 'already_used', 'not_found', etc.
  final DateTime scannedAt;
  final String? agentName;

  ScanLogModel({
    required this.id,
    required this.ticketCode,
    required this.result,
    required this.scannedAt,
    this.agentName,
  });

  factory ScanLogModel.fromJson(Map<String, dynamic> json) {
    return ScanLogModel(
      id: json['id'] as String? ?? '',
      ticketCode: json['ticket_code'] as String? ?? 'N/A',
      result: json['result'] as String? ?? 'unknown',
      scannedAt: json['scanned_at'] != null
          ? DateTime.parse(json['scanned_at'] as String)
          : DateTime.now(),
      agentName: json['agent_name'] as String?,
    );
  }
}

class ValidationResult {
  final ValidationStatus status;
  final String message;
  final String ticketCode;
  final String? supporterName;
  final String? zoneName;
  final String? matchTitle;
  final DateTime? scannedAt;
  final String? firstScannedBy;

  ValidationResult({
    required this.status,
    required this.message,
    required this.ticketCode,
    this.supporterName,
    this.zoneName,
    this.matchTitle,
    this.scannedAt,
    this.firstScannedBy,
  });
}
