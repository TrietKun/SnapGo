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

  factory BestTimeInfo.fromJson(Map<String, dynamic> json) =>
      _$BestTimeInfoFromJson(json);

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
