import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/token_storage.dart';

class ProfileScreen extends StatefulWidget {
  final bool showAppBar;

  const ProfileScreen({super.key, this.showAppBar = true});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  String? _displayName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
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
          _user = user;
          _displayName = savedName;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถโหลดโปรไฟล์ได้ กรุณาล็อกอินใหม่')),
        );
      }
    }
  }

  Future<void> _editDisplayName() async {
    final controller = TextEditingController(
      text: _displayName?.isNotEmpty == true ? _displayName! : (_user?.fname ?? ''),
    );
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ตั้งชื่อสำหรับทักทาย'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'ชื่อที่ต้องการแสดง (Custom)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await TokenStorage.saveDisplayName(name, _user?.id ?? '');
      if (mounted) setState(() => _displayName = name);
    }
  }

  Future<void> _logout() async {
    final token = ApiService.token;
    if (token != null) {
      try {
        await ApiService.logout(token);
      } catch (_) {}
    }
    ApiService.token = null;
    await TokenStorage.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'สวัสดีตอนเช้า';
    if (hour < 17) return 'สวัสดีตอนบ่าย';
    return 'สวัสดีตอนเย็น';
  }

  String get _displayFullName {
    if (_displayName != null && _displayName!.isNotEmpty) return _displayName!;
    return _user?.fullName ?? '-';
  }

  String get _osName {
    if (kIsWeb) return 'Web';
    switch (Platform.operatingSystem) {
      case 'android':
        return 'Android';
      case 'ios':
        return 'iOS';
      case 'linux':
        return 'Linux';
      case 'macos':
        return 'macOS';
      case 'windows':
        return 'Windows';
      case 'fuchsia':
        return 'Fuchsia';
      default:
        return Platform.operatingSystem;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final day = '${date.day}'.padLeft(2, '0');
    final month = '${date.month}'.padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(title: const Text('โปรไฟล์ผู้ใช้งาน')) : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.primary,
                          child: Icon(Icons.person, size: 48, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$_greeting, $_displayFullName!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user?.email ?? '-',
                          style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _editDisplayName,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('ตั้งชื่อสำหรับทักทาย'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ประวัติส่วนตัว',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.badge_outlined, color: AppTheme.primary),
                          title: const Text('User ID', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          subtitle: Text(_user?.id ?? '-', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.email_outlined, color: AppTheme.primary),
                          title: const Text('อีเมลองค์กร', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          subtitle: Text(_user?.email ?? '-', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.person_outline, color: AppTheme.primary),
                          title: const Text('ชื่อ-นามสกุล', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          subtitle: Text(_user?.fullName ?? '-', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.devices_outlined, color: AppTheme.primary),
                          title: const Text('ระบบปฏิบัติการที่ใช้งานอยู่ (Active OS)', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          subtitle: Text(_osName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.event_outlined, color: AppTheme.primary),
                          title: const Text('สมัครสมาชิกเมื่อ', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          subtitle: Text(_formatDate(_user?.createdAt), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.danger),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: AppTheme.danger),
                      label: const Text('ออกจากระบบ (Logout)', style: TextStyle(color: AppTheme.danger, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
