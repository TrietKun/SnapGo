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

  factory SpotEntity.fromJson(Map<String, dynamic> json) =>
      _$SpotEntityFromJson(json);

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
