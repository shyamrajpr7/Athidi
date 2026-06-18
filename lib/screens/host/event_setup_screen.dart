import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/providers/event_provider.dart';
import 'package:athidhi/providers/guest_provider.dart';
import 'package:athidhi/providers/language_provider.dart';
import 'package:athidhi/screens/host/host_dashboard.dart';

class EventSetupScreen extends StatefulWidget {
  const EventSetupScreen({super.key});

  @override
  State<EventSetupScreen> createState() => _EventSetupScreenState();
}

class _EventSetupScreenState extends State<EventSetupScreen> {
  final _groomController = TextEditingController();
  final _brideController = TextEditingController();
  final _dateController = TextEditingController();
  final _muhurthamController = TextEditingController();
  final _venueController = TextEditingController();
  final _upiController = TextEditingController();
  final _livestreamController = TextEditingController();
  bool _isLoading = false;

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
          lang.t('ഇവന്റ് വിവരങ്ങൾ', 'Event Setup'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Text('💍', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lang.t(
                        'നിങ്ങളുടെ വിവാഹ വിവരങ്ങൾ നൽകുക',
                        'Enter your wedding details',
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel(lang.t('വരന്റെ പേര്', 'Groom\'s Name')),
            _buildInput(_groomController, lang.t('പേര് നൽകുക', 'Enter name')),
            const SizedBox(height: 16),
            _buildLabel(lang.t('വധുവിന്റെ പേര്', 'Bride\'s Name')),
            _buildInput(_brideController, lang.t('പേര് നൽകുക', 'Enter name')),
            const SizedBox(height: 16),
            _buildLabel(lang.t('വിവാഹ തീയതി', 'Wedding Date')),
            _buildInput(
              _dateController,
              'YYYY-MM-DD',
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                  builder: (ctx, child) => Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme:
                          const ColorScheme.light(primary: AppColors.primary),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  _dateController.text = picked.toIso8601String().split('T')[0];
                }
              },
              readOnly: true,
            ),
            const SizedBox(height: 16),
            _buildLabel(lang.t('മുഹൂർത്തം സമയം', 'Muhurtham Time')),
            _buildInput(_muhurthamController, '10:30 AM'),
            const SizedBox(height: 16),
            _buildLabel(lang.t('വേദി', 'Venue')),
            _buildInput(_venueController,
                lang.t('സ്ഥലം നൽകുക', 'Enter venue name and location')),
            const SizedBox(height: 16),
            _buildLabel(lang.t('UPI ID (മൊഴ്ദ്)', 'UPI ID (for Moidhu)')),
            _buildInput(_upiController, 'yourname@upi'),
            const SizedBox(height: 16),
            _buildLabel(lang.t(
                'ലൈവ്സ്ട്രീം URL (ഓപ്ഷണൽ)', 'Livestream URL (Optional)')),
            _buildInput(_livestreamController, 'https://youtube.com/live/...'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        lang.t('സേവ് ചെയ്യുക', 'Save Event'),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 40),
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

  Widget _buildInput(
    TextEditingController controller,
    String hint, {
    TextInputType type = TextInputType.text,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        readOnly: readOnly,
        onTap: onTap,
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

  void _handleSave() async {
    if (_groomController.text.isEmpty ||
        _brideController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _muhurthamController.text.isEmpty ||
        _venueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LanguageProvider>().t(
                  'ദയവായി എല്ലാ വിവരങ്ങളും നൽകുക',
                  'Please fill all required fields',
                ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final eventId = await context.read<EventProvider>().createEvent(
          groomName: _groomController.text,
          brideName: _brideController.text,
          date: _dateController.text,
          muhurtham: _muhurthamController.text,
          venue: _venueController.text,
          upiId: _upiController.text,
          livestreamUrl: _livestreamController.text,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (eventId != null) {
        context.read<GuestProvider>().loadGuests(eventId);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HostDashboard()),
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _groomController.dispose();
    _brideController.dispose();
    _dateController.dispose();
    _muhurthamController.dispose();
    _venueController.dispose();
    _upiController.dispose();
    _livestreamController.dispose();
    super.dispose();
  }
}
