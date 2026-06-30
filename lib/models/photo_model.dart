class MemoryPhoto {
  final String id;
  final String eventId;
  final String guestName;
  final String imageUrl;
  final String? caption;
  final String status;
  final DateTime createdAt;

  MemoryPhoto({
    required this.id,
    required this.eventId,
    required this.guestName,
    required this.imageUrl,
    this.caption,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  MemoryPhoto copyWith({String? status}) {
    return MemoryPhoto(
      id: id,
      eventId: eventId,
      guestName: guestName,
      imageUrl: imageUrl,
      caption: caption,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'guest_name': guestName,
      'image_url': imageUrl,
      'caption': caption,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MemoryPhoto.fromMap(Map<String, dynamic> map) {
    return MemoryPhoto(
      id: map['id'] ?? '',
      eventId: map['event_id'] ?? '',
      guestName: map['guest_name'] ?? '',
      imageUrl: map['image_url'] ?? '',
      caption: map['caption'],
      status: map['status'] ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
}
