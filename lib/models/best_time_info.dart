import 'package:json_annotation/json_annotation.dart';

part 'best_time_info.g.dart';

@JsonSerializable(explicitToJson: true)
class BestTimeInfo {
  final String description;
  final List<String> months;
  final List<String> timesOfDay;

  BestTimeInfo({
    required this.description,
    required this.months,
    required this.timesOfDay,
  });

  // ✅ Custom fromJson với locale support
  factory BestTimeInfo.fromJson(Map<String, dynamic> json, {String? locale}) {
    final currentLocale = locale ?? 'vi';

    return BestTimeInfo(
      description: _extractLocalized(
        json['description'],
        currentLocale,
      ),
      months: (json['months'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      timesOfDay: _extractLocalizedList(
        json['timesOfDay'],
        currentLocale,
      ),
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

  Map<String, dynamic> toJson() => _$BestTimeInfoToJson(this);

  BestTimeInfo copyWith({
    String? description,
    List<String>? months,
    List<String>? timesOfDay,
  }) {
    return BestTimeInfo(
      description: description ?? this.description,
      months: months ?? this.months,
      timesOfDay: timesOfDay ?? this.timesOfDay,
    );
  }
}
