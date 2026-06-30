import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:athidhi/models/guest_model.dart';
import 'package:athidhi/models/reminder_template.dart';

class ReminderProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  List<ReminderLog> _history = [];
  List<ReminderTemplate> _templates = [];
  bool _isLoading = false;

  List<ReminderLog> get history => _history;
  List<ReminderTemplate> get templates => _templates;
  bool get isLoading => _isLoading;

  List<ReminderLog> getGuestHistory(String guestId) {
    return _history.where((r) => r.guestId == guestId).toList();
  }

  Future<void> loadTemplates() async {
    try {
      final response = await _client.from('reminder_templates').select();
      _templates = (response as List)
          .map((t) => ReminderTemplate.fromMap(t as Map<String, dynamic>))
          .toList();
      if (_templates.isEmpty) {
        _templates = List.from(ReminderTemplate.defaults);
      }
    } catch (_) {
      _templates = List.from(ReminderTemplate.defaults);
    }
    notifyListeners();
  }

  Future<void> loadHistory(String eventId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('reminders')
          .select()
          .eq('event_id', eventId)
          .order('sent_at', ascending: false);

      _history = (response as List)
          .map((r) => ReminderLog.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendWhatsApp({
    required Guest guest,
    required ReminderTemplate template,
    required String groom,
    required String bride,
    String date = '',
    String venue = '',
    bool isMalayalam = true,
    String? eventId,
  }) async {
    final message = template.fill(
      guestName: guest.name,
      groom: groom,
      bride: bride,
      date: date,
      venue: venue,
      isMalayalam: isMalayalam,
    );

    final phone = '91${guest.phone}';
    final encoded = Uri.encodeComponent(message);
    final url = 'whatsapp://send?phone=$phone&text=$encoded';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
        await _logReminder(
          eventId: eventId,
          guest: guest,
          templateId: template.id,
          message: message,
          channel: 'whatsapp',
          status: 'sent',
        );
      } else {
        await _logReminder(
          eventId: eventId,
          guest: guest,
          templateId: template.id,
          message: message,
          channel: 'whatsapp',
          status: 'failed',
        );
      }
    } catch (_) {
      await _logReminder(
        eventId: eventId,
        guest: guest,
        templateId: template.id,
        message: message,
        channel: 'whatsapp',
        status: 'failed',
      );
    }
  }

  Future<void> sendSms({
    required Guest guest,
    required ReminderTemplate template,
    required String groom,
    required String bride,
    String date = '',
    String venue = '',
    bool isMalayalam = true,
    String? eventId,
  }) async {
    final message = template.fill(
      guestName: guest.name,
      groom: groom,
      bride: bride,
      date: date,
      venue: venue,
      isMalayalam: isMalayalam,
    );

    final phone = '+91${guest.phone}';
    final encoded = Uri.encodeComponent(message);
    final url = 'sms:$phone?body=$encoded';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
        await _logReminder(
          eventId: eventId,
          guest: guest,
          templateId: template.id,
          message: message,
          channel: 'sms',
          status: 'sent',
        );
      }
    } catch (_) {
      await _logReminder(
        eventId: eventId,
        guest: guest,
        templateId: template.id,
        message: message,
        channel: 'sms',
        status: 'failed',
      );
    }
  }

  List<Guest> getPendingGuests(List<Guest> allGuests) {
    return allGuests
        .where((g) => g.status != 'accepted' && g.status != 'declined')
        .toList();
  }

  List<Guest> getRespondedGuests(List<Guest> allGuests) {
    return allGuests
        .where((g) => g.status == 'accepted' || g.status == 'declined')
        .toList();
  }

  Future<void> _logReminder({
    required String? eventId,
    required Guest guest,
    required String templateId,
    required String message,
    required String channel,
    required String status,
  }) async {
    final log = ReminderLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      guestId: guest.id,
      guestName: guest.name,
      guestPhone: guest.phone,
      templateId: templateId,
      message: message,
      channel: channel,
      status: status,
      sentAt: DateTime.now(),
    );

    _history.insert(0, log);
    notifyListeners();

    if (eventId != null) {
      try {
        await _client.from('reminders').insert({
          ...log.toMap(),
          'event_id': eventId,
        });
      } catch (_) {}
    }
  }
}
