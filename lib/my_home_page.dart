import 'package:flutter/material.dart';
import 'core/theme.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'ENTERPRISE ACCOUNTING',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: const Text('เข้าสู่ระบบ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Hero Banner ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 64, color: AppTheme.primary),
                    const SizedBox(height: 16),
                    const Text(
                      'ระบบบันทึกและจัดการรายรับ-รายจ่าย',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'โซลูชันสำหรับบันทึกรายรับ-รายจ่าย ตรวจสอบธุรกรรมทางการเงิน และสรุปยอดอย่างแม่นยำ ปลอดภัย ตามมาตรฐานองค์กร',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => Navigator.pushNamed(context, '/login'),
                            child: const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppTheme.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => Navigator.pushNamed(context, '/register'),
                            child: const Text('ลงทะเบียน', style: TextStyle(fontSize: 16, color: AppTheme.primary)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- คุณสมบัติหลักของระบบ ---
              const Text(
                'คุณสมบัติหลักของระบบ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.security,
                title: 'การยืนยันตัวตนด้วย JWT Token',
                description: 'เข้าถึงข้อมูลอย่างปลอดภัยด้วยระบบการสิทธิ์ผู้ใช้งานผ่าน JSON Web Token',
              ),
              const SizedBox(height: 10),
              _buildFeatureCard(
                icon: Icons.receipt_long,
                title: 'จัดการรายการ บันทึก/ลบ บัญชี',
                description: 'เพิ่มและลบรายการรายรับ-รายจ่าย พร้อมอัปเดตข้อมูลแบบ Real-time',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}