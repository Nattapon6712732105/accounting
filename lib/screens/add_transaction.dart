import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/model.dart';
import '../services/api_service.dart';
import '../services/app_state.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionModel? _transaction;
  String _type = 'expense';
  List<CategoryModel> _incomeCategories = [];
  List<CategoryModel> _expenseCategories = [];
  String? _category;
  DateTime _date = DateTime.now();
  bool _isLoadingCategories = true;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _initialized = false;

  bool get _isEditing => _transaction != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is TransactionModel && !_initialized) {
      _initialized = true;
      _transaction = args;
      _type = args.type;
      _category = args.category;
      _date = args.date;
      _amountController.text = args.amount.toStringAsFixed(2);
      _descriptionController.text = args.description;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final result = await ApiService.getCategories();
      if (!mounted) return;
      setState(() {
        _incomeCategories = result['income'] ?? [];
        _expenseCategories = result['expense'] ?? [];
        _isLoadingCategories = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingCategories = false);
      _showError('โหลดหมวดหมู่ไม่สำเร็จ');
    }
  }

  List<CategoryModel> get _visibleCategories =>
      _type == 'income' ? _incomeCategories : _expenseCategories;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('กรุณากรอกจำนวนเงินที่ถูกต้อง');
      return;
    }
    if (_category == null) {
      _showError('กรุณาเลือกหมวดหมู่');
      return;
    }
    final token = ApiService.token;
    if (token == null) {
      _showError('กรุณาล็อกอินก่อนใช้งาน');
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        await ApiService.updateTransaction(
          token: token,
          id: _transaction!.id,
          type: _type,
          amount: amount,
          category: _category!,
          description: _descriptionController.text.trim(),
          date: _date.toIso8601String().split('T').first,
        );
      } else {
        await ApiService.createTransaction(
          token: token,
          type: _type,
          amount: amount,
          category: _category!,
          description: _descriptionController.text.trim(),
          date: _date.toIso8601String().split('T').first,
        );
      }
      AppState.notifyTransactionsChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'แก้ไขรายการสำเร็จ' : 'บันทึกรายการสำเร็จ')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    if (_transaction == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: AppTheme.danger),
            SizedBox(width: 8),
            Text('ลบรายการ', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'ต้องการลบรายการ "${_transaction!.displayTitle}" จำนวน '
          '฿${formatAmount(_transaction!.amount)} หรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบรายการ'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await ApiService.deleteTransaction(token: ApiService.token!, id: _transaction!.id);
      AppState.notifyTransactionsChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบรายการสำเร็จ')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      _showError('ลบไม่สำเร็จ: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'แก้ไขรายการ' : 'เพิ่มรายการบันทึก')),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildTypeToggle(),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'จำนวนเงิน',
                      prefixText: '฿ ',
                      prefixStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.goldDark,
                      ),
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_type),
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'หมวดหมู่',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _visibleCategories
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (value) => setState(() => _category = value),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'รายละเอียด (ไม่บังคับ)',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'วันที่',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        formatDateLong(_date),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gold.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEditing ? 'บันทึกการแก้ไข' : 'บันทึกรายการ',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.danger,
                          side: const BorderSide(color: AppTheme.danger),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isDeleting ? null : _delete,
                        icon: _isDeleting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.danger,
                                ),
                              )
                            : const Icon(Icons.delete_outline),
                        label: const Text('ลบรายการนี้'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.luxuryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              gradient: AppTheme.goldGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isEditing ? Icons.edit_note : Icons.add_chart,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'แก้ไขรายการบันทึก' : 'เพิ่มรายการใหม่',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'บันทึกรายรับ-รายจ่ายอย่างแม่นยำ',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E0D3)),
      ),
      child: Row(
        children: [
          _typeButton('expense', 'รายจ่าย', Icons.trending_down, AppTheme.danger),
          const SizedBox(width: 8),
          _typeButton('income', 'รายรับ', Icons.trending_up, AppTheme.success),
        ],
      ),
    );
  }

  Widget _typeButton(String value, String label, IconData icon, Color color) {
    final selected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _type = value;
          _category = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected ? AppTheme.goldGradient : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textMain,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
