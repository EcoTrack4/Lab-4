import '../models/data_models.dart';

/// Returns Service - Handles all operations related to annual returns
class ReturnsService {
  // Mock data storage (to be replaced with real API/database)
  final List<AnnualReturn> _mockReturns = [
    AnnualReturn(
      id: 'return_001',
      hunterId: 'hunter_001',
      hunterName: 'Johannes Kamanga',
      species: 'Oryx',
      huntDate: DateTime(2024, 5, 1),
      location: 'Kunene Region',
      notes: 'Large male specimen',
      status: 'approved',
      submittedDate: DateTime(2024, 5, 6),
      approvalDate: DateTime(2024, 5, 6),
      approvedBy: 'Petrus M.',
      auditTrail: '2024-05-06 14:32:45 UTC | Samsung Galaxy A12',
      isOfflineSync: false,
    ),
    AnnualReturn(
      id: 'return_002',
      hunterId: 'hunter_001',
      hunterName: 'Johannes Kamanga',
      species: 'Kudu',
      huntDate: DateTime(2024, 4, 28),
      location: 'Kunene Region',
      notes: 'Hunt duration: 3 days',
      status: 'pending',
      submittedDate: DateTime(2024, 5, 5),
      auditTrail: '2024-05-05 10:15:30 UTC | Samsung Galaxy A12',
      isOfflineSync: true,
    ),
    AnnualReturn(
      id: 'return_003',
      hunterId: 'hunter_002',
      hunterName: 'Marcus Steenkamp',
      species: 'Springbok',
      huntDate: DateTime(2024, 4, 30),
      location: 'Hardap Region',
      status: 'approved',
      submittedDate: DateTime(2024, 5, 4),
      approvalDate: DateTime(2024, 5, 4),
      approvedBy: 'Petrus M.',
      auditTrail: '2024-05-04 09:45:00 UTC | iPhone 12',
      isOfflineSync: false,
    ),
    AnnualReturn(
      id: 'return_004',
      hunterId: 'hunter_003',
      hunterName: 'David Mueller',
      species: 'Warthog',
      huntDate: DateTime(2024, 4, 15),
      location: 'Otjozondjupa',
      status: 'approved',
      submittedDate: DateTime(2024, 4, 28),
      approvalDate: DateTime(2024, 4, 30),
      approvedBy: 'Petrus M.',
      auditTrail: '2024-04-28 16:20:15 UTC | Samsung A50',
      isOfflineSync: false,
    ),
  ];

  Future<List<AnnualReturn>> getReturnsByHunter(String hunterId) async {
    // TODO: Implement API call to fetch returns
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockReturns.where((r) => r.hunterId == hunterId).toList();
  }

  Future<List<AnnualReturn>> getAllReturns() async {
    // TODO: Implement API call to fetch all returns
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockReturns;
  }

  Future<List<AnnualReturn>> getReturnsByStatus(String status) async {
    // TODO: Implement API call to fetch returns by status
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockReturns.where((r) => r.status == status).toList();
  }

  Future<AnnualReturn?> getReturnById(String returnId) async {
    // TODO: Implement API call to fetch single return
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockReturns.firstWhere((r) => r.id == returnId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> submitReturn(AnnualReturn returnData) async {
    // TODO: Implement API call to submit return
    await Future.delayed(const Duration(seconds: 1));
    _mockReturns.add(returnData);
    return true;
  }

  Future<bool> approveReturn({
    required String returnId,
    required String approvedBy,
  }) async {
    // TODO: Implement API call to approve return
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final index = _mockReturns.indexWhere((r) => r.id == returnId);
      if (index != -1) {
        final returnData = _mockReturns[index];
        _mockReturns[index] = AnnualReturn(
          id: returnData.id,
          hunterId: returnData.hunterId,
          hunterName: returnData.hunterName,
          species: returnData.species,
          huntDate: returnData.huntDate,
          location: returnData.location,
          notes: returnData.notes,
          photoPath: returnData.photoPath,
          status: 'approved',
          submittedDate: returnData.submittedDate,
          approvalDate: DateTime.now(),
          approvedBy: approvedBy,
          auditTrail: returnData.auditTrail,
          isOfflineSync: returnData.isOfflineSync,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectReturn({
    required String returnId,
    required String rejectionReason,
    required String rejectedBy,
  }) async {
    // TODO: Implement API call to reject return
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final index = _mockReturns.indexWhere((r) => r.id == returnId);
      if (index != -1) {
        final returnData = _mockReturns[index];
        _mockReturns[index] = AnnualReturn(
          id: returnData.id,
          hunterId: returnData.hunterId,
          hunterName: returnData.hunterName,
          species: returnData.species,
          huntDate: returnData.huntDate,
          location: returnData.location,
          notes: returnData.notes,
          photoPath: returnData.photoPath,
          status: 'rejected',
          rejectionReason: rejectionReason,
          submittedDate: returnData.submittedDate,
          auditTrail: returnData.auditTrail,
          isOfflineSync: returnData.isOfflineSync,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<AnnualReport> generateAnnualReport({
    required String year,
    required List<AnnualReturn> returns,
    required String generatedBy,
  }) async {
    // TODO: Implement API call to generate report
    await Future.delayed(const Duration(seconds: 1));
    
    final species = returns.map((r) => r.species).toSet().toList();
    
    return AnnualReport(
      year: year,
      totalReturns: returns.length,
      species: species,
      returns: returns,
      generatedAt: DateTime.now(),
      generatedBy: generatedBy,
    );
  }

  Future<DashboardStats> getDashboardStats() async {
    // TODO: Implement API call to fetch stats
    await Future.delayed(const Duration(milliseconds: 300));
    
    final topSpecies = <String, int>{};
    for (final r in _mockReturns) {
      topSpecies[r.species] = (topSpecies[r.species] ?? 0) + 1;
    }
    
    final sortedSpecies = topSpecies.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return DashboardStats(
      totalReturns: _mockReturns.length,
      pendingReturns: _mockReturns.where((r) => r.isPending).length,
      approvedReturns: _mockReturns.where((r) => r.isApproved).length,
      rejectedReturns: _mockReturns.where((r) => r.isRejected).length,
      topSpecies: sortedSpecies.take(5).map((e) => e.key).toList(),
      generatedAt: DateTime.now(),
    );
  }
}
