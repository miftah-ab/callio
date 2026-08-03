import 'package:callio/data/local_db.dart';
import 'package:callio/domain/models.dart';
import 'package:sqflite/sqflite.dart';

class TemplateRepository {
  Future<int> insert(Template template) async {
    final db = await LocalDatabase.instance.database;
    return await db.insert('templates', template.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Template>> getAll() async {
    final db = await LocalDatabase.instance.database;
    final result = await db.query('templates');
    return result.map((json) => Template.fromMap(json)).toList();
  }

  Future<int> delete(int id) async {
    final db = await LocalDatabase.instance.database;
    return await db.delete('templates', where: 'id = ?', whereArgs: [id]);
  }
}

class RuleRepository {
  Future<int> insert(Rule rule) async {
    final db = await LocalDatabase.instance.database;
    return await db.insert('rules', rule.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Rule>> getAll() async {
    final db = await LocalDatabase.instance.database;
    final result = await db.query('rules');
    return result.map((json) => Rule.fromMap(json)).toList();
  }

  Future<int> delete(int id) async {
    final db = await LocalDatabase.instance.database;
    return await db.delete('rules', where: 'id = ?', whereArgs: [id]);
  }
}

class SmsLogRepository {
  Future<int> insert(SmsLog log) async {
    final db = await LocalDatabase.instance.database;
    return await db.insert('logs', log.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SmsLog>> getAll() async {
    final db = await LocalDatabase.instance.database;
    final result = await db.query('logs', orderBy: 'id DESC');
    return result.map((json) => SmsLog.fromMap(json)).toList();
  }

  Future<bool> hasRepliedRecently(String phoneNumber, Duration window) async {
    final db = await LocalDatabase.instance.database;
    final threshold = DateTime.now().subtract(window).toIso8601String();
    
    final result = await db.query(
      'logs',
      where: 'phoneNumber = ? AND timeSent > ?',
      whereArgs: [phoneNumber, threshold],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
