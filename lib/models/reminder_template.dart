class ReminderTemplate {
  final String id;
  final String name;
  final String messageML;
  final String messageEN;
  final bool isDefault;

  const ReminderTemplate({
    required this.id,
    required this.name,
    required this.messageML,
    required this.messageEN,
    this.isDefault = false,
  });

  String fill({
    required String guestName,
    required String groom,
    required String bride,
    String date = '',
    String venue = '',
    bool isMalayalam = true,
  }) {
    final msg = isMalayalam ? messageML : messageEN;
    return msg
        .replaceAll('{{name}}', guestName)
        .replaceAll('{{groom}}', groom)
        .replaceAll('{{bride}}', bride)
        .replaceAll('{{date}}', date)
        .replaceAll('{{venue}}', venue);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'message_ml': messageML,
      'message_en': messageEN,
      'is_default': isDefault,
    };
  }

  factory ReminderTemplate.fromMap(Map<String, dynamic> map) {
    return ReminderTemplate(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      messageML: map['message_ml'] ?? '',
      messageEN: map['message_en'] ?? '',
      isDefault: map['is_default'] ?? false,
    );
  }

  static const List<ReminderTemplate> defaults = [
    ReminderTemplate(
      id: 'gentle_reminder',
      name: 'Gentle Reminder',
      messageML: 'നമസ്കാരം {{name}} 🙏\n\n{{groom}} & {{bride}} ന്റെ വിവാഹത്തിലേക്ക് ക്ഷണിച്ചിട്ടും താങ്കളുടെ മറുപടി ലഭിച്ചിട്ടില്ല. ദയവായി RSVP ചെയ്യുക.\n\nതീയതി: {{date}}\nവേദി: {{venue}}\n\nഅതിഥി',
      messageEN: 'Hello {{name}} 🙏\n\nWe haven\'t received your RSVP for {{groom}} & {{bride}}\'s wedding yet. Please confirm your attendance.\n\nDate: {{date}}\nVenue: {{venue}}\n\nThank you!',
      isDefault: true,
    ),
    ReminderTemplate(
      id: 'urgent_reminder',
      name: 'Urgent Reminder',
      messageML: 'നമസ്കാരം {{name}} 🙏\n\n{{groom}} & {{bride}} ന്റെ വിവാഹത്തിന് അധികം ദിവസങ്ങൾ ബാക്കിയില്ല. താങ്കളുടെ RSVP പ്രതീക്ഷിക്കുന്നു.\n\nതീയതി: {{date}}\nവേദി: {{venue}}\n\nഅതിഥി',
      messageEN: 'Hello {{name}} 🙏\n\nJust a few days left for {{groom}} & {{bride}}\'s wedding! We\'re still waiting for your RSVP.\n\nDate: {{date}}\nVenue: {{venue}}\n\nPlease confirm soon!',
      isDefault: true,
    ),
    ReminderTemplate(
      id: 'priority_vip',
      name: 'Priority/VIP',
      messageML: 'നമസ്കാരം {{name}} 🙏\n\n{{groom}} & {{bride}} ന്റെ വിവാഹത്തിലേക്ക് ഹൃദയപൂർവ്വമായ ക്ഷണം. താങ്കളുടെ സാന്നിധ്യം ഞങ്ങൾക്ക് വളരെ വിലപ്പെട്ടതാണ്. ദയവായി RSVP ചെയ്യുക.\n\nതീയതി: {{date}}\nവേദി: {{venue}}',
      messageEN: 'Dear {{name}} 🙏\n\nCordial invitation to {{groom}} & {{bride}}\'s wedding. Your presence means a lot to us. Kindly RSVP at the earliest.\n\nDate: {{date}}\nVenue: {{venue}}',
      isDefault: true,
    ),
  ];
}

class ReminderLog {
  final String id;
  final String guestId;
  final String guestName;
  final String guestPhone;
  final String templateId;
  final String message;
  final String channel;
  final String status;
  final DateTime sentAt;

  ReminderLog({
    required this.id,
    required this.guestId,
    required this.guestName,
    required this.guestPhone,
    required this.templateId,
    required this.message,
    required this.channel,
    required this.status,
    required this.sentAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guest_id': guestId,
      'guest_name': guestName,
      'guest_phone': guestPhone,
      'template_id': templateId,
      'message': message,
      'channel': channel,
      'status': status,
      'sent_at': sentAt.toIso8601String(),
    };
  }

  factory ReminderLog.fromMap(Map<String, dynamic> map) {
    return ReminderLog(
      id: map['id'] ?? '',
      guestId: map['guest_id'] ?? '',
      guestName: map['guest_name'] ?? '',
      guestPhone: map['guest_phone'] ?? '',
      templateId: map['template_id'] ?? '',
      message: map['message'] ?? '',
      channel: map['channel'] ?? 'whatsapp',
      status: map['status'] ?? 'sent',
      sentAt: map['sent_at'] != null
          ? DateTime.parse(map['sent_at'])
          : DateTime.now(),
    );
  }
}
