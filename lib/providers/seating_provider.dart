import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athidhi/models/seating_table_model.dart';

class SeatingProvider extends ChangeNotifier {
  List<SeatingTableModel> _tables = [];
  bool _isLoading = false;

  List<SeatingTableModel> get tables => _tables;
  bool get isLoading => _isLoading;

  SeatingTableModel? getTableById(String id) {
    try {
      return _tables.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<SeatingTableModel> get unassignedTable {
    return _tables.where((t) => !t.isFull).toList();
  }

  String? findTableForGuest(String guestId) {
    for (final table in _tables) {
      if (table.guestIds.contains(guestId)) return table.id;
    }
    return null;
  }

  void addTable(String label, {int capacity = 8}) {
    final table = SeatingTableModel(
      id: const Uuid().v4(),
      label: label,
      capacity: capacity,
      color: _nextColor(_tables.length),
    );
    _tables.add(table);
    notifyListeners();
  }

  void removeTable(String tableId) {
    _tables.removeWhere((t) => t.id == tableId);
    notifyListeners();
  }

  void renameTable(String tableId, String newLabel) {
    final index = _tables.indexWhere((t) => t.id == tableId);
    if (index == -1) return;
    _tables[index] = _tables[index].copyWith(label: newLabel);
    notifyListeners();
  }

  void assignGuest(String tableId, String guestId) {
    _removeGuestFromAll(guestId);
    final index = _tables.indexWhere((t) => t.id == tableId);
    if (index == -1) return;
    if (_tables[index].isFull) return;
    _tables[index] = _tables[index].copyWith(
      guestIds: [..._tables[index].guestIds, guestId],
    );
    notifyListeners();
  }

  void unassignGuest(String guestId) {
    _removeGuestFromAll(guestId);
    notifyListeners();
  }

  void _removeGuestFromAll(String guestId) {
    for (int i = 0; i < _tables.length; i++) {
      if (_tables[i].guestIds.contains(guestId)) {
        _tables[i] = _tables[i].copyWith(
          guestIds: _tables[i].guestIds.where((id) => id != guestId).toList(),
        );
      }
    }
  }

  int get totalCapacity =>
      _tables.fold(0, (sum, t) => sum + t.capacity);
  int get totalFilled =>
      _tables.fold(0, (sum, t) => sum + t.filledCount);

  static const List<Color> _tableColors = [
    Colors.indigo,
    Colors.teal,
    Colors.deepOrange,
    Colors.purple,
    Colors.green,
    Colors.pink,
    Colors.brown,
    Colors.blueGrey,
    Colors.cyan,
    Colors.amber,
  ];

  static Color _nextColor(int index) =>
      _tableColors[index % _tableColors.length];

  void loadTables() {
    _isLoading = true;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _tables.clear();
    notifyListeners();
  }
}
