import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final fname = _firstNameController.text.trim();
    final lname = _lastNameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (fname.isEmpty || lname.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('กรุณากรอกข้อมูลให้ครบทุกช่อง');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.register(
        fname: fname,
        lname: lname,
        email: email,
        password: password,
      );
      final token = result['token'] as String?;
      ApiService.token = token;
      await TokenStorage.save(token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลงทะเบียนสำเร็จ ยินดีต้อนรับ!')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ลงทะเบียนบัญชีองค์กร')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('สร้างบัญชีใหม่', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'ชื่อจริง (First Name)', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'นามสกุล (Last Name)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              decoration: const InputDecoration(labelText: 'อีเมล (Email)', prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'รหัสผ่าน (Password)',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('ยืนยันลงทะเบียน', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
