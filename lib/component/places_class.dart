import 'dart:math';

class Place {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String photoUrl;
  final List<String> types;
  final String? description;
  final double? cost;
  final String? workHour;
  final isOpen;
  final rating;

  Place({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.photoUrl,
    required this.types,
    required this.rating,
    this.description,
    this.cost,
    this.workHour,
    this.isOpen,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'photoUrl': photoUrl,
      'types': types,
      'rating': rating,
      'description': description,
      'cost': cost,
      'workHour': workHour,
      'isOpen': isOpen,
    };
  }
}

