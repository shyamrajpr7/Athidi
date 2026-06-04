class Guest {
  final String id;
  final String name;
  final String phone;
  final String group;
  final String status;
  final int attendingCount;
  final String? note;

  Guest({
    required this.id,
    required this.name,
    required this.phone,
    required this.group,
    required this.status,
    this.attendingCount = 1,
    this.note,
  });

  // Status values: invited, viewed, accepted, declined

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String get groupEmoji {
    switch (group) {
      case 'Close Family':
        return '❤️';
      case 'Extended Family':
        return '👨‍👩‍👧';
      case 'Friends':
        return '😊';
      case 'VIP':
        return '⭐';
      case 'Colleagues':
        return '💼';
      default:
        return '👤';
    }
  }

  Guest copyWith({String? status, int? attendingCount}) {
    return Guest(
      id: id,
      name: name,
      phone: phone,
      group: group,
      status: status ?? this.status,
      attendingCount: attendingCount ?? this.attendingCount,
      note: note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'group': group,
      'status': status,
      'attendingCount': attendingCount,
      'note': note,
    };
  }

  factory Guest.fromMap(Map<String, dynamic> map) {
    return Guest(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      group: map['group'] ?? 'Friends',
      status: map['status'] ?? 'invited',
      attendingCount: map['attendingCount'] ?? 1,
      note: map['note'],
    );
  }
}
