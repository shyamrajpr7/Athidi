import 'package:flutter/material.dart';

class SeatingTableModel {
  final String id;
  final String label;
  final int capacity;
  final Color color;
  final List<String> guestIds;

  SeatingTableModel({
    required this.id,
    required this.label,
    this.capacity = 8,
    this.color = Colors.blueGrey,
    this.guestIds = const [],
  });

  int get filledCount => guestIds.length;
  bool get isFull => filledCount >= capacity;

  SeatingTableModel copyWith({
    String? id,
    String? label,
    int? capacity,
    Color? color,
    List<String>? guestIds,
  }) {
    return SeatingTableModel(
      id: id ?? this.id,
      label: label ?? this.label,
      capacity: capacity ?? this.capacity,
      color: color ?? this.color,
      guestIds: guestIds ?? this.guestIds,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'capacity': capacity,
        'colorValue': color.value,
        'guest_ids': guestIds,
      };

  factory SeatingTableModel.fromMap(Map<String, dynamic> map) =>
      SeatingTableModel(
        id: map['id'] as String,
        label: map['label'] as String,
        capacity: map['capacity'] as int? ?? 8,
        color: Color(map['colorValue'] as int? ?? 0xFF607D8B),
        guestIds: (map['guest_ids'] as List<dynamic>?)
                ?.cast<String>() ??
            [],
      );
}
