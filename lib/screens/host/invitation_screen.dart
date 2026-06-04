import 'package:flutter/material.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/models/guest_model.dart';

class InvitationScreen extends StatefulWidget {
  final bool isMalayalam;
  const InvitationScreen({super.key, required this.isMalayalam});

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  String _selectedGroup = 'All';
  bool _isSending = false;
  int _sentCount = 0;

  final List<String> _groups = [
    'All',
    'Close Family',
    'Extended Family',
    'Friends',
    'VIP',
    'Colleagues',
  ];

  // Sample guests
  final List<Guest> _guests = [
    Guest(
        id: '1',
        name: 'Rajan Menon',
        phone: '9876543210',
        group: 'Close Family',
        status: 'accepted'),
    Guest(
        id: '2',
        name: 'Meera Nair',
        phone: '9876543211',
        group: 'Close Family',
        status: 'invited'),
    Guest(
        id: '3',
        name: 'Dr. Suresh Kumar',
        phone: '9876543212',
        group: 'VIP',
        status: 'viewed'),
    Guest(
        id: '4',
        name: 'Anitha Thomas',
        phone: '9876543213',
        group: 'Friends',
        status: 'invited'),
    Guest(
        id: '5',
        name: 'Priya Krishnan',
        phone: '9876543215',
        group: 'Friends',
        status: 'invited'),
    Guest(
        id: '6',
        name: 'Santhosh Pillai',
        phone: '9876543216',
        group: 'Colleagues',
        status: 'invited'),
  ];

  final Map<String, bool> _selected = {};

  @override
  void initState() {
    super.initState();
    for (final g in _guests) {
      _selected[g.id] = false;
    }
  }

  List<Guest> get _filteredGuests => _guests
      .where((g) => _selectedGroup == 'All' || g.group == _selectedGroup)
      .toList();

  int get _selectedCount => _selected.values.where((v) => v).length;

  String _templateMessage(Guest guest) {
    if (widget.isMalayalam) {
      return '''🌸 *${guest.name}* ജി,

നമസ്കാരം! 🙏

ഞങ്ങളുടെ വിവാഹ ആഘോഷത്തിലേക്ക് താങ്കളെ സ്നേഹപൂർവ്വം ക്ഷണിക്കുന്നു.

📅 തീയതി: 2025 മാർച്ച് 15
⏰ മുഹൂർത്തം: രാവിലെ 10:30
📍 സ്ഥലം: ഗണേശ് മഹൽ, തൃശ്ശൂർ

ദയവായി RSVP ചെയ്യുക 👇
[RSVP Link]

🗺️ ദിശകൾക്ക്: [Maps Link]

— Athidhi App വഴി''';
    }
    return '''🌸 Dear *${guest.name}*,

Greetings! 🙏

We joyfully invite you to our wedding celebration.

📅 Date: March 15, 2025
⏰ Muhurtham: 10:30 AM
📍 Venue: Ganesh Mahal, Thrissur

Please RSVP here 👇
[RSVP Link]

🗺️ Get Directions: [Maps Link]

— Sent via Athidhi App''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.isMalayalam ? 'ക്ഷണം അയക്കുക' : 'Send Invitations',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_selectedCount > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_selectedCount ${widget.isMalayalam ? 'തിരഞ്ഞെടുത്തു' : 'selected'}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildTemplatePreview(),
          _buildGroupFilter(),
          _buildSelectAll(),
          Expanded(child: _buildGuestList()),
        ],
      ),
      bottomNavigationBar: _buildSendBar(),
    );
  }

  Widget _buildTemplatePreview() {
    return GestureDetector(
      onTap: _showTemplateOptions,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.message,
                          color: Color(0xFF25D366), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.isMalayalam
                          ? 'WhatsApp ക്ഷണം'
                          : 'WhatsApp Invitation',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.isMalayalam ? 'മാറ്റുക' : 'Change',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDCF8C6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.isMalayalam
                    ? '🌸 [പേര്] ജി,\n\nനമസ്കാരം! 🙏\nവിവാഹ ആഘോഷത്തിലേക്ക് ക്ഷണിക്കുന്നു...\n\n📅 മാർച്ച് 15 · ⏰ 10:30 AM\n📍 ഗണേശ് മഹൽ, തൃശ്ശൂർ'
                    : '🌸 Dear [Name],\n\nGreetings! 🙏\nYou are invited to our wedding...\n\n📅 March 15 · ⏰ 10:30 AM\n📍 Ganesh Mahal, Thrissur',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1A1A1A),
                  height: 1.5,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _groups.length,
        itemBuilder: (_, i) {
          final selected = _groups[i] == _selectedGroup;
          return GestureDetector(
            onTap: () => setState(() => _selectedGroup = _groups[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                _groups[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectAll() {
    final all = _filteredGuests.every((g) => _selected[g.id] == true);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredGuests.length} ${widget.isMalayalam ? 'അതിഥികൾ' : 'guests'}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                for (final g in _filteredGuests) {
                  _selected[g.id] = !all;
                }
              });
            },
            child: Text(
              all
                  ? (widget.isMalayalam ? 'എല്ലാം നീക്കുക' : 'Deselect All')
                  : (widget.isMalayalam
                      ? 'എല്ലാം തിരഞ്ഞെടുക്കുക'
                      : 'Select All'),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: _filteredGuests.length,
      itemBuilder: (_, i) => _buildGuestTile(_filteredGuests[i]),
    );
  }

  Widget _buildGuestTile(Guest guest) {
    final isSelected = _selected[guest.id] ?? false;
    return GestureDetector(
      onTap: () => setState(() => _selected[guest.id] = !isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                guest.initials,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guest.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    '${guest.groupEmoji} ${guest.group} · +91 ${guest.phone}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Preview button
            GestureDetector(
              onTap: () => _showPreview(guest),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.visibility_outlined,
                    size: 16, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selectedCount > 0 && !_isSending ? _handleSendAll : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.border,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: _isSending
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${widget.isMalayalam ? 'അയക്കുന്നു' : 'Sending'} $_sentCount/$_selectedCount...',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _selectedCount > 0
                          ? '${widget.isMalayalam ? 'WhatsApp വഴി അയക്കുക' : 'Send via WhatsApp'} ($_selectedCount)'
                          : (widget.isMalayalam
                              ? 'അതിഥികളെ തിരഞ്ഞെടുക്കുക'
                              : 'Select guests to send'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _handleSendAll() async {
    setState(() {
      _isSending = true;
      _sentCount = 0;
    });
    // Simulate sending one by one
    final selectedGuests =
        _guests.where((g) => _selected[g.id] == true).toList();
    for (final guest in selectedGuests) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) setState(() => _sentCount++);
    }
    if (mounted) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isMalayalam
                ? '$_sentCount പേർക്ക് ക്ഷണം അയച്ചു! ✅'
                : '$_sentCount invitations sent! ✅',
          ),
          backgroundColor: AppColors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() {
        for (final g in selectedGuests) {
          _selected[g.id] = false;
        }
        _sentCount = 0;
      });
    }
  }

  void _showPreview(Guest guest) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isMalayalam ? 'ക്ഷണ പ്രിവ്യൂ' : 'Invitation Preview',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '→ ${guest.name}',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFDCF8C6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _templateMessage(guest),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1A1A1A),
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showTemplateOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isMalayalam
                  ? 'ടെംപ്ലേറ്റ് തിരഞ്ഞെടുക്കുക'
                  : 'Choose Template',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildTemplateOption(
                '❤️',
                widget.isMalayalam ? 'കുടുംബം' : 'Family',
                widget.isMalayalam
                    ? 'വ്യക്തിഗത വീഡിയോ ക്ഷണം'
                    : 'Personal video invite'),
            _buildTemplateOption(
                '💼',
                widget.isMalayalam ? 'സഹപ്രവർത്തകർ' : 'Colleagues',
                widget.isMalayalam
                    ? 'ഔദ്യോഗിക ഡിജിറ്റൽ കാർഡ്'
                    : 'Formal digital card'),
            _buildTemplateOption(
                '😊',
                widget.isMalayalam ? 'സുഹൃത്തുക്കൾ' : 'Friends',
                widget.isMalayalam ? 'കാഷ്വൽ ക്ഷണം' : 'Casual fun invite'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateOption(String emoji, String title, String subtitle) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
