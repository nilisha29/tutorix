import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/api/api_endpoints.dart';
import 'package:tutorix/core/utils/snackbar_utils.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({
    super.key,
    this.initialEmail = '',
  });

  final String initialEmail;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  bool _linkSent = false;
  static const bool _showDebugSnackbars = true;

  void _showDebugSnack(String message) {
    if (!_showDebugSnackbars || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blueGrey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _extractTokenFromInput(String raw) {
    final input = raw.trim();
    if (input.isEmpty) return '';

    final uri = Uri.tryParse(input);
    if (uri != null) {
      final queryToken = uri.queryParameters['token'];
      if (queryToken != null && queryToken.trim().isNotEmpty) {
        return queryToken.trim();
      }

      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final last = segments.last.trim();
        if (last.isNotEmpty && last.toLowerCase() != 'reset-password') {
          return last;
        }
      }
    }

    final hexToken = RegExp(r'[a-fA-F0-9]{64}').firstMatch(input)?.group(0);
    if (hexToken != null && hexToken.isNotEmpty) return hexToken;

    return input.replaceAll(RegExp(r'^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$'), '');
  }

  String _friendlyDioMessage(DioException? error, {String fallback = 'Request failed'}) {
    if (error == null) return fallback;
    final data = error.response?.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data as Map);
      final msg = map['message']?.toString();
      if (msg != null && msg.trim().isNotEmpty) return msg.trim();
      final errors = map['errors'];
      if (errors != null) return errors.toString();
    }
    final code = error.response?.statusCode;
    if (code == 404) return 'Reset password endpoint not found on backend.';
    return error.message ?? fallback;
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    setState(() => _loading = true);

    final apiClient = ref.read(apiClientProvider);

    final endpointCandidates = <String>[ApiEndpoints.authForgotPassword];

    final payload = <String, dynamic>{'email': email.toLowerCase()};

    DioException? lastError;

    try {
      for (final path in endpointCandidates) {
        try {
          await apiClient.post(
            path,
            data: payload,
            options: Options(
              headers: {
                'x-client-origin': ApiEndpoints.serverUrl,
              },
            ),
          );

          if (!mounted) return;
          SnackbarUtils.showSuccess(
            context,
            'Reset link sent. If link does not open on phone, copy token or full link and paste below.',
          );
          setState(() => _linkSent = true);
          return;
        } on DioException catch (e) {
          lastError = e;
          if (e.response?.statusCode == 404) {
            continue;
          }
          rethrow;
        }
      }

      if (!mounted) return;
      final responseData = lastError?.response?.data;
      final backendMessage = responseData is Map
          ? responseData['message']?.toString()
          : null;

      SnackbarUtils.showError(
        context,
        backendMessage ??
            lastError?.message ??
            'Forgot password endpoint not available on backend',
      );
    } catch (_) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Failed to request reset link');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final token = _extractTokenFromInput(_tokenController.text);
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() => _loading = true);

    final apiClient = ref.read(apiClientProvider);

    final endpointCandidates = <String>[ApiEndpoints.authResetPassword];

    final payload = <String, dynamic>{
      'token': token,
      'password': newPassword,
    };

    DioException? lastError;

    try {
      for (final path in endpointCandidates) {
        try {
          await apiClient.post(path, data: payload);

          if (!mounted) return;
          SnackbarUtils.showSuccess(context, 'Password reset successful. Please login.');
          Navigator.pop(context);
          return;
        } on DioException catch (e) {
          lastError = e;
          final status = e.response?.statusCode ?? 0;
          if (status == 404) {
            continue;
          }
          if (!mounted) return;
          SnackbarUtils.showError(
            context,
            _friendlyDioMessage(e, fallback: 'Failed to reset password'),
          );
          return;
        }
      }

      if (!mounted) return;
      final responseData = lastError?.response?.data;
      final backendMessage = responseData is Map
          ? responseData['message']?.toString()
          : null;

      SnackbarUtils.showError(
        context,
        backendMessage ??
          _friendlyDioMessage(lastError, fallback: 'Failed to reset password') ??
            'Reset password endpoint not available on backend',
      );
    } catch (_) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Failed to reset password');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _linkSent
                    ? 'Check your email for the reset token/link, then complete your new password below.'
                    : 'Enter your account email. We will send a password reset link.',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return 'Please enter your email';
                  if (!email.contains('@')) return 'Please enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _loading ? null : _sendResetLink,
                child: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Send Reset Link'),
              ),
              if (_linkSent) ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _tokenController,
                  decoration: InputDecoration(
                    labelText: 'Reset Token or Link',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (!_linkSent) return null;
                    if ((value ?? '').trim().isEmpty) {
                      return 'Please enter the reset token';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _hideNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    suffixIcon: IconButton(
                      icon: Icon(_hideNewPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _hideNewPassword = !_hideNewPassword),
                    ),
                  ),
                  validator: (value) {
                    if (!_linkSent) return null;
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'Please enter new password';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _hideConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    suffixIcon: IconButton(
                      icon: Icon(_hideConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _hideConfirmPassword = !_hideConfirmPassword),
                    ),
                  ),
                  validator: (value) {
                    if (!_linkSent) return null;
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'Please confirm new password';
                    if (v != _newPasswordController.text.trim()) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _loading ? null : _resetPassword,
                  child: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Reset Password'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
