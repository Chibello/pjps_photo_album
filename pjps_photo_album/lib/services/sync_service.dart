// lib/services/sync_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/database/database_helper.dart';
import '../services/connectivity_service.dart';
import '../services/api_service.dart';
import 'package:sqflite/sqflite.dart'; // for ConflictAlgorithm

// Optional imports for mobile/desktop only
// ignore: uri_does_not_exist
import 'package:workmanager/workmanager.dart';
// ignore: uri_does_not_exist
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart'; // for Color

class SyncService {
  static const String syncTask = 'syncTask';

  static FlutterLocalNotificationsPlugin? _notifications;

  /// Initialize background sync & notifications
  static Future<void> initialize() async {
    if (!kIsWeb) {
      // Initialize notifications
      _notifications = FlutterLocalNotificationsPlugin();
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      final initSettings =
          InitializationSettings(android: androidSettings, iOS: iosSettings);
      await _notifications!.initialize(initSettings);

      // Initialize Workmanager
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

      // Register periodic sync every 15 minutes
      await Workmanager().registerPeriodicTask(
        syncTask,
        syncTask,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        initialDelay: const Duration(minutes: 5),
      );
    } else {
      // Web: skip Workmanager & notifications
      print('⚠️ Background sync & notifications are disabled on Web.');
    }
  }

  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    if (kIsWeb) return; // web does not support background tasks

    Workmanager().executeTask((task, inputData) async {
      if (task == syncTask) await performSync();
      return Future.value(true);
    });
  }

  /// Manual sync for all platforms
  static Future<void> syncNow() async => performSync();

  /// Perform pending operations
  static Future<void> performSync() async {
    print('🔄 Starting sync...');

    final connectivity = ConnectivityService();
    if (!await connectivity.isOnline) {
      print('📡 Offline: skipping sync.');
      return;
    }

    final db = DatabaseHelper();
    final api = ApiService();

    try {
      final pendingOps = await db.getPendingOperations();
      if (pendingOps.isEmpty) {
        print('✅ No pending operations to sync.');
        return;
      }

      for (var op in pendingOps) {
        try {
          final data = json.decode(op['data']);
          switch (op['operation']) {
            case 'CREATE':
              await api.post('/${op['table_name']}/', data: data);
              break;
            case 'UPDATE':
              await api.put('/${op['table_name']}/${op['record_id']}/',
                  data: data);
              break;
            case 'DELETE':
              await api.delete('/${op['table_name']}/${op['record_id']}/');
              break;
            default:
              print('⚠️ Unknown operation ${op['operation']}');
          }
          await db.removeOperation(op['id']);
        } catch (e) {
          print('❌ Failed operation ${op['id']}: $e');
          // Increment attempts safely
          final attempts = (op['attempts'] ?? 0) as int;
          if (!kIsWeb) {
            await db.update(
              'sync_queue',
              {'attempts': attempts + 1},
              where: 'id = ?',
              whereArgs: [op['id']],
            );
          }
        }
      }

      if (!kIsWeb) {
        await _showNotification(
          'Sync Complete',
          'Successfully synced ${pendingOps.length} items',
        );
      }
    } catch (e) {
      print('❌ Sync failed: $e');
      if (!kIsWeb) {
        await _showNotification('Sync Failed', 'Check your connection',
            isError: true);
      }
    }
  }

  /// Show notification (mobile/desktop only)
  static Future<void> _showNotification(String title, String body,
      {bool isError = false}) async {
    if (kIsWeb || _notifications == null) return;

    await _notifications!.show(
      DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'sync_channel',
          'Sync Notifications',
          channelDescription: 'Notifications for data sync',
          importance: Importance.high,
          priority: Priority.high,
          color: isError ? const Color(0xFFFF4444) : const Color(0xFF4CAF50),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Full data sync (force all records)
  static Future<void> fullSync() async {
    print('🔄 Starting full data sync...');
    final db = DatabaseHelper();
    final api = ApiService();

    try {
      // Example: sync year_levels
      final yearLevels = await api.get('/albums/year-levels/');
      for (var year in yearLevels.data) {
        await db.insert(
          'year_levels',
          {
            'id': year['id'],
            'name': year['name'],
            'display_order': year['display_order'],
            'last_sync': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      print('✅ Full sync completed');
    } catch (e) {
      print('❌ Full sync failed: $e');
      rethrow;
    }
  }
}
