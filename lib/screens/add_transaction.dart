import 'package:flutter/material.dart';

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

  String _type = 'expense';
  List<CategoryModel> _incomeCategories = [];
  List<CategoryModel> _expenseCategories = [];
  String? _category;
  DateTime _date = DateTime.now();
  bool _isLoadingCategories = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
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
      await ApiService.createTransaction(
        token: token,
        type: _type,
        amount: amount,
        category: _category!,
        description: _descriptionController.text.trim(),
        date: _date.toIso8601String().split('T').first,
      );
      AppState.notifyTransactionsChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกรายการสำเร็จ')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มรายการบันทึก')),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'expense', label: Text('รายจ่าย')),
                      ButtonSegment(value: 'income', label: Text('รายรับ')),
                    ],
                    selected: {_type},
                    onSelectionChanged: (Set<String> sel) => setState(() {
                      _type = sel.first;
                      _category = null;
                    }),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'จำนวนเงิน (บาท)', prefixIcon: Icon(Icons.payments_outlined)),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_type),
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'หมวดหมู่', prefixIcon: Icon(Icons.category_outlined)),
                    items: _visibleCategories
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (value) => setState(() => _category = value),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'รายละเอียด (ไม่บังคับ)', prefixIcon: Icon(Icons.notes_outlined)),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'วันที่',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('บันทึก', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
