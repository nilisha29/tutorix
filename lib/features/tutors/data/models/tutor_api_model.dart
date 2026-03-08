class TutorApiModel {
  const TutorApiModel({required this.data});

  final Map<String, dynamic> data;

  factory TutorApiModel.fromJson(Map<String, dynamic> json) {
    return TutorApiModel(data: json);
  }

  Map<String, dynamic> toJson() => data;
}
