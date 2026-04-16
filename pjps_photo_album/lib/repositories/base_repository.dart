// lib/repositories/base_repository.dart
import '../services/connectivity_service.dart';
import '../core/database/database_helper.dart';
import '../services/api_service.dart';
import 'package:sqflite/sqflite.dart';

abstract class BaseRepository<T> {
  final ApiService apiService;
  final DatabaseHelper dbHelper;
  final ConnectivityNotifier connectivity;

  BaseRepository(this.apiService, this.dbHelper, this.connectivity);

  // Table name for this repository
  String get tableName;

  // Convert from JSON to model
  T fromJson(Map<String, dynamic> json);

  // Convert from model to JSON
  Map<String, dynamic> toJson(T model);

  // Check if online
  Future<bool> get isOnline async => await connectivity.isOnline;

  // Get all items (online first, fallback to cache)
  Future<List<T>> getAll({bool forceRefresh = false}) async {
    if (await isOnline && !forceRefresh) {
      try {
        final items = await fetchFromApi();
        await cacheItems(items);
        return items;
      } catch (e) {
        return getFromCache();
      }
    } else {
      return getFromCache();
    }
  }

  // Get single item by ID
  Future<T?> getById(String id) async {
    if (await isOnline) {
      try {
        final item = await fetchFromApiById(id);
        await cacheItem(item);
        return item;
      } catch (e) {
        return getFromCacheById(id);
      }
    } else {
      return getFromCacheById(id);
    }
  }

  // Create item (queue if offline)
  Future<T?> create(T item) async {
    if (await isOnline) {
      try {
        final created = await createInApi(item);
        await cacheItem(created);
        return created;
      } catch (e) {
        await queueOperation('CREATE', item);
        await cacheItem(item, isDirty: true);
        return item;
      }
    } else {
      await queueOperation('CREATE', item);
      await cacheItem(item, isDirty: true);
      return item;
    }
  }

  // Update item (queue if offline)
  Future<T?> update(T item) async {
    if (await isOnline) {
      try {
        final updated = await updateInApi(item);
        await cacheItem(updated);
        return updated;
      } catch (e) {
        await queueOperation('UPDATE', item);
        await cacheItem(item, isDirty: true);
        return item;
      }
    } else {
      await queueOperation('UPDATE', item);
      await cacheItem(item, isDirty: true);
      return item;
    }
  }

  // Delete item (queue if offline)
  Future<void> delete(String id) async {
    if (await isOnline) {
      try {
        await deleteInApi(id);
        await deleteFromCache(id);
      } catch (e) {
        await queueOperation('DELETE', {'id': id});
      }
    } else {
      await queueOperation('DELETE', {'id': id});
    }
  }

  // Abstract methods
  Future<List<T>> fetchFromApi();
  Future<T> fetchFromApiById(String id);
  Future<T> createInApi(T item);
  Future<T> updateInApi(T item);
  Future<void> deleteInApi(String id);

  // Cache methods
  Future<void> cacheItems(List<T> items) async {
    final db = await dbHelper.database;
    final batch = db.batch();

    for (var item in items) {
      batch.insert(
        tableName,
        toJson(item),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> cacheItem(T item, {bool isDirty = false}) async {
    final db = await dbHelper.database;
    final data = toJson(item);
    data['is_dirty'] = isDirty ? 1 : 0;
    data['last_sync'] = DateTime.now().toIso8601String();

    await db.insert(
      tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<T>> getFromCache() async {
    final db = await dbHelper.database;
    final result = await db.query(tableName);
    return result
        .map((json) => fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<T?> getFromCacheById(String id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return fromJson(Map<String, dynamic>.from(result.first));
    }
    return null;
  }

  Future<void> deleteFromCache(String id) async {
    final db = await dbHelper.database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> queueOperation(String operation, dynamic data) async {
    final id = (data is Map && data['id'] != null)
        ? data['id']
        : (data is T && toJson(data)['id'] != null)
            ? toJson(data)['id']
            : '';

    await dbHelper.queueOperation(
      operation,
      tableName,
      id,
      data is T ? toJson(data) : data,
    );
  }
}
