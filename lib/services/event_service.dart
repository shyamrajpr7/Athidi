import 'package:supabase_flutter/supabase_flutter.dart';

class EventService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> getEvent() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('events')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    return response;
  }

  Future<String> createEvent({
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
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _client.from('events').insert({
      'user_id': user.id,
      'groom_name': groomName,
      'bride_name': brideName,
      'date': date,
      'muhurtham': muhurtham,
      'venue': venue,
      'venue_lat': venueLat ?? 10.5276,
      'venue_lng': venueLng ?? 76.2144,
      'livestream_url': livestreamUrl ?? '',
      'upi_id': upiId ?? '',
    }).select().single();

    return response['id'] as String;
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    await _client.from('events').update(data).eq('id', eventId);
  }
}
