import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'meal_entity.g.dart';

@immutable
@JsonSerializable()
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

  factory MealEntity.fromJson(Map<String, dynamic> json) => _$MealEntityFromJson(json);

  final String id;
  final String img;
  final String name;
  final String dsc;
  @JsonKey(fromJson: _priceFromJson, toJson: _priceToJson)
  final double price;
  @JsonKey(fromJson: _rateFromJson, toJson: _rateToJson)
  final double rate;
  final String country;

  Map<String, dynamic> toJson() => _$MealEntityToJson(this);

  // Handle both int and double prices from JSON
  static double _priceFromJson(num? value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value.toString()) ?? 0.0;
    }
    return 0;
  }

  static dynamic _priceToJson(double price) => price;

  // Handle both int and double rates from JSON
  static double _rateFromJson(num? value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value.toString()) ?? 0.0;
    }
    return 0;
  }

  static dynamic _rateToJson(double rate) => rate;

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
