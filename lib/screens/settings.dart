import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _emailController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final token = ApiService.token;
    if (token == null) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
      return;
    }

    try {
      final user = await ApiService.getMe(token);
      final savedName = await TokenStorage.readDisplayName(user.id);
      if (mounted) {
        setState(() {
          _fnameController.text = user.fname;
          _lnameController.text = user.lname;
          _emailController.text = user.email;
          _displayNameController.text =
              savedName?.isNotEmpty == true ? savedName! : user.fname;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถโหลดข้อมูลได้ กรุณาล็อกอินใหม่')),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    final fname = _fnameController.text.trim();
    final lname = _lnameController.text.trim();
    final email = _emailController.text.trim();
    final displayName = _displayNameController.text.trim();

    if (fname.isEmpty || lname.isEmpty || email.isEmpty) {
      _showMessage('กรุณากรอกข้อมูลให้ครบทุกช่อง');
      return;
    }

    final token = ApiService.token;
    if (token == null) {
      _showMessage('กรุณาล็อกอินก่อน');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updated = await ApiService.updateProfile(
        token: token,
        fname: fname,
        lname: lname,
        email: email,
      );
      await TokenStorage.saveDisplayName(
        displayName.isNotEmpty ? displayName : null,
        updated.id,
      );
      if (mounted) {
        setState(() {
          _fnameController.text = updated.fname;
          _lnameController.text = updated.lname;
          _emailController.text = updated.email;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลส่วนตัวเรียบร้อย')),
        );
      }
    } catch (e) {
      _showMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่า')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_outline, color: AppTheme.primary),
                            SizedBox(width: 8),
                            Text(
                              'แก้ไขข้อมูลส่วนตัว',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'แก้ไขชื่อ นามสกุล และอีเมลของคุณ',
                          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อสำหรับทักทาย (Display Name)',
                      prefixIcon: Icon(Icons.face_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _fnameController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อจริง (First Name)',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _lnameController,
                    decoration: const InputDecoration(
                      labelText: 'นามสกุล (Last Name)',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'อีเมล (Email)',
                      prefixIcon: Icon(Icons.email_outlined),
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
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'บันทึกข้อมูล',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
