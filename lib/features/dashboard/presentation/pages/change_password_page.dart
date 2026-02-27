import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final current = _currentController.text.trim();
    final next = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    setState(() => _loading = true);

    final apiClient = ref.read(apiClientProvider);

    final endpointCandidates = <String>[
      '/auth/change-password',
      '/auth/changePassword',
      '/users/change-password',
      '/users/changePassword',
      '/change-password',
    ];

    final payloadCandidates = <Map<String, dynamic>>[
      {
        'currentPassword': current,
        'newPassword': next,
        'confirmPassword': confirm,
      },
      {
        'oldPassword': current,
        'newPassword': next,
        'confirmPassword': confirm,
      },
      {
        'password': current,
        'newPassword': next,
        'confirmPassword': confirm,
      },
      {
        'currentPassword': current,
        'password': next,
        'confirmPassword': confirm,
      },
    ];

    DioException? lastError;

    try {
      for (final path in endpointCandidates) {
        for (final data in payloadCandidates) {
          try {
            await apiClient.post(path, data: data);

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password changed successfully')),
            );
            Navigator.pop(context);
            return;
          } on DioException catch (e) {
            lastError = e;
            if (e.response?.statusCode == 404) {
              continue;
            }

            final status = e.response?.statusCode ?? 0;
            if (status == 400 || status == 422) {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            backendMessage ??
                lastError?.message ??
                'Change password endpoint not available on backend',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to change password')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentController,
                obscureText: _hideCurrent,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(_hideCurrent ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _hideCurrent = !_hideCurrent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newController,
                obscureText: _hideNew,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(_hideNew ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _hideNew = !_hideNew),
                  ),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Enter new password';
                  if (v.length < 6) return 'Password must be at least 6 characters';
                  if (v == _currentController.text.trim()) {
                    return 'New password must be different';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                obscureText: _hideConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(_hideConfirm ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) return 'Confirm your password';
                  if ((value ?? '').trim() != _newController.text.trim()) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Update Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
