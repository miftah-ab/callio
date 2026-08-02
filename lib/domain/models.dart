class Template {
  final int? id;
  final String name;
  final String content;
  final bool isDefault;

  Template({
    this.id,
    required this.name,
    required this.content,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory Template.fromMap(Map<String, dynamic> map) {
    return Template(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      content: map['content'] ?? '',
      isDefault: map['isDefault'] == 1,
    );
  }
}

class Rule {
  final int? id;
  final String contactGroup;
  final int templateId;
  final bool isActive;

  Rule({
    this.id,
    required this.contactGroup,
    required this.templateId,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactGroup': contactGroup,
      'templateId': templateId,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Rule.fromMap(Map<String, dynamic> map) {
    return Rule(
      id: map['id']?.toInt(),
      contactGroup: map['contactGroup'] ?? '',
      templateId: map['templateId']?.toInt() ?? 0,
      isActive: map['isActive'] == 1,
    );
  }
}

class SmsLog {
  final int? id;
  final String phoneNumber;
  final String timeSent;
  final String status;

  SmsLog({
    this.id,
    required this.phoneNumber,
    required this.timeSent,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'timeSent': timeSent,
      'status': status,
    };
  }

  factory SmsLog.fromMap(Map<String, dynamic> map) {
    return SmsLog(
      id: map['id']?.toInt(),
      phoneNumber: map['phoneNumber'] ?? '',
      timeSent: map['timeSent'] ?? '',
      status: map['status'] ?? '',
    );
  }
}
