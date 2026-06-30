import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum StreamStatus { scheduled, live, ended }

class WishMessage {
  final String id;
  final String guestName;
  final String message;
  final DateTime createdAt;
  final bool approved;

  WishMessage({
    required this.id,
    required this.guestName,
    required this.message,
    required this.createdAt,
    this.approved = true,
  });

  Map<String, dynamic> toMap({required String eventId}) {
    return {
      'id': id,
      'event_id': eventId,
      'guest_name': guestName,
      'message': message,
      'approved': approved,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WishMessage.fromMap(Map<String, dynamic> map) {
    return WishMessage(
      id: map['id'] ?? '',
      guestName: map['guest_name'] ?? '',
      message: map['message'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      approved: map['approved'] ?? true,
    );
  }
}

class LivestreamProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  StreamStatus _status = StreamStatus.scheduled;
  String _streamUrl = '';
  DateTime? _scheduledTime;
  List<WishMessage> _wishes = [];
  bool _isLoading = false;

  StreamStatus get status => _status;
  String get streamUrl => _streamUrl;
  DateTime? get scheduledTime => _scheduledTime;
  List<WishMessage> get wishes => _wishes;
  List<WishMessage> get approvedWishes =>
      _wishes.where((w) => w.approved).toList();
  bool get isLoading => _isLoading;
  bool get isLive => _status == StreamStatus.live;

  StreamSubscription? _wishSubscription;

  void configure({
    required String url,
    StreamStatus status = StreamStatus.scheduled,
    DateTime? scheduledTime,
  }) {
    _streamUrl = url;
    _status = url.isEmpty ? StreamStatus.scheduled : status;
    _scheduledTime = scheduledTime;
    notifyListeners();
  }

  void setStatus(StreamStatus status) {
    _status = status;
    notifyListeners();
  }

  void setStreamUrl(String url) {
    _streamUrl = url;
    notifyListeners();
  }

  void setScheduledTime(DateTime? time) {
    _scheduledTime = time;
    notifyListeners();
  }

  Duration? get countdown {
    if (_scheduledTime == null) return null;
    final diff = _scheduledTime!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  Future<void> loadStream(String eventId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('events')
          .select('livestream_url, stream_status, stream_scheduled_at')
          .eq('id', eventId)
          .maybeSingle();

      if (response != null) {
        _streamUrl = response['livestream_url'] ?? '';
        final statusStr = response['stream_status'] ?? 'scheduled';
        _status = statusStr == 'live'
            ? StreamStatus.live
            : statusStr == 'ended'
                ? StreamStatus.ended
                : StreamStatus.scheduled;
        if (response['stream_scheduled_at'] != null) {
          _scheduledTime = DateTime.parse(response['stream_scheduled_at']);
        }
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateStreamStatus(
      String eventId, StreamStatus status) async {
    _status = status;
    notifyListeners();

    try {
      final statusStr = status == StreamStatus.live
          ? 'live'
          : status == StreamStatus.ended
              ? 'ended'
              : 'scheduled';
      await _client
          .from('events')
          .update({'stream_status': statusStr}).eq('id', eventId);
    } catch (_) {}
  }

  Future<void> updateStreamUrl(String eventId, String url) async {
    _streamUrl = url;
    notifyListeners();

    try {
      await _client
          .from('events')
          .update({'livestream_url': url}).eq('id', eventId);
    } catch (_) {}
  }

  Future<void> sendWish({
    required String eventId,
    required String guestName,
    required String message,
  }) async {
    final wish = WishMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      guestName: guestName,
      message: message,
      createdAt: DateTime.now(),
      approved: true,
    );

    _wishes.insert(0, wish);
    notifyListeners();

    try {
      await _client
          .from('live_wishes')
          .insert(wish.toMap(eventId: eventId));
    } catch (_) {}
  }

  Future<void> deleteWish(String wishId) async {
    _wishes.removeWhere((w) => w.id == wishId);
    notifyListeners();
    try {
      await _client.from('live_wishes').delete().eq('id', wishId);
    } catch (_) {}
  }

  void subscribeToWishes(String eventId) {
    _wishSubscription?.cancel();
    _wishSubscription = _client
        .from('live_wishes')
        .stream(primaryKey: ['id'])
        .eq('event_id', eventId)
        .order('created_at', ascending: false)
        .limit(50)
        .listen(
          (data) {
            _wishes = data
                .map((w) => WishMessage.fromMap(w))
                .toList();
            notifyListeners();
          },
          onError: (_) {},
        );
  }

  Future<void> loadWishes(String eventId) async {
    try {
      final response = await _client
          .from('live_wishes')
          .select()
          .eq('event_id', eventId)
          .order('created_at', ascending: false)
          .limit(50);

      _wishes = (response as List)
          .map((w) => WishMessage.fromMap(w as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  @override
  void dispose() {
    _wishSubscription?.cancel();
    super.dispose();
  }
}
