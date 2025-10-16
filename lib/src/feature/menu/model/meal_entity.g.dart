// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealEntity _$MealEntityFromJson(Map<String, dynamic> json) => MealEntity(
  id: json['id'] as String,
  img: json['img'] as String,
  name: json['name'] as String,
  dsc: json['dsc'] as String,
  price: MealEntity._priceFromJson(json['price'] as num?),
  rate: MealEntity._rateFromJson(json['rate'] as num?),
  country: json['country'] as String,
);

Map<String, dynamic> _$MealEntityToJson(MealEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'img': instance.img,
      'name': instance.name,
      'dsc': instance.dsc,
      'price': MealEntity._priceToJson(instance.price),
      'rate': MealEntity._rateToJson(instance.rate),
      'country': instance.country,
    };
