import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
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

    final endpointCandidates = <String>[
      '/auth/forgot-password',
      '/auth/forgotPassword',
      '/auth/reset-password-link',
      '/users/forgot-password',
      '/forgot-password',
    ];

    final payloadCandidates = <Map<String, dynamic>>[
      {'email': email},
      {'userEmail': email},
      {'username': email},
    ];

    DioException? lastError;

    try {
      for (final path in endpointCandidates) {
        for (final data in payloadCandidates) {
          try {
            await apiClient.post(path, data: data);

            if (!mounted) return;
            SnackbarUtils.showSuccess(
              context,
              'If this email is registered, a reset link has been sent.',
            );
            setState(() => _linkSent = true);
            return;
          } on DioException catch (e) {
            lastError = e;
            if (e.response?.statusCode == 404 ||
                e.response?.statusCode == 400 ||
                e.response?.statusCode == 422) {
              continue;
            }
            rethrow;
          }
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
    final token = _tokenController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() => _loading = true);

    final apiClient = ref.read(apiClientProvider);

    final endpointCandidates = <String>[
      '/auth/reset-password',
      '/auth/resetPassword',
      '/users/reset-password',
      '/users/resetPassword',
      '/reset-password',
    ];

    final payloadCandidates = <Map<String, dynamic>>[
      {
        'email': email,
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
      {
        'email': email,
        'resetToken': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
      {
        'email': email,
        'token': token,
        'password': newPassword,
        'confirmPassword': confirmPassword,
      },
    ];

    DioException? lastError;

    try {
      for (final path in endpointCandidates) {
        for (final data in payloadCandidates) {
          try {
            await apiClient.post(path, data: data);

            if (!mounted) return;
            SnackbarUtils.showSuccess(context, 'Password reset successful. Please login.');
            Navigator.pop(context);
            return;
          } on DioException catch (e) {
            lastError = e;
            final status = e.response?.statusCode ?? 0;
            if (status == 404 || status == 400 || status == 422) {
              continue;
            }
            rethrow;
          }
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
                    labelText: 'Reset Token',
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
