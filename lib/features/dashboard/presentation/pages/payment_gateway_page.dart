import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/api/api_endpoints.dart';
import 'package:tutorix/features/dashboard/presentation/pages/booking_store.dart';
import 'package:tutorix/features/dashboard/presentation/pages/payment_success_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class PaymentGatewayPage extends ConsumerStatefulWidget {
  const PaymentGatewayPage({
    super.key,
    required this.method,
    required this.booking,
  });

  final String method;
  final BookingRecord booking;

  @override
  ConsumerState<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends ConsumerState<PaymentGatewayPage> {
  static const String _defaultEsewaUatFormUrl = 'https://rc-epay.esewa.com.np/epay/main';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController =
      TextEditingController(text: 'Saanvi Thapa');
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isProcessing = false;

  String _normalizeTutorId(String raw) {
    final text = raw.trim();
    final match = RegExp(r'[a-fA-F0-9]{24}').firstMatch(text);
    return (match?.group(0) ?? text).trim();
  }

  List<Map<String, dynamic>> _buildInitiatePayloadCandidates() {
    final tutorId = _normalizeTutorId(widget.booking.tutorId);
    final amountNum = widget.booking.totalPrice;
    final base = <String, dynamic>{
      'tutorId': tutorId,
      'date': widget.booking.dateLabel,
      'time': widget.booking.timeLabel,
      'duration': widget.booking.durationMinutes.toString(),
      'paymentMethod': 'esewa',
      'amount': amountNum,
    };

    return <Map<String, dynamic>>[base];
  }

  List<Map<String, dynamic>> _buildCreateBookingPayloadCandidates() {
    final tutorId = _normalizeTutorId(widget.booking.tutorId);
    final amountNum = widget.booking.totalPrice;
    final amountString = widget.booking.totalPrice.toStringAsFixed(2);

    return <Map<String, dynamic>>[
      {
        'tutorId': tutorId,
        'date': widget.booking.dateLabel,
        'time': widget.booking.timeLabel,
        'duration': widget.booking.durationMinutes,
        'amount': amountNum,
        'paymentMethod': 'esewa',
      },
      {
        'teacherId': tutorId,
        'date': widget.booking.dateLabel,
        'time': widget.booking.timeLabel,
        'duration': widget.booking.durationMinutes.toString(),
        'amount': amountString,
        'paymentMethod': 'esewa',
      },
      {
        'tutor': tutorId,
        'date': widget.booking.dateLabel,
        'time': widget.booking.timeLabel,
        'duration': widget.booking.durationMinutes,
        'totalPrice': amountNum,
        'paymentMethod': 'esewa',
      },
    ];
  }

  String _extractBackendErrorMessage(DioException? error) {
    if (error == null) return 'Failed to start eSewa checkout.';
    final data = error.response?.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data as Map);
      final message = map['message']?.toString();
      if (message != null && message.trim().isNotEmpty) return message.trim();
      final errors = map['errors'];
      if (errors != null) return errors.toString();
    }
    final code = error.response?.statusCode;
    if (code == 401) return 'Unauthorized. Please login again.';
    if (code == 404) {
      final path = error.requestOptions.path;
      return 'Payment initiate endpoint not found (404): $path';
    }
    if (code == 400 || code == 422) {
      return 'Invalid payment request. Please check booking details and try again.';
    }
    return 'Failed to start eSewa checkout (${code ?? 'unknown error'}).';
  }

  String _extractResponseMessage(dynamic data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data as Map);
      final direct = map['message']?.toString();
      if (direct != null && direct.trim().isNotEmpty) return direct.trim();
      final nested = map['data'];
      if (nested is Map) {
        final nestedMsg = nested['message']?.toString();
        if (nestedMsg != null && nestedMsg.trim().isNotEmpty) return nestedMsg.trim();
      }
      if (map['errors'] != null) return map['errors'].toString();
    }
    return 'Failed to start eSewa checkout.';
  }

  Map<String, String> _extractFormFields(dynamic raw) {
    if (raw is! Map) return const <String, String>{};
    final map = Map<String, dynamic>.from(raw as Map);
    final keys = <String>[
      'redirectFormFields',
      'formFields',
      'form_fields',
      'fields',
      'payload',
      'formData',
      'form_data',
      'params',
    ];

    for (final key in keys) {
      final value = map[key];
      if (value is Map) {
        final out = <String, String>{};
        value.forEach((fieldKey, fieldValue) {
          if (fieldKey != null && fieldValue != null) {
            out[fieldKey.toString()] = fieldValue.toString();
          }
        });
        if (out.isNotEmpty) return out;
      }
    }

    return const <String, String>{};
  }

  Map<String, String> _extractEsewaStandardFields(Map<String, dynamic> source) {
    const keys = <String>[
      'amount',
      'amt',
      'product_service_charge',
      'pdc',
      'product_delivery_charge',
      'psc',
      'txAmt',
      'tax_amount',
      'service_charge',
      'delivery_charge',
      'tAmt',
      'total_amount',
      'pid',
      'transaction_uuid',
      'product_code',
      'scd',
      'su',
      'success_url',
      'fu',
      'failure_url',
      'signature',
      'signed_field_names',
    ];

    final fields = <String, String>{};
    for (final key in keys) {
      final value = source[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        fields[key] = value.toString().trim();
      }
    }

    if (fields.containsKey('tax_amount') && !fields.containsKey('txAmt')) {
      fields['txAmt'] = fields['tax_amount']!;
    }
    if (fields.containsKey('service_charge') && !fields.containsKey('psc')) {
      fields['psc'] = fields['service_charge']!;
    }
    if (fields.containsKey('product_service_charge') && !fields.containsKey('psc')) {
      fields['psc'] = fields['product_service_charge']!;
    }
    if (fields.containsKey('delivery_charge') && !fields.containsKey('pdc')) {
      fields['pdc'] = fields['delivery_charge']!;
    }
    if (fields.containsKey('product_delivery_charge') && !fields.containsKey('pdc')) {
      fields['pdc'] = fields['product_delivery_charge']!;
    }
    if (fields.containsKey('total_amount') && !fields.containsKey('tAmt')) {
      fields['tAmt'] = fields['total_amount']!;
    }
    if (fields.containsKey('amount') && !fields.containsKey('amt')) {
      fields['amt'] = fields['amount']!;
    }
    if (fields.containsKey('transaction_uuid') && !fields.containsKey('pid')) {
      fields['pid'] = fields['transaction_uuid']!;
    }
    if (fields.containsKey('product_code') && !fields.containsKey('scd')) {
      fields['scd'] = fields['product_code']!;
    }
    if (fields.containsKey('success_url') && !fields.containsKey('su')) {
      fields['su'] = fields['success_url']!;
    }
    if (fields.containsKey('failure_url') && !fields.containsKey('fu')) {
      fields['fu'] = fields['failure_url']!;
    }

    return fields;
  }

  bool _looksLikeInitiateSuccess(dynamic data) {
    if (data is String) {
      final text = data.toLowerCase();
      return text.contains('initiat') || text.contains('creat') || text.contains('creted');
    }

    if (data is! Map) return false;
    final map = Map<String, dynamic>.from(data as Map);
    final message = (map['message'] ??
            (map['data'] is Map ? map['data']['message'] : null))
        ?.toString()
        .toLowerCase();
    final successRaw = map['success'] ?? (map['data'] is Map ? map['data']['success'] : null);
    final isSuccessFlag = successRaw == true || successRaw?.toString().toLowerCase() == 'true';
    final hasSuccessMessage = message != null &&
        (message.contains('initiat') ||
            message.contains('creat') ||
            message.contains('creted') ||
            message.contains('success'));
    return isSuccessFlag || hasSuccessMessage;
  }

  _EsewaCheckoutPayload? _buildFallbackCheckoutFromInitiate(dynamic data) {
    if (!_looksLikeInitiateSuccess(data)) return null;

    final merged = <String, dynamic>{};
    if (data is Map) {
      final map = Map<String, dynamic>.from(data as Map);
      final base = map['data'] is Map
          ? Map<String, dynamic>.from(map['data'] as Map)
          : <String, dynamic>{};
      final payment = base['payment'] is Map
          ? Map<String, dynamic>.from(base['payment'] as Map)
          : <String, dynamic>{};
      merged.addAll(map);
      merged.addAll(base);
      merged.addAll(payment);
    }

    final fields = _extractEsewaStandardFields(merged);
    final amount = widget.booking.totalPrice.toStringAsFixed(2);
    fields['amt'] = fields['amt'] ?? amount;
    fields['pdc'] = fields['pdc'] ?? '0';
    fields['psc'] = fields['psc'] ?? '0';
    fields['txAmt'] = fields['txAmt'] ?? '0';
    fields['tAmt'] = fields['tAmt'] ?? amount;
    fields['pid'] =
        fields['pid'] ?? fields['transaction_uuid'] ?? 'TXN${DateTime.now().millisecondsSinceEpoch}';
    fields['scd'] = fields['scd'] ?? fields['product_code'] ?? 'EPAYTEST';
    fields['su'] =
        fields['su'] ?? '${ApiEndpoints.serverUrl}/api/bookings/payments/verify?provider=esewa&status=success';
    fields['fu'] =
        fields['fu'] ?? '${ApiEndpoints.serverUrl}/api/bookings/payments/verify?provider=esewa&status=failed';

    return _EsewaCheckoutPayload(
      redirectUrl: _defaultEsewaUatFormUrl,
      redirectMethod: 'POST',
      redirectFormFields: fields,
      successUrl: fields['su'],
      failureUrl: fields['fu'],
      bookingId: _extractBookingIdFromMap(merged),
      paymentRef: _extractPaymentRefFromMap(merged),
      transactionUuid: fields['transaction_uuid'] ?? fields['pid'],
    );
  }

  List<String> _buildEndpointCandidates() {
    return <String>[
      ApiEndpoints.paymentsInitiate,
    ];
  }

  List<String> _buildEndpointCandidatesWithBookingId(String bookingId) {
    final normalized = bookingId.trim();
    if (normalized.isEmpty) return _buildEndpointCandidates();

    final base = _buildEndpointCandidates();
    return <String>[
      '/bookings/$normalized/payments/initiate',
      '/bookings/$normalized/payment/initiate',
      '/bookings/$normalized/pay',
      ...base,
    ];
  }

  String? _extractBookingIdFromResponseData(dynamic data) {
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data as Map);
    final source = map['data'] is Map
        ? Map<String, dynamic>.from(map['data'] as Map)
        : map;

    final candidates = <dynamic>[
      source['bookingId'],
      source['_id'],
      source['id'],
      source['booking'] is Map
          ? (source['booking']['_id'] ?? source['booking']['id'])
          : null,
    ];

    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  Future<String?> _createBookingIfNeeded(
    Dio dio,
    List<String> baseUrlCandidates,
    List<Map<String, dynamic>> payloadCandidates,
  ) async {
    final endpointCandidates = <String>[
      '/bookings',
      '/bookings/create',
      '/booking',
    ];

    for (final baseUrl in baseUrlCandidates) {
      for (final endpoint in endpointCandidates) {
        final normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
        final url = '$baseUrl$normalizedEndpoint';
        for (final payload in payloadCandidates) {
          try {
            final response = await dio.post(url, data: payload);
            final directCheckout = _extractEsewaCheckoutPayload(response.data);
            if (directCheckout != null && directCheckout.redirectUrl.isNotEmpty) {
              return null;
            }
            final bookingId = _extractBookingIdFromResponseData(response.data);
            if (bookingId != null && bookingId.isNotEmpty) {
              return bookingId;
            }
          } on DioException catch (e) {
            final code = e.response?.statusCode ?? 0;
            if (code == 404 || code == 400 || code == 422) {
              continue;
            }
          }
        }
      }
    }

    return null;
  }

  String? _extractUrlWithKeys(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  List<String> _buildBaseUrlCandidates() {
    final set = <String>{
      ApiEndpoints.baseUrl,
      '${ApiEndpoints.serverUrl}/api/v1',
      ApiEndpoints.serverUrl,
    };
    return set.map((value) => value.replaceFirst(RegExp(r'/+$'), '')).toList();
  }

  String? _extractBookingIdFromMap(Map<String, dynamic> map) {
    final direct = _extractStringByKeys(map, const ['bookingId', 'booking_id', '_id', 'id']);
    if (direct != null && direct.isNotEmpty) return direct;

    final nested = map['booking'];
    if (nested is Map) {
      final nestedMap = Map<String, dynamic>.from(nested as Map);
      return _extractStringByKeys(nestedMap, const ['_id', 'id', 'bookingId', 'booking_id']);
    }
    return null;
  }

  String? _extractPaymentRefFromMap(Map<String, dynamic> map) {
    return _extractStringByKeys(
      map,
      const ['paymentRef', 'payment_ref', 'transaction_uuid', 'transactionUuid', 'pid'],
    );
  }

  String? _extractTransactionUuidFromMap(Map<String, dynamic> map) {
    return _extractStringByKeys(
      map,
      const ['transaction_uuid', 'transactionUuid', 'pid', 'paymentRef', 'payment_ref'],
    );
  }

  Future<bool> _verifyEsewaPayment(
    ApiClient apiClient,
    _EsewaCheckoutPayload payload, {
    required String status,
  }) async {
    final bookingId = payload.bookingId?.trim();
    final paymentRef = payload.paymentRef?.trim();
    final transactionUuid = payload.transactionUuid?.trim();

    final candidates = <Map<String, dynamic>>[];

    if (bookingId != null && bookingId.isNotEmpty) {
      candidates.add({
        'bookingId': bookingId,
        'provider': 'esewa',
        'status': status,
        if (paymentRef != null && paymentRef.isNotEmpty) 'paymentRef': paymentRef,
        if (transactionUuid != null && transactionUuid.isNotEmpty)
          'transactionUuid': transactionUuid,
      });
    }

    if (paymentRef != null && paymentRef.isNotEmpty) {
      candidates.add({
        'paymentRef': paymentRef,
        'provider': 'esewa',
        'status': status,
        if (transactionUuid != null && transactionUuid.isNotEmpty)
          'transactionUuid': transactionUuid,
      });
    }

    if (transactionUuid != null && transactionUuid.isNotEmpty) {
      candidates.add({
        'transactionUuid': transactionUuid,
        'provider': 'esewa',
        'status': status,
      });
    }

    if (candidates.isEmpty) {
      return false;
    }

    for (final body in candidates) {
      try {
        final response = await apiClient.post(ApiEndpoints.paymentsVerify, data: body);
        final data = response.data;
        if (data is Map) {
          final map = Map<String, dynamic>.from(data as Map);
          final directVerified = map['verified'];
          final nestedData = map['data'];

          if (directVerified == true) return true;
          if (nestedData is Map) {
            final nestedMap = Map<String, dynamic>.from(nestedData as Map);
            final nestedVerified = nestedMap['verified'];
            if (nestedVerified == true) return true;

            final booking = nestedMap['booking'];
            if (booking is Map) {
              final bookingMap = Map<String, dynamic>.from(booking as Map);
              final bookingStatus =
                  (bookingMap['bookingStatus'] ?? '').toString().toLowerCase();
              final paymentStatus =
                  (bookingMap['paymentStatus'] ?? '').toString().toLowerCase();
              if (bookingStatus == 'confirmed' || paymentStatus == 'paid') {
                return true;
              }
            }
          }
        }
      } on DioException {
        continue;
      }
    }

    return false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool _isEsewaMethod(String method) {
    final normalized =
        method.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return normalized.contains('esewa');
  }

  Future<void> _handlePay() async {
    if (!_formKey.currentState!.validate()) return;

    final isEsewa = _isEsewaMethod(widget.method);
    if (!isEsewa) {
      BookingStore.addBooking(widget.booking);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PaymentSuccessPage()),
      );
      return;
    }

    final normalizedTutorId = _normalizeTutorId(widget.booking.tutorId);
    if (normalizedTutorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tutor ID is missing. Please re-open tutor profile and book again.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final apiClient = ref.read(apiClientProvider);
    final endpointCandidates = _buildEndpointCandidates();

    final payloadCandidates = _buildInitiatePayloadCandidates();

    DioException? lastError;
    dynamic lastResponseData;

    try {
      for (final endpoint in endpointCandidates) {
        for (final payload in payloadCandidates) {
          try {
            final response = await apiClient.post(endpoint, data: payload);
            lastResponseData = response.data;

            final checkoutPayload =
                _extractEsewaCheckoutPayload(response.data) ??
                _buildFallbackCheckoutFromInitiate(response.data);
            if (checkoutPayload == null || checkoutPayload.redirectUrl.isEmpty) {
              continue;
            }

            final result = await _openEsewaWebView(checkoutPayload);
            if (!mounted) return;

            if (result == _EsewaCheckoutResult.success) {
              final verified = await _verifyEsewaPayment(
                apiClient,
                checkoutPayload,
                status: 'success',
              );
              if (!verified && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment received but verification is still pending.'),
                  ),
                );
              }
              BookingStore.addBooking(widget.booking);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PaymentSuccessPage()),
              );
              return;
            }

            if (result == _EsewaCheckoutResult.failed) {
              await _verifyEsewaPayment(
                apiClient,
                checkoutPayload,
                status: 'failed',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('eSewa payment failed or cancelled.'),
                  backgroundColor: Colors.red.shade600,
                ),
              );
              return;
            }

            if (result == _EsewaCheckoutResult.cancelled) {
              await _verifyEsewaPayment(
                apiClient,
                checkoutPayload,
                status: 'failed',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('eSewa payment cancelled.')),
              );
              return;
            }

            continue;
          } on DioException catch (e) {
            lastError = e;
            final code = e.response?.statusCode ?? 0;
            if (code == 404 || code == 400 || code == 422) {
              continue;
            }
            rethrow;
          }
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lastError != null
                ? _extractBackendErrorMessage(lastError)
                : _extractResponseMessage(lastResponseData),
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is DioException
          ? _extractBackendErrorMessage(e)
          : 'eSewa checkout error: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<_EsewaCheckoutResult> _openEsewaWebView(_EsewaCheckoutPayload payload) async {
    final redirectUri = Uri.tryParse(payload.redirectUrl);
    if (redirectUri == null || !mounted) return _EsewaCheckoutResult.error;

    try {
      final result = await Navigator.push<_EsewaCheckoutResult>(
        context,
        MaterialPageRoute(
          builder: (_) => _EsewaWebViewPage(
            title: 'eSewa Checkout',
            initialUrl: redirectUri,
            postFields: payload.redirectMethod == 'POST'
                ? payload.redirectFormFields
                : null,
            successUrl: payload.successUrl,
            failureUrl: payload.failureUrl,
          ),
        ),
      );
      return result ?? _EsewaCheckoutResult.cancelled;
    } catch (_) {
      return _EsewaCheckoutResult.error;
    }
  }

  _EsewaCheckoutPayload? _extractEsewaCheckoutPayload(dynamic data) {
    if (data is! Map) return null;

    final map = Map<String, dynamic>.from(data);
    final base = map['data'] is Map
        ? Map<String, dynamic>.from(map['data'] as Map)
        : map;

    Map<String, dynamic> source = base;
    if (base['payment'] is Map) {
      source = Map<String, dynamic>.from(base['payment'] as Map);
    } else if (base['checkout'] is Map) {
      source = Map<String, dynamic>.from(base['checkout'] as Map);
    } else if (base['esewa'] is Map) {
      source = Map<String, dynamic>.from(base['esewa'] as Map);
    }

    final mergedSource = <String, dynamic>{
      ...map,
      ...base,
      ...source,
    };

    var redirectUrl = _extractStringByKeys(mergedSource, const [
      'redirectUrl',
      'redirect_url',
      'payment_url',
      'paymentUrl',
      'url',
      'checkoutUrl',
      'action',
      'actionUrl',
      'gatewayUrl',
    ]);

    var formFields = _extractFormFields(source);
    if (formFields.isEmpty) formFields = _extractFormFields(base);
    if (formFields.isEmpty) formFields = _extractFormFields(map);
    if (formFields.isEmpty) formFields = _extractEsewaStandardFields(mergedSource);

    if ((redirectUrl == null || redirectUrl.isEmpty) && formFields.isNotEmpty) {
      redirectUrl = _defaultEsewaUatFormUrl;
    }

    if (redirectUrl == null || redirectUrl.isEmpty) return null;

    final redirectMethod = (_extractStringByKeys(base, const [
          'redirectMethod',
          'redirect_method',
        ]) ??
        (formFields.isNotEmpty ? 'POST' : 'GET'))
        .toUpperCase();

    final successUrl = _extractUrlWithKeys(
      mergedSource,
      const ['successUrl', 'success_url', 'su'],
    );
    final failureUrl = _extractUrlWithKeys(
      mergedSource,
      const ['failureUrl', 'failure_url', 'fu'],
    );

    final transactionUuid = _extractTransactionUuidFromMap(mergedSource) ??
        formFields['transaction_uuid'] ??
        formFields['pid'];

    return _EsewaCheckoutPayload(
      redirectUrl: redirectUrl,
      redirectMethod: redirectMethod,
      redirectFormFields: formFields,
      successUrl: successUrl,
      failureUrl: failureUrl,
      bookingId: _extractBookingIdFromMap(mergedSource),
      paymentRef: _extractPaymentRefFromMap(mergedSource),
      transactionUuid: transactionUuid,
    );
  }

  String? _extractStringByKeys(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEsewa = _isEsewaMethod(widget.method);
    final primaryColor =
        isEsewa ? const Color(0xFF00A73E) : const Color(0xFF5C2D91);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text('${widget.method} Checkout'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Confirm your booking details before gateway payment.',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111111) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.white24 : const Color(0xFFDDE3EA),
                  ),
                ),
                child: Column(
                  children: [
                    _summaryRow('Tutor', widget.booking.tutorName, isDark),
                    _summaryRow(
                      'Date & Time',
                      '${widget.booking.dateLabel} ${widget.booking.timeLabel}',
                      isDark,
                    ),
                    _summaryRow(
                      'Duration',
                      '${widget.booking.durationMinutes} min',
                      isDark,
                    ),
                    _summaryRow(
                      'Amount',
                      'NPR ${widget.booking.totalPrice.toStringAsFixed(2)}',
                      isDark,
                      boldValue: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Full Name'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Enter your name'
                        : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'Mobile Number'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Enter mobile number'
                        : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(hintText: 'Address'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Enter address'
                        : null,
              ),
              const SizedBox(height: 8),
              Text(
                'You selected: ${isEsewa ? 'eSewa' : widget.method}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isProcessing ? null : _handlePay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Pay via ${isEsewa ? 'eSewa' : widget.method}'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _isProcessing ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String key, String value, bool isDark,
      {bool boldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              key,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1D2B4A),
                fontWeight: boldValue ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EsewaCheckoutPayload {
  const _EsewaCheckoutPayload({
    required this.redirectUrl,
    required this.redirectMethod,
    required this.redirectFormFields,
    this.successUrl,
    this.failureUrl,
    this.bookingId,
    this.paymentRef,
    this.transactionUuid,
  });

  final String redirectUrl;
  final String redirectMethod;
  final Map<String, String> redirectFormFields;
  final String? successUrl;
  final String? failureUrl;
  final String? bookingId;
  final String? paymentRef;
  final String? transactionUuid;
}

enum _EsewaCheckoutResult {
  success,
  failed,
  cancelled,
  error,
}

class _EsewaWebViewPage extends StatefulWidget {
  const _EsewaWebViewPage({
    required this.title,
    required this.initialUrl,
    this.postFields,
    this.successUrl,
    this.failureUrl,
  });

  final String title;
  final Uri initialUrl;
  final Map<String, String>? postFields;
  final String? successUrl;
  final String? failureUrl;

  @override
  State<_EsewaWebViewPage> createState() => _EsewaWebViewPageState();
}

class _EsewaWebViewPageState extends State<_EsewaWebViewPage> {
  late final WebViewController _controller;
  late final WebViewCookieManager _cookieManager;
  bool _loading = true;
  String? _errorText;

  bool _isSuccessUrl(Uri uri) {
    final text = uri.toString().toLowerCase();
    final configured = widget.successUrl?.toLowerCase();
    if (configured != null && configured.isNotEmpty && text.startsWith(configured)) {
      return true;
    }

    final status = uri.queryParameters['status']?.toLowerCase();
    final provider = uri.queryParameters['provider']?.toLowerCase();
    return provider == 'esewa' &&
        (status == 'success' || status == 'completed' || status == 'paid');
  }

  bool _isFailureUrl(Uri uri) {
    final text = uri.toString().toLowerCase();
    final configured = widget.failureUrl?.toLowerCase();
    if (configured != null && configured.isNotEmpty && text.startsWith(configured)) {
      return true;
    }

    final status = uri.queryParameters['status']?.toLowerCase();
    final provider = uri.queryParameters['provider']?.toLowerCase();
    return provider == 'esewa' &&
        (status == 'failed' ||
            status == 'failure' ||
            status == 'cancel' ||
            status == 'cancelled' ||
            status == 'canceled');
  }

  @override
  void initState() {
    super.initState();
    final params = PlatformWebViewControllerCreationParams();
    _cookieManager = WebViewCookieManager();
    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && mounted) {
              if (_isSuccessUrl(uri)) {
                Navigator.pop(context, _EsewaCheckoutResult.success);
                return NavigationDecision.prevent;
              }
              if (_isFailureUrl(uri)) {
                Navigator.pop(context, _EsewaCheckoutResult.failed);
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _errorText = 'Failed to load checkout: ${error.description}';
            });
          },
        ),
      );

    final platformController = _controller.platform;
    if (platformController is AndroidWebViewController) {
      AndroidWebViewCookieManager(
        const PlatformWebViewCookieManagerCreationParams(),
      ).setAcceptThirdPartyCookies(
        platformController,
        true,
      );
      platformController.setMediaPlaybackRequiresUserGesture(false);
    }

    _loadCheckoutPage();
  }

  Future<void> _loadCheckoutPage() async {
    await _cookieManager.clearCookies();

    final fields = widget.postFields;
    if (fields != null && fields.isNotEmpty) {
      final formBody = fields.entries
          .map((entry) =>
              '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}')
          .join('&');

      _controller.loadRequest(
        widget.initialUrl,
        method: LoadRequestMethod.post,
        headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
        body: Uint8List.fromList(utf8.encode(formBody)),
      );
      return;
    }

    _controller.loadRequest(widget.initialUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_errorText != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Colors.red.shade600,
                padding: const EdgeInsets.all(10),
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
