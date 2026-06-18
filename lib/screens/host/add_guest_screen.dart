import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/models/guest_model.dart';
import 'package:athidhi/providers/guest_provider.dart';
import 'package:athidhi/providers/language_provider.dart';

class AddGuestScreen extends StatefulWidget {
  const AddGuestScreen({super.key});

  @override
  State<AddGuestScreen> createState() => _AddGuestScreenState();
}

class _AddGuestScreenState extends State<AddGuestScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedGroup = 'Friends';
  int _attendingCount = 1;
  bool _isSaving = false;

  final List<String> _groups = [
    'Close Family',
    'Extended Family',
    'Friends',
    'VIP',
    'Colleagues',
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          lang.t('അതിഥിയെ ചേർക്കുക', 'Add Guest'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(lang.t('പേര്', 'Full Name')),
            _buildInput(
                _nameController, lang.t('പേര് നൽകുക', 'Enter full name')),
            const SizedBox(height: 16),
            _buildLabel(lang.t('ഫോൺ നമ്പർ', 'Phone Number')),
            _buildInput(_phoneController, '9876543210',
                type: TextInputType.phone),
            const SizedBox(height: 16),
            _buildLabel(lang.t('ഗ്രൂപ്പ്', 'Group')),
            _buildGroupSelector(),
            const SizedBox(height: 16),
            _buildLabel(lang.t('വരുന്നവരുടെ എണ്ണം', 'Attending Count')),
            _buildCountSelector(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        lang.t('സേവ് ചെയ്യുക', 'Save Guest'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint,
      {TextInputType type = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildGroupSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _groups.map((g) {
        final selected = g == _selectedGroup;
        return GestureDetector(
          onTap: () => setState(() => _selectedGroup = g),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              g,
              style: TextStyle(
                fontSize: 13,
                color: selected ? Colors.white : AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCountSelector() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (_attendingCount > 1) setState(() => _attendingCount--);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.remove, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          _attendingCount.toString(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => setState(() => _attendingCount++),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _handleSave() async {
    if (_nameController.text.isEmpty || _phoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LanguageProvider>().t(
                  'ദയവായി എല്ലാ വിവരങ്ങളും ശരിയായി നൽകുക',
                  'Please fill all details correctly',
                ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final guest = Guest(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      group: _selectedGroup,
      status: 'invited',
      attendingCount: _attendingCount,
    );

    await context.read<GuestProvider>().addGuest(guest);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LanguageProvider>().t(
                  '${_nameController.text} ചേർത്തു!',
                  '${_nameController.text} added!',
                ),
          ),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
