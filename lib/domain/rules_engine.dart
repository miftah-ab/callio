import 'package:flutter/services.dart';
import 'package:callio/data/repositories.dart';
import 'package:callio/data/settings_storage.dart';
import 'package:callio/domain/models.dart';

class RulesEngine {
  static const MethodChannel _platform = MethodChannel('com.example.callio/sms');
  final RuleRepository _ruleRepo = RuleRepository();
  final TemplateRepository _templateRepo = TemplateRepository();
  final SmsLogRepository _logRepo = SmsLogRepository();

  Future<void> processMissedCall(String phoneNumber) async {
    // 1. Check if master toggle is on
    if (!SettingsStorage.isAppEnabled()) {
      return;
    }

    // 2. Throttling: Check if we recently replied to this number (e.g., within the last 15 minutes)
    final bool recentlyReplied = await _logRepo.hasRepliedRecently(phoneNumber, const Duration(minutes: 15));
    if (recentlyReplied) {
      return; // Do not spam
    }

    // 3. Fetch all rules and templates
    final rules = await _ruleRepo.getAll();
    final templates = await _templateRepo.getAll();

    if (templates.isEmpty) {
      return; // Nothing to send
    }

    // 4. Priority Resolution: Filter active rules and sort by priority (highest first)
    final activeRules = rules.where((r) => r.isActive).toList();
    activeRules.sort((a, b) => b.priority.compareTo(a.priority));

    // For this MVP, we find the highest priority active rule. 
    // (In a full implementation, we'd also check if the phoneNumber belongs to the rule's contactGroup here).
    Rule? matchedRule;
    if (activeRules.isNotEmpty) {
      matchedRule = activeRules.first;
    }

    Template? templateToSend;
    if (matchedRule != null) {
      try {
        templateToSend = templates.firstWhere((t) => t.id == matchedRule!.templateId);
      } catch (e) {
        templateToSend = null;
      }
    }

    // Fallback to default template if no rule matched
    if (templateToSend == null) {
      try {
        templateToSend = templates.firstWhere((t) => t.isDefault);
      } catch (e) {
        templateToSend = templates.first; // Last resort fallback
      }
    }

    // 5. Handle delay
    final delaySeconds = SettingsStorage.getGlobalDelay();
    if (delaySeconds > 0) {
      await Future.delayed(Duration(seconds: delaySeconds));
    }

    // 4. Send SMS via platform channel
    bool success = false;
    try {
      final result = await _platform.invokeMethod<bool>('sendSms', {
        'phoneNumber': phoneNumber,
        'message': templateToSend.content,
      });
      success = result ?? false;
    } catch (e) {
      success = false;
    }

    // 5. Log the result
    await _logRepo.insert(
      SmsLog(
        phoneNumber: phoneNumber,
        timeSent: DateTime.now().toIso8601String(),
        status: success ? 'SUCCESS' : 'FAILED',
      ),
    );
  }
}
