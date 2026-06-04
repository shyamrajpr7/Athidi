import 'package:flutter/material.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/models/guest_model.dart';
import 'package:athidhi/screens/host/add_guest_screen.dart';

class GuestListScreen extends StatefulWidget {
  final bool isMalayalam;
  const GuestListScreen({super.key, required this.isMalayalam});

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGroup = 'All';
  String _searchQuery = '';

  final List<String> _groups = [
    'All',
    'Close Family',
    'Extended Family',
    'Friends',
    'VIP',
    'Colleagues',
  ];

  // Sample guests — replaced by Firestore later
  final List<Guest> _allGuests = [
    Guest(id: '1', name: 'Rajan Menon', phone: '9876543210',
        group: 'Close Family', status: 'accepted', attendingCount: 4),
    Guest(id: '2', name: 'Meera Nair', phone: '9876543211',
        group: 'Close Family', status: 'pending'),
    Guest(id: '3', name: 'Dr. Suresh Kumar', phone: '9876543212',
        group: 'VIP', status: 'viewed'),
    Guest(id: '4', name: 'Anitha Thomas', phone: '9876543213',
        group: 'Friends', status: 'accepted', attendingCount: 2),
    Guest(id: '5', name: 'Biju Varghese', phone: '9876543214',
        group: 'Extended Family', status: 'declined'),
    Guest(id: '6', name: 'Priya Krishnan', phone: '9876543215',
        group: 'Friends', status: 'invited'),
    Guest(id: '7', name: 'Santhosh Pillai', phone: '9876543216',
        group: 'Colleagues', status: 'invited'),
    Guest(id: '8', name: 'Latha Chandran', phone: '9876543217',
        group: 'Extended Family', status: 'accepted', attendingCount: 3),
  ];

  List<Guest> get _filteredGuests {
    return _allGuests.where((g) {
      final matchGroup =
          _selectedGroup == 'All' || g.group == _selectedGroup;
      final matchSearch = g.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          g.phone.contains(_searchQuery);
      return matchGroup && matchSearch;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted': return AppColors.green;
      case 'declined': return Colors.redAccent;
      case 'viewed':   return AppColors.primary;
      case 'pending':  return Colors.orange;
      default:         return AppColors.textMuted;
    }
  }

  String _statusLabel(String status) {
    if (widget.isMalayalam) {
      switch (status) {
        case 'accepted': return 'സ്ഥിരീകരിച്ചു';
        case 'declined': return 'നിരസിച്ചു';
        case 'viewed':   return 'കണ്ടു';
        case 'pending':  return 'ബാക്കി';
        default:         return 'ക്ഷണിച്ചു';
      }
    } else {
      switch (status) {
        case 'accepted': return 'Confirmed';
        case 'declined': return 'Declined';
        case 'viewed':   return 'Viewed';
        case 'pending':  return 'Pending';
        default:         return 'Invited';
      }
    }
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
          widget.isMalayalam ? 'അതിഥി പട്ടിക' : 'Guest List',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddGuestScreen(isMalayalam: widget.isMalayalam),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildGroupFilter(),
          _buildGuestCount(),
          Expanded(child: _buildGuestList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: widget.isMalayalam
              ? 'പേര് അല്ലെങ്കിൽ നമ്പർ തിരയുക...'
              : 'Search by name or number...',
          hintStyle: const TextStyle(color: AppColors.textMuted),
          prefixIcon:
              const Icon(Icons.search, color: AppColors.textMuted),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textMuted),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color:
                    selected ? AppColors.primary : AppColors.surface,
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

  Widget _buildGuestCount() {
    final count = _filteredGuests.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            widget.isMalayalam
                ? '$count അതിഥികൾ'
                : '$count guests',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestList() {
    final guests = _filteredGuests;
    if (guests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline,
                size: 60, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              widget.isMalayalam
                  ? 'അതിഥികൾ ആരും ഇല്ല'
                  : 'No guests found',
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: guests.length,
      itemBuilder: (_, i) => _buildGuestCard(guests[i]),
    );
  }

  Widget _buildGuestCard(Guest guest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Avatar
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
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      guest.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(guest.groupEmoji, style: const TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  guest.phone,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 3),
                Text(
                  '${guest.group} · ${guest.attendingCount} ${widget.isMalayalam ? 'പേർ' : 'attending'}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          // Status + send
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(guest.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _statusLabel(guest.status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(guest.status),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.send,
                      size: 16, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}