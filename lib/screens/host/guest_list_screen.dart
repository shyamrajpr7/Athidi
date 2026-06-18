import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/models/guest_model.dart';
import 'package:athidhi/providers/guest_provider.dart';
import 'package:athidhi/providers/language_provider.dart';
import 'package:athidhi/screens/host/add_guest_screen.dart';

class GuestListScreen extends StatelessWidget {
  final bool isMalayalam;
  const GuestListScreen({super.key, required this.isMalayalam});

  final List<String> _groups = const [
    'All',
    'Close Family',
    'Extended Family',
    'Friends',
    'VIP',
    'Colleagues',
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted': return AppColors.green;
      case 'declined': return Colors.redAccent;
      case 'viewed':   return AppColors.primary;
      case 'pending':  return Colors.orange;
      default:         return AppColors.textMuted;
    }
  }

  String _statusLabel(String status, bool isMl) {
    if (isMl) {
      switch (status) {
        case 'accepted': return 'സ്ഥിരീകരിച്ചു';
        case 'declined': return 'നിരസിച്ചു';
        case 'viewed':   return 'കണ്ടു';
        case 'pending':  return 'ബാക്കി';
        default:         return 'ക്ഷണിച്ചു';
      }
    }
    switch (status) {
      case 'accepted': return 'Confirmed';
      case 'declined': return 'Declined';
      case 'viewed':   return 'Viewed';
      case 'pending':  return 'Pending';
      default:         return 'Invited';
    }
  }

  @override
  Widget build(BuildContext context) {
    final guestProvider = context.watch<GuestProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(child: _buildSearchBar(context, guestProvider)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddGuestScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_add,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildGroupFilter(context, guestProvider),
          _buildGuestCount(guestProvider),
          Expanded(
            child: guestProvider.status == GuestStatus.loading
                ? const Center(child: CircularProgressIndicator(
                    color: AppColors.primary))
                : _buildGuestList(context, guestProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, GuestProvider gp) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        onChanged: (v) => gp.setSearchQuery(v),
        decoration: InputDecoration(
          hintText: isMalayalam
              ? 'പേര് അല്ലെങ്കിൽ നമ്പർ തിരയുക...'
              : 'Search by name or number...',
          hintStyle: const TextStyle(color: AppColors.textMuted),
          prefixIcon:
              const Icon(Icons.search, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildGroupFilter(BuildContext context, GuestProvider gp) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _groups.length,
        itemBuilder: (_, i) {
          final selected = _groups[i] == gp.selectedGroup;
          return GestureDetector(
            onTap: () => gp.setSelectedGroup(_groups[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
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

  Widget _buildGuestCount(GuestProvider gp) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        isMalayalam
            ? '${gp.filteredGuests.length} അതിഥികൾ'
            : '${gp.filteredGuests.length} guests',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildGuestList(BuildContext context, GuestProvider gp) {
    final guests = gp.filteredGuests;
    if (guests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline,
                size: 60, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              isMalayalam ? 'അതിഥികൾ ആരും ഇല്ല' : 'No guests yet',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddGuestScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(isMalayalam
                  ? 'ആദ്യ അതിഥിയെ ചേർക്കുക'
                  : 'Add your first guest'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: guests.length,
      itemBuilder: (_, i) => _buildGuestCard(context, guests[i], gp),
    );
  }

  Widget _buildGuestCard(
      BuildContext context, Guest guest, GuestProvider gp) {
    return Dismissible(
      key: Key(guest.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => gp.deleteGuest(guest.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                guest.initials,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(guest.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textDark)),
                      const SizedBox(width: 6),
                      Text(guest.groupEmoji,
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text('+91 ${guest.phone}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 3),
                  Text(
                    '${guest.group} · ${guest.attendingCount} ${isMalayalam ? 'പേർ' : 'attending'}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showStatusPicker(context, guest, gp),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(guest.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _statusLabel(guest.status, isMalayalam),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(guest.status),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker(
      BuildContext context, Guest guest, GuestProvider gp) {
    final statuses = ['invited', 'viewed', 'accepted', 'declined'];
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
              isMalayalam ? 'സ്റ്റാറ്റസ് മാറ്റുക' : 'Update Status',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...statuses.map((s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _statusColor(s),
                    ),
                  ),
                  title: Text(_statusLabel(s, isMalayalam)),
                  onTap: () {
                    gp.updateGuestStatus(guest.id, s);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}