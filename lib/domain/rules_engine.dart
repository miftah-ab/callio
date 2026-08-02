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

    // 2. Fetch all rules and templates
    final rules = await _ruleRepo.getAll();
    final templates = await _templateRepo.getAll();

    if (templates.isEmpty) {
      return; // Nothing to send
    }

    // For this MVP, we find the first active rule. 
    // In a full implementation, we'd check if the phoneNumber belongs to the rule's contactGroup.
    // Right now, if no rule matches, we fall back to the default template.
    
    Rule? matchedRule;
    try {
      matchedRule = rules.firstWhere((r) => r.isActive);
    } catch (e) {
      matchedRule = null;
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

    // 3. Handle delay
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
