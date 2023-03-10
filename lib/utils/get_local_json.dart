import 'package:flutter/services.dart' show rootBundle;

Future<String> getLocalMetricCardJson() {
  return rootBundle.loadString('assets/metrics.json');
}

Future<String> getLocalLineChartJson() {
  return rootBundle.loadString('assets/line_chart_data.json');
}

Future<String> getLocalBarChartJson() {
  return rootBundle.loadString('assets/bar_chart_data.json');
}
