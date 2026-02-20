import 'package:json_annotation/json_annotation.dart';

part 'chart_data_point.g.dart';

@JsonSerializable()
class ChartDataPoint {
  final String? label;
  final double? revenue;
  final int? orders;

  ChartDataPoint({this.label, this.revenue, this.orders});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) => _$ChartDataPointFromJson(json);
  Map<String, dynamic> toJson() => _$ChartDataPointToJson(this);
}