class PaymentApiModel {
  const PaymentApiModel({required this.data});

  final Map<String, dynamic> data;

  factory PaymentApiModel.fromJson(Map<String, dynamic> json) {
    return PaymentApiModel(data: json);
  }

  Map<String, dynamic> toJson() => data;
}
