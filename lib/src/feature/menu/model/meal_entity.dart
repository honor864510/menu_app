import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

@immutable
class MealEntity {
  const MealEntity({
    required this.id,
    required this.img,
    required this.name,
    required this.dsc,
    required this.price,
    required this.rate,
    required this.country,
  });

  factory MealEntity.fromJson(Map<String, dynamic> json) => MealEntity(
    id: json['id'] as String? ?? '',
    img: json['img'] as String? ?? '',
    name: json['name'] as String? ?? '',
    dsc: json['dsc'] as String? ?? '',
    price: _priceFromJson(json['price']),
    rate: _rateFromJson(json['rate']),
    country: json['country'] as String? ?? '',
  );

  final String id;
  final String img;
  final String name;
  final String dsc;
  final double price;
  final double rate;
  final String country;

  Map<String, dynamic> toJson() => {
    'id': id,
    'img': img,
    'name': name,
    'dsc': dsc,
    'price': price,
    'rate': rate,
    'country': country,
  };

  // Handle both int and double prices from JSON
  static double _priceFromJson(Object? value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else if (value is num) {
      return value.toDouble();
    }
    return 0;
  }

  // Handle both int and double rates from JSON
  static double _rateFromJson(Object? value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else if (value is num) {
      return value.toDouble();
    }
    return 0;
  }

  MealEntity copyWith({
    String? id,
    String? img,
    String? name,
    String? dsc,
    double? price,
    double? rate,
    String? country,
  }) => MealEntity(
    id: id ?? this.id,
    img: img ?? this.img,
    name: name ?? this.name,
    dsc: dsc ?? this.dsc,
    price: price ?? this.price,
    rate: rate ?? this.rate,
    country: country ?? this.country,
  );

  @override
  String toString() => 'MealEntity(id: $id, name: $name, price: $price, rate: $rate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MealEntity &&
        other.id == id &&
        other.img == img &&
        other.name == name &&
        other.dsc == dsc &&
        other.price == price &&
        other.rate == rate &&
        other.country == country;
  }

  @override
  int get hashCode =>
      id.hashCode ^ img.hashCode ^ name.hashCode ^ dsc.hashCode ^ price.hashCode ^ rate.hashCode ^ country.hashCode;
}
