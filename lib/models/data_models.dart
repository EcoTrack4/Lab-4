/// Data models for EcoTrack application

/// User model for both Professional Hunters and Permit Officers
class User {
  final String id;
  final String name;
  final String email;
  final String userType; // 'hunter' or 'officer'
  final String? licenseNumber;
  final String? region;
  final DateTime createdAt;
  final DateTime lastLogin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.licenseNumber,
    this.region,
    required this.createdAt,
    required this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      userType: json['userType'],
      licenseNumber: json['licenseNumber'],
      region: json['region'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'userType': userType,
      'licenseNumber': licenseNumber,
      'region': region,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }
}

/// Annual Return model for wildlife hunt submissions
class AnnualReturn {
  final String id;
  final String hunterId;
  final String hunterName;
  final String species;
  final DateTime huntDate;
  final String location;
  final String? notes;
  final String? photoPath;
  final String status; // 'submitted', 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final DateTime submittedDate;
  final DateTime? approvalDate;
  final String? approvedBy;
  final String auditTrail; // Timestamp and device info
  final bool isOfflineSync; // Whether submitted via offline sync

  AnnualReturn({
    required this.id,
    required this.hunterId,
    required this.hunterName,
    required this.species,
    required this.huntDate,
    required this.location,
    this.notes,
    this.photoPath,
    required this.status,
    this.rejectionReason,
    required this.submittedDate,
    this.approvalDate,
    this.approvedBy,
    required this.auditTrail,
    required this.isOfflineSync,
  });

  factory AnnualReturn.fromJson(Map<String, dynamic> json) {
    return AnnualReturn(
      id: json['id'],
      hunterId: json['hunterId'],
      hunterName: json['hunterName'],
      species: json['species'],
      huntDate: DateTime.parse(json['huntDate']),
      location: json['location'],
      notes: json['notes'],
      photoPath: json['photoPath'],
      status: json['status'],
      rejectionReason: json['rejectionReason'],
      submittedDate: DateTime.parse(json['submittedDate']),
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'])
          : null,
      approvedBy: json['approvedBy'],
      auditTrail: json['auditTrail'],
      isOfflineSync: json['isOfflineSync'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hunterId': hunterId,
      'hunterName': hunterName,
      'species': species,
      'huntDate': huntDate.toIso8601String(),
      'location': location,
      'notes': notes,
      'photoPath': photoPath,
      'status': status,
      'rejectionReason': rejectionReason,
      'submittedDate': submittedDate.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'approvedBy': approvedBy,
      'auditTrail': auditTrail,
      'isOfflineSync': isOfflineSync,
    };
  }

  // Helper method to check if return is pending
  bool get isPending => status == 'pending';

  // Helper method to check if return is approved
  bool get isApproved => status == 'approved';

  // Helper method to check if return is rejected
  bool get isRejected => status == 'rejected';
}

/// Dashboard statistics model
class DashboardStats {
  final int totalReturns;
  final int pendingReturns;
  final int approvedReturns;
  final int rejectedReturns;
  final List<String> topSpecies;
  final DateTime generatedAt;

  DashboardStats({
    required this.totalReturns,
    required this.pendingReturns,
    required this.approvedReturns,
    required this.rejectedReturns,
    required this.topSpecies,
    required this.generatedAt,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalReturns: json['totalReturns'],
      pendingReturns: json['pendingReturns'],
      approvedReturns: json['approvedReturns'],
      rejectedReturns: json['rejectedReturns'],
      topSpecies: List<String>.from(json['topSpecies']),
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReturns': totalReturns,
      'pendingReturns': pendingReturns,
      'approvedReturns': approvedReturns,
      'rejectedReturns': rejectedReturns,
      'topSpecies': topSpecies,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

/// Annual Report model for exports
class AnnualReport {
  final String year;
  final int totalReturns;
  final List<String> species;
  final List<AnnualReturn> returns;
  final DateTime generatedAt;
  final String generatedBy;

  AnnualReport({
    required this.year,
    required this.totalReturns,
    required this.species,
    required this.returns,
    required this.generatedAt,
    required this.generatedBy,
  });

  factory AnnualReport.fromJson(Map<String, dynamic> json) {
    return AnnualReport(
      year: json['year'],
      totalReturns: json['totalReturns'],
      species: List<String>.from(json['species']),
      returns: (json['returns'] as List)
          .map((r) => AnnualReturn.fromJson(r))
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt']),
      generatedBy: json['generatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'totalReturns': totalReturns,
      'species': species,
      'returns': returns.map((r) => r.toJson()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
      'generatedBy': generatedBy,
    };
  }
}

/// API Response wrapper model
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
    };
  }
}

/// Offline data model for local storage
class OfflineReturnData {
  final String localId;
  final String hunterId;
  final String hunterName;
  final String species;
  final DateTime huntDate;
  final String location;
  final String? notes;
  final String? photoPath;
  final DateTime createdAt;
  final bool isSynced;
  final DateTime? syncedAt;

  OfflineReturnData({
    required this.localId,
    required this.hunterId,
    required this.hunterName,
    required this.species,
    required this.huntDate,
    required this.location,
    this.notes,
    this.photoPath,
    required this.createdAt,
    required this.isSynced,
    this.syncedAt,
  });

  factory OfflineReturnData.fromJson(Map<String, dynamic> json) {
    return OfflineReturnData(
      localId: json['localId'],
      hunterId: json['hunterId'],
      hunterName: json['hunterName'],
      species: json['species'],
      huntDate: DateTime.parse(json['huntDate']),
      location: json['location'],
      notes: json['notes'],
      photoPath: json['photoPath'],
      createdAt: DateTime.parse(json['createdAt']),
      isSynced: json['isSynced'] ?? false,
      syncedAt: json['syncedAt'] != null
          ? DateTime.parse(json['syncedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localId': localId,
      'hunterId': hunterId,
      'hunterName': hunterName,
      'species': species,
      'huntDate': huntDate.toIso8601String(),
      'location': location,
      'notes': notes,
      'photoPath': photoPath,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced,
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }
}
