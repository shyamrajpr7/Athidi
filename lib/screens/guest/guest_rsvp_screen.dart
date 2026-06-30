import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/providers/event_provider.dart';
import 'package:athidhi/screens/guest/live_telecast_screen.dart';
import 'package:athidhi/screens/memory/memory_wall_screen.dart';

class GuestRsvpScreen extends StatefulWidget {
  const GuestRsvpScreen({super.key});

  @override
  State<GuestRsvpScreen> createState() => _GuestRsvpScreenState();
}

class _GuestRsvpScreenState extends State<GuestRsvpScreen>
    with SingleTickerProviderStateMixin {
  bool _isMalayalam = true;
  String _rsvpStatus = '';
  int _attendingCount = 1;
  bool _isSubmitting = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  // Event details — from Firestore later
  final String _groomName = 'അർജുൻ';
  final String _brideName = 'ദേവിക';
  final String _date = 'March 15, 2025';
  final String _muhurtham = '10:30 AM';
  final String _venue = 'Ganesh Mahal, Thrissur';
  final double _venueLat = 10.5276;
  final double _venueLng = 76.2144;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroSection(),
              _buildEventDetails(),
              _buildRsvpSection(),
              if (_rsvpStatus == 'accepted') _buildAttendingCount(),
              _buildActionButtons(),
              _buildMoidhuSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Language toggle
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => setState(() => _isMalayalam = !_isMalayalam),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _isMalayalam ? 'English' : 'മലയാളം',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Ring icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
            ),
            child: const Center(
              child: Text('💍', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isMalayalam ? 'വിവാഹ ക്ഷണം' : 'Wedding Invitation',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_groomName & $_brideName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isMalayalam
                ? 'വിവാഹ ആഘോഷത്തിലേക്ക് സ്വാഗതം'
                : 'You are warmly invited',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEventDetails() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            '📅',
            _isMalayalam ? 'തീയതി' : 'Date',
            _date,
          ),
          const Divider(height: 24, color: AppColors.border),
          _buildDetailRow(
            '⏰',
            _isMalayalam ? 'മുഹൂർത്തം' : 'Muhurtham',
            _muhurtham,
          ),
          const Divider(height: 24, color: AppColors.border),
          _buildDetailRow(
            '📍',
            _isMalayalam ? 'സ്ഥലം' : 'Venue',
            _venue,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRsvpSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isMalayalam
                ? 'നിങ്ങൾ വരുന്നുണ്ടോ?'
                : 'Will you be attending?',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRsvpButton(
                  'accepted',
                  _isMalayalam ? 'അതെ, വരും! 🎉' : 'Yes, attending! 🎉',
                  AppColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRsvpButton(
                  'declined',
                  _isMalayalam ? 'ഇല്ല, കഴിയില്ല 😔' : 'Sorry, can\'t make it 😔',
                  Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRsvpButton(String status, String label, Color color) {
    final isSelected = _rsvpStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _rsvpStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildAttendingCount() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isMalayalam ? 'എത്ര പേർ വരും?' : 'How many attending?',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (_attendingCount > 1) {
                    setState(() => _attendingCount--);
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.remove,
                      color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 24),
              Text(
                _attendingCount.toString(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () => setState(() => _attendingCount++),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              _isMalayalam
                  ? '$_attendingCount പേർ — സദ്യയ്ക്ക് ഉൾപ്പെടുത്തും'
                  : '$_attendingCount people — included in Sadhya count',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Confirm RSVP
          if (_rsvpStatus.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleRsvpSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isMalayalam
                            ? 'RSVP സ്ഥിരീകരിക്കുക'
                            : 'Confirm RSVP',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          const SizedBox(height: 12),
          // Maps and Calendar row
          Row(
            children: [
              Expanded(
                child: _buildOutlineButton(
                  icon: Icons.map_outlined,
                  label: _isMalayalam ? 'ദിശകൾ' : 'Get Directions',
                  onTap: _openMaps,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildOutlineButton(
                  icon: Icons.calendar_today_outlined,
                  label: _isMalayalam ? 'കലണ്ടർ' : 'Add to Calendar',
                  onTap: _addToCalendar,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Livestream
          _buildOutlineButton(
            icon: Icons.live_tv_outlined,
            label: _isMalayalam
                ? 'തത്സമയം കാണുക 📺'
                : 'Watch Live 📺',
            onTap: () {
              final event = context.read<EventProvider>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LiveTelecastScreen(
                    eventId: event.eventId ?? 'preview',
                    groomName: event.groomName,
                    brideName: event.brideName,
                  ),
                ),
              );
            },
            fullWidth: true,
          ),
          const SizedBox(height: 10),
          // Memory Wall
          _buildOutlineButton(
            icon: Icons.photo_library_outlined,
            label: _isMalayalam
                ? 'മെമ്മറി വാൾ കാണുക'
                : 'Memory Wall',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MemoryWallScreen(
                    eventId: 'preview',
                    isHost: false,
                  ),
                ),
              );
            },
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOutlineButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoidhuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.gold.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 10),
          Text(
            _isMalayalam ? 'ഡിജിറ്റൽ മൊഴ്ദ്' : 'Digital Moidhu',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isMalayalam
                ? 'ഓൺലൈനായി ഒരു സമ്മാനം അയക്കൂ'
                : 'Send a gift online directly to the couple',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Quick amount buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [501, 1001, 2001, 5001].map((amount) {
              return GestureDetector(
                onTap: () => _openUpiPayment(amount),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '₹$amount',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openUpiPayment(null),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _isMalayalam
                    ? 'ഇഷ്ടമുള്ള തുക നൽകുക'
                    : 'Enter Custom Amount',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRsvpSubmit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isSubmitting = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                _rsvpStatus == 'accepted'
                    ? (_isMalayalam
                        ? 'നന്ദി! കാണാൻ കഴിഞ്ഞ്‌ സന്തോഷം'
                        : 'Thank you! So glad you can make it!')
                    : (_isMalayalam
                        ? 'ഒഴിവാക്കിയതിൽ ദുഃഖം'
                        : 'Sorry you can\'t make it. Thank you for letting us know.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                _isMalayalam ? 'ശരി' : 'OK',
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _openMaps() async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$_venueLat,$_venueLng');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  void _addToCalendar() async {
    final url = Uri.parse(
        'https://calendar.google.com/calendar/r/eventedit?text=Arjun+%26+Devika+Wedding&dates=20250315T050000Z/20250315T120000Z&location=$_venue');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  void _openUpiPayment(int? amount) async {
    final amt = amount ?? 501;
    final url = Uri.parse(
        'upi://pay?pa=athidhi@upi&pn=Arjun+Wedding&am=$amt&cu=INR&tn=Moidhu+Gift');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isMalayalam
                  ? 'UPI ആപ്പ് കണ്ടുപിടിക്കാൻ കഴിഞ്ഞില്ല'
                  : 'No UPI app found on this device',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }
}