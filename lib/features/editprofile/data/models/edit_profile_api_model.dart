class EditProfileApiModel {
  const EditProfileApiModel({required this.data});

  final Map<String, dynamic> data;

  factory EditProfileApiModel.fromJson(Map<String, dynamic> json) {
    return EditProfileApiModel(data: json);
  }

  Map<String, dynamic> toJson() => data;
}
