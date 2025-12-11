// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spot_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotEntity _$SpotEntityFromJson(Map<String, dynamic> json) => SpotEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      district: json['district'] as String,
      city: json['city'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      bestTime: BestTimeInfo.fromJson(json['bestTime'] as Map<String, dynamic>),
      ratingAverage: (json['ratingAverage'] as num).toDouble(),
      ratingCount: (json['ratingCount'] as num).toInt(),
      ratingBreakdown: (json['ratingBreakdown'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
      ),
      checkInCount: (json['checkInCount'] as num).toInt(),
      views: (json['views'] as num).toInt(),
      favorites: (json['favorites'] as num).toInt(),
      shares: (json['shares'] as num).toInt(),
      trendingScore: (json['trendingScore'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      isVerified: json['isVerified'] as bool,
    );

Map<String, dynamic> _$SpotEntityToJson(SpotEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imageUrls': instance.imageUrls,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'district': instance.district,
      'city': instance.city,
      'categories': instance.categories,
      'tags': instance.tags,
      'bestTime': instance.bestTime.toJson(),
      'ratingAverage': instance.ratingAverage,
      'ratingCount': instance.ratingCount,
      'ratingBreakdown':
          instance.ratingBreakdown.map((k, e) => MapEntry(k.toString(), e)),
      'checkInCount': instance.checkInCount,
      'views': instance.views,
      'favorites': instance.favorites,
      'shares': instance.shares,
      'trendingScore': instance.trendingScore,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'isVerified': instance.isVerified,
    };
