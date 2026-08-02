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
}
