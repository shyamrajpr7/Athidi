import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athidhi/models/guest_model.dart';

enum GuestStatus { initial, loading, loaded, error }

class GuestProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  GuestStatus _status = GuestStatus.initial;
  List<Guest> _guests = [];
  String _searchQuery = '';
  String _selectedGroup = 'All';
  String? _eventId;

  GuestStatus get status => _status;
  List<Guest> get guests => _guests;
  String get searchQuery => _searchQuery;
  String get selectedGroup => _selectedGroup;
  String? get eventId => _eventId;

  List<Guest> get filteredGuests {
    var result = _guests.where((g) {
      if (_selectedGroup != 'All' && g.group != _selectedGroup) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!g.name.toLowerCase().contains(q) &&
            !g.phone.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
    return result;
  }

  int get totalInvited => _guests.length;
  int get totalViewed => _guests.where((g) => g.status == 'viewed').length;
  int get totalAccepted => _guests.where((g) => g.status == 'accepted').length;
  int get totalDeclined => _guests.where((g) => g.status == 'declined').length;

  int get totalHeadcount {
    return _guests
        .where((g) => g.status == 'accepted')
        .fold(0, (sum, g) => sum + g.attendingCount);
  }

  List<Guest> get priorityPendingGuests {
    const priorityGroups = ['Close Family', 'VIP'];
    return _guests.where((g) {
      return priorityGroups.contains(g.group) &&
          g.status != 'accepted' &&
          g.status != 'declined';
    }).toList();
  }

  Future<void> loadGuests(String eventId) async {
    _status = GuestStatus.loading;
    _eventId = eventId;
    notifyListeners();

    try {
      final response = await _client
          .from('guests')
          .select()
          .eq('event_id', eventId);

      _guests = (response as List)
          .map((g) => Guest.fromMap(g as Map<String, dynamic>))
          .toList();
      _status = GuestStatus.loaded;
    } catch (e) {
      _status = GuestStatus.error;
    }
    notifyListeners();
  }

  Future<void> addGuest(Guest guest) async {
    if (_eventId == null) return;

    try {
      await _client.from('guests').insert({
        ...guest.toMap(),
        'event_id': _eventId,
      });
      _guests.add(guest);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> deleteGuest(String id) async {
    try {
      await _client.from('guests').delete().eq('id', id);
      _guests.removeWhere((g) => g.id == id);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updateGuestStatus(String id, String status) async {
    try {
      await _client.from('guests').update({'status': status}).eq('id', id);
      final index = _guests.indexWhere((g) => g.id == id);
      if (index != -1) {
        _guests[index] = _guests[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (_) {}
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedGroup(String group) {
    _selectedGroup = group;
    notifyListeners();
  }
}
