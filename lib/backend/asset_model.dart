import 'package:uuid/uuid.dart';

class Asset {
  final String id;
  final String userId;
  final String roomId;
  final String name;
  final String code;
  final String category;
  final String condition;
  final String? image;
  final DateTime purchasedDate;
  final DateTime lastMaintenance;
  final String type;

  Asset({
    String? id,
    required this.userId,
    required this.roomId,
    required this.name,
    required this.code,
    required this.category,
    required this.condition,
    this.image,
    required this.purchasedDate,
    required this.lastMaintenance,
    required this.type,
  }) : id = id ?? const Uuid().v4();

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['asset_id'],
      userId: json['user_id'],
      roomId: json['room_id'],
      name: json['name'],
      code: json['code'],
      category: json['category'],
      condition: json['condition'],
      image: json['image'],
      purchasedDate: DateTime.parse(json['purchased_date']),
      lastMaintenance: DateTime.parse(json['last_maintenance']),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_id': id,
      'user_id': userId,
      'room_id': roomId,
      'name': name,
      'code': code,
      'category': category,
      'condition': condition,
      'image': image,
      'purchased_date': purchasedDate.toIso8601String(),
      'last_maintenance': lastMaintenance.toIso8601String(),
      'type': type,
    };
  }
}