import 'package:flutter/material.dart';
import 'package:athidhi/services/event_service.dart';

enum EventStatus { initial, loading, loaded, error }

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();

  EventStatus _status = EventStatus.initial;
  Map<String, dynamic>? _event;
  String _errorMessage = '';

  // Getters
  EventStatus get status => _status;
  Map<String, dynamic>? get event => _event;
  String get errorMessage => _errorMessage;
  String? get eventId => _event?['id'] as String?;

  String get groomName => _event?['groom_name'] ?? 'Groom';
  String get brideName => _event?['bride_name'] ?? 'Bride';
  String get date => _event?['date'] ?? '';
  String get muhurtham => _event?['muhurtham'] ?? '';
  String get venue => _event?['venue'] ?? '';
  double get venueLat => (_event?['venue_lat'] ?? 10.5276) as double;
  double get venueLng => (_event?['venue_lng'] ?? 76.2144) as double;
  String get livestreamUrl => _event?['livestream_url'] ?? '';
  String get upiId => _event?['upi_id'] ?? '';

  int get daysLeft {
    if (_event?['date'] == null) return 0;
    try {
      final eventDate = DateTime.parse(_event!['date']);
      return eventDate.difference(DateTime.now()).inDays;
    } catch (_) {
      return 0;
    }
  }

  // Load event
  Future<void> loadEvent() async {
    _status = EventStatus.loading;
    notifyListeners();

    try {
      final event = await _eventService.getEvent();
      _event = event;
      _status = EventStatus.loaded;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _status = EventStatus.error;
      notifyListeners();
    }
  }

  // Create event
  Future<String?> createEvent({
    required String groomName,
    required String brideName,
    required String date,
    required String muhurtham,
    required String venue,
    double? venueLat,
    double? venueLng,
    String? livestreamUrl,
    String? upiId,
  }) async {
    _status = EventStatus.loading;
    notifyListeners();

    try {
      final eventId = await _eventService.createEvent(
        groomName: groomName,
        brideName: brideName,
        date: date,
        muhurtham: muhurtham,
        venue: venue,
        venueLat: venueLat,
        venueLng: venueLng,
        livestreamUrl: livestreamUrl,
        upiId: upiId,
      );
      await loadEvent();
      return eventId;
    } catch (e) {
      _errorMessage = e.toString();
      _status = EventStatus.error;
      notifyListeners();
      return null;
    }
  }

  // Update event
  Future<void> updateEvent(Map<String, dynamic> data) async {
    if (eventId == null) return;
    try {
      await _eventService.updateEvent(eventId!, data);
      await loadEvent();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}