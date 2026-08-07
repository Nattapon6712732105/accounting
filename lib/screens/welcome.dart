import 'package:flutter/material.dart';
import '../core/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.account_balance, size: 80, color: AppTheme.primary),
              const SizedBox(height: 24),
              const Text(
                'ENTERPRISE ACCOUNTING',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              const SizedBox(height: 8),
              const Text(
                'ระบบจัดการและบันทึกบัญชีทางการเงินสำหรับองค์กร',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.primary),
                ),
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('ลงทะเบียนใช้งาน', style: TextStyle(color: AppTheme.primary, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}