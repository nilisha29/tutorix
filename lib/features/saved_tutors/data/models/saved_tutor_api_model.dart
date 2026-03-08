class SavedTutorApiModel {
  const SavedTutorApiModel({required this.data});

  final Map<String, dynamic> data;

  factory SavedTutorApiModel.fromJson(Map<String, dynamic> json) {
    return SavedTutorApiModel(data: json);
  }

  Map<String, dynamic> toJson() => data;
}
