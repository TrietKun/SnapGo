// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'best_time_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BestTimeInfo _$BestTimeInfoFromJson(Map<String, dynamic> json) => BestTimeInfo(
      description: json['description'] as String,
      months:
          (json['months'] as List<dynamic>).map((e) => e as String).toList(),
      timesOfDay: (json['timesOfDay'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$BestTimeInfoToJson(BestTimeInfo instance) =>
    <String, dynamic>{
      'description': instance.description,
      'months': instance.months,
      'timesOfDay': instance.timesOfDay,
    };
