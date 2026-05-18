import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_service.dart';
import 'returns_service.dart';

/// Sync Service - Handles offline data synchronization
class SyncService {
  final DatabaseService databaseService;
  final ReturnsService returnsService;
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;

  SyncService({
    required this.databaseService,
    required this.returnsService,
  });

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> startAutoSync() async {
    _connectivity.onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none && !_isSyncing) {
        await syncOfflineData();
      }
    });
  }

  Future<bool> syncOfflineData() async {
    if (_isSyncing) return false;

    _isSyncing = true;

    try {
      final isOnline = await this.isOnline();
      if (!isOnline) {
        _isSyncing = false;
        return false;
      }

      final unsyncedReturns = await databaseService.getUnsyncedReturns();

      for (final offlineReturn in unsyncedReturns) {
        try {
          // TODO: Implement API call to sync return
          // For now, mark as synced
          await databaseService.markAsSynced(offlineReturn.localId);
        } catch (e) {
          // If sync fails, continue with next return
          continue;
        }
      }

      _isSyncing = false;
      return true;
    } catch (e) {
      _isSyncing = false;
      return false;
    }
  }

  Future<int> getPendingSyncCount() async {
    final unsyncedReturns = await databaseService.getUnsyncedReturns();
    return unsyncedReturns.length;
  }

  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
