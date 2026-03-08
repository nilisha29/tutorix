class BookingApiModel {
  const BookingApiModel({required this.data});

  final Map<String, dynamic> data;

  factory BookingApiModel.fromJson(Map<String, dynamic> json) {
    return BookingApiModel(data: json);
  }

  Map<String, dynamic> toJson() => data;
}
