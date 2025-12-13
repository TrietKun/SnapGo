import 'package:json_annotation/json_annotation.dart';
import 'best_time_info.dart';

part 'spot_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class SpotEntity {
  final String id;
  final String name;
  final String description;
  final List<String> imageUrls;

  final double latitude;
  final double longitude;
  final String address;
  final String district;
  final String city;

  final List<String> categories;
  final List<String> tags;

  final BestTimeInfo bestTime;

  final double ratingAverage;
  final int ratingCount;
  final Map<int, int> ratingBreakdown;

  final int checkInCount;

  final int views;
  final int favorites;
  final int shares;
  final int trendingScore;

  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isVerified;

  SpotEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.district,
    required this.city,
    required this.categories,
    required this.tags,
    required this.bestTime,
    required this.ratingAverage,
    required this.ratingCount,
    required this.ratingBreakdown,
    required this.checkInCount,
    required this.views,
    required this.favorites,
    required this.shares,
    required this.trendingScore,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.isVerified,
  });

  // ✅ Custom fromJson với locale support
  factory SpotEntity.fromJson(Map<String, dynamic> json, {String? locale}) {
    final currentLocale = locale ?? 'en';

    return SpotEntity(
      id: json['id'] as String,

      // ✅ Extract localized strings
      name: _extractLocalized(json['name'], currentLocale),
      description: _extractLocalized(json['description'], currentLocale),
      address: _extractLocalized(json['address'], currentLocale),

      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],

      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      district: json['district'] as String,
      city: json['city'] as String,

      // ✅ Extract localized lists
      categories: _extractLocalizedList(json['categories'], currentLocale),
      tags: _extractLocalizedList(json['tags'], currentLocale),

      bestTime: BestTimeInfo.fromJson(
        json['bestTime'] as Map<String, dynamic>,
      ),

      ratingAverage: (json['ratingAverage'] as num).toDouble(),
      ratingCount: json['ratingCount'] as int,

      ratingBreakdown: (json['ratingBreakdown'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(int.parse(k), v as int)) ??
          {},

      checkInCount: json['checkInCount'] as int,
      views: json['views'] as int,
      favorites: json['favorites'] as int,
      shares: json['shares'] as int,
      trendingScore: json['trendingScore'] as int,

      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      isVerified: json['isVerified'] as bool,
    );
  }

  // ✅ Helper method to extract localized string
  static String _extractLocalized(dynamic value, String locale) {
    if (value is String) {
      return value;
    } else if (value is Map) {
      return value[locale]?.toString() ??
          value['vi']?.toString() ??
          value['en']?.toString() ??
          '';
    }
    return '';
  }

  // ✅ Helper method to extract localized list
  static List<String> _extractLocalizedList(dynamic value, String locale) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    } else if (value is Map) {
      final list = value[locale] ?? value['vi'] ?? value['en'] ?? [];
      return (list as List).map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() => _$SpotEntityToJson(this);

  SpotEntity copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? imageUrls,
    double? latitude,
    double? longitude,
    String? address,
    String? district,
    String? city,
    List<String>? categories,
    List<String>? tags,
    BestTimeInfo? bestTime,
    double? ratingAverage,
    int? ratingCount,
    Map<int, int>? ratingBreakdown,
    int? checkInCount,
    int? views,
    int? favorites,
    int? shares,
    int? trendingScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isVerified,
  }) {
    return SpotEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      district: district ?? this.district,
      city: city ?? this.city,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      bestTime: bestTime ?? this.bestTime,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
      ratingBreakdown: ratingBreakdown ?? this.ratingBreakdown,
      checkInCount: checkInCount ?? this.checkInCount,
      views: views ?? this.views,
      favorites: favorites ?? this.favorites,
      shares: shares ?? this.shares,
      trendingScore: trendingScore ?? this.trendingScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
