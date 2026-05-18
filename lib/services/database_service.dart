import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/data_models.dart';

/// Database Service - Handles local SQLite database operations
class DatabaseService {
  static const String _databaseName = 'ecotrack.db';
  static const int _databaseVersion = 1;

  static const String _offlineReturnsTable = 'offline_returns';

  late Database _db;

  Future<void> init() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE $_offlineReturnsTable (
        localId TEXT PRIMARY KEY,
        hunterId TEXT NOT NULL,
        hunterName TEXT NOT NULL,
        species TEXT NOT NULL,
        huntDate TEXT NOT NULL,
        location TEXT NOT NULL,
        notes TEXT,
        photoPath TEXT,
        createdAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        syncedAt TEXT
      )
      ''',
    );
  }

  Future<void> saveOfflineReturn(OfflineReturnData returnData) async {
    await _db.insert(
      _offlineReturnsTable,
      {
        'localId': returnData.localId,
        'hunterId': returnData.hunterId,
        'hunterName': returnData.hunterName,
        'species': returnData.species,
        'huntDate': returnData.huntDate.toIso8601String(),
        'location': returnData.location,
        'notes': returnData.notes,
        'photoPath': returnData.photoPath,
        'createdAt': returnData.createdAt.toIso8601String(),
        'isSynced': returnData.isSynced ? 1 : 0,
        'syncedAt': returnData.syncedAt?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<OfflineReturnData>> getUnsyncedReturns() async {
    final maps = await _db.query(
      _offlineReturnsTable,
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (index) {
      return OfflineReturnData(
        localId: maps[index]['localId'] as String,
        hunterId: maps[index]['hunterId'] as String,
        hunterName: maps[index]['hunterName'] as String,
        species: maps[index]['species'] as String,
        huntDate: DateTime.parse(maps[index]['huntDate'] as String),
        location: maps[index]['location'] as String,
        notes: maps[index]['notes'] as String?,
        photoPath: maps[index]['photoPath'] as String?,
        createdAt: DateTime.parse(maps[index]['createdAt'] as String),
        isSynced: (maps[index]['isSynced'] as int) == 1,
        syncedAt: maps[index]['syncedAt'] != null
            ? DateTime.parse(maps[index]['syncedAt'] as String)
            : null,
      );
    });
  }

  Future<List<OfflineReturnData>> getAllOfflineReturns() async {
    final maps = await _db.query(_offlineReturnsTable);

    return List.generate(maps.length, (index) {
      return OfflineReturnData(
        localId: maps[index]['localId'] as String,
        hunterId: maps[index]['hunterId'] as String,
        hunterName: maps[index]['hunterName'] as String,
        species: maps[index]['species'] as String,
        huntDate: DateTime.parse(maps[index]['huntDate'] as String),
        location: maps[index]['location'] as String,
        notes: maps[index]['notes'] as String?,
        photoPath: maps[index]['photoPath'] as String?,
        createdAt: DateTime.parse(maps[index]['createdAt'] as String),
        isSynced: (maps[index]['isSynced'] as int) == 1,
        syncedAt: maps[index]['syncedAt'] != null
            ? DateTime.parse(maps[index]['syncedAt'] as String)
            : null,
      );
    });
  }

  Future<void> markAsSynced(String localId) async {
    await _db.update(
      _offlineReturnsTable,
      {
        'isSynced': 1,
        'syncedAt': DateTime.now().toIso8601String(),
      },
      where: 'localId = ?',
      whereArgs: [localId],
    );
  }

  Future<void> deleteOfflineReturn(String localId) async {
    await _db.delete(
      _offlineReturnsTable,
      where: 'localId = ?',
      whereArgs: [localId],
    );
  }

  Future<void> close() async {
    await _db.close();
  }
}
