class DashboardApiModel {
  const DashboardApiModel({required this.data});

  final Map<String, dynamic> data;

  factory DashboardApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardApiModel(data: json);
  }

  Map<String, dynamic> toJson() => data;
}
